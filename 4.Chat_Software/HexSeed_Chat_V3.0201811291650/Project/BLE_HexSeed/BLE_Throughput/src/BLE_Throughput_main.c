#include <stdio.h>
#include <string.h>
#include "BlueNRG1_it.h"
#include "BlueNRG1_conf.h"
#include "ble_const.h"
#include "bluenrg1_stack.h"
#include "gp_timer.h"
#include "app_state.h"
#include "throughput.h"
#include "SDK_EVAL_Config.h"
#include "Throughput_config.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
#define BLE_HEXSEED_VERSION_STRING "1.0.0"
#define TIMES_SAMPLING 20
#define FILT_EN 1

#if  FILT_EN
uint16_t Filter_vlotage[TIMES_SAMPLING] = {0x00};
float vlotage = 0;
uint16_t Temperature_vlotage = 0;
uint16_t Batter_vlotage = 0;
#else
float vlotage = 0;
float Temperature_vlotage = 0;
float Batter_vlotage = 0;
#endif

static uint8_t adc_switch = 0;
extern ADC_InitType xADC_InitType;
uint8_t Adc_Data[10] = {0x79};
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/
uint16_t SDK_ADC_Filter(uint16_t *value_buf);
int main(void)
{
    uint8_t ret;
	
	  WRITE_REG(GPIO->DATS, GPIO_Pin_1);
    
	  SdkEvalLedOn(EN_PWR);
    /* System Init */
    SystemInit();

    /* Identify BlueNRG1 platform */
    SdkEvalIdentification();
	
    /* Init Clock */
    Clock_Init();
	
    SdkEvalLedInit(EN_PWR);
    SdkEvalLedOn(EN_PWR);
	
    SdkEvalLedInit(LED2_G);
    SdkEvalLedInit(LED2_R);

    SdkEvalLedInit(OG);
    SdkEvalLedInit(VCC_PWR);

    //**ADC Power up**//
    SdkEvalLedOn(OG);
    SdkEvalLedOn(VCC_PWR);
    //***************//
    SdkEvalLedOn(LED2_G);
    SdkEvalLedOff(LED2_R); //开机提示
    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_ADC, ENABLE);
    ADC_Configuration(ADC_Input_AdcPin1);//ADC_Input_AdcPin1);
    ADC_Cmd(ENABLE);
    Clock_Wait(200);

    /* Init the UART peripheral */
    SdkEvalComUartInit(UART_BAUDRATE);
    SdkEvalComUartIrqConfig(ENABLE);

    SdkEvalPWM_Init();//不要随意关闭此时钟，因为与ADC公用
    Modify_PWM(0, 0); //关闭PWM，修改GPIO
    SdkEvalTimerInit();//初始化Timer等待数据触发

    /* BlueNRG-1 stack init */
    ret = BlueNRG_Stack_Initialization(&BlueNRG_Stack_Init_params);
    if (ret != BLE_STATUS_SUCCESS)
    {
        printf("Error in BlueNRG_Stack_Initialization() 0x%02x\r\n", ret);
        while(1);
    }
    printf("BlueNRG-1 BLE HexSeed Server Application (version: %s)\r\n", BLE_HEXSEED_VERSION_STRING);


    /* Init Throughput test */
    ret = THROUGHPUT_DeviceInit();
    if (ret != BLE_STATUS_SUCCESS)
    {
        while(1);
    }
    SdkEvalPushButtonInit(OFF_PWR_BUTTON);
    printf("BLE Stack Initialized \n");

    while(1)
    {
        /* BlueNRG-1 stack tick */
        BTLE_StackTick();

        /* Application tick */
        APP_Tick();

        Appli_Process();

        if (System_flag.Low_Battery_Flag == 1)
        {
            SdkEvalLedOn(LED2_G);
            Clock_Wait(200);
            SdkEvalLedOff(LED2_G);
            Clock_Wait(200);
        }
        else
        {
            if (System_flag.Connect_Status == 1)
            {
                SdkEvalLedOn(LED2_R);
            }
            else
            {
                SdkEvalLedOff(LED2_R);
            }
        }

        ///*********************************************************************************//
#if 1
        if(System_flag.Adc_Updata_Flag == 1) //200ms上报一次电压温度值
        {
            System_flag.Adc_Updata_Flag = 0;
            /* Polling of End-Of-Conversion flag */
            while(!ADC_GetFlagStatus(ADC_FLAG_EOC));
            {
                vlotage = ADC_GetConvertedData(xADC_InitType.ADC_Input, xADC_InitType.ADC_ReferenceVoltage);
                Temperature_vlotage = vlotage * 1000.0;
                if(xADC_InitType.ADC_Input == ADC_Input_TempSensor)
                {
                    printf("ADC value: %.1f 'C\r\n", vlotage);
                }
                else
                {
                    //printf("ADC1 value: %.0f mV\r\n", vlotage * 1000.0);
                    Adc_Data[0] =	(uint8_t)(Temperature_vlotage >> 8); //H
                    Adc_Data[1] =	(uint8_t) Temperature_vlotage; //L
                    TempDatatophone(Adc_Data, 2);
                }
                //开启Vbat开关
                ADC->CONF_b.CHSEL = ADC_Input_BattSensor;
                ADC_Cmd(ENABLE);
                Clock_Wait(2);
                while( !ADC_GetFlagStatus(ADC_FLAG_EOC));
                {
                    vlotage = ADC_GetConvertedData(ADC_Input_BattSensor, xADC_InitType.ADC_ReferenceVoltage);
                    Batter_vlotage = vlotage * 1000.0;
                    if(xADC_InitType.ADC_Input == ADC_Input_TempSensor)
                    {
                        printf("ADC value: %.1f 'C\r\n", vlotage);
                    }
                    else
                    {
                        //printf("ADC2 value: %.0f mV\r\n", vlotage * 1000.0);

#if 1
                        if(Batter_vlotage < 2500)
                        {
                            printf("ADC POWER OFF\r\n");
                            System_flag.Low_Battery_Flag = 0;
                            SdkEvalLedOff(EN_PWR);
                        }
                        else if(Batter_vlotage < 2800)
                        {
                            printf("ADC POWER LOW\r\n");
                            Adc_Data[2] = 1; //低电量
                            System_flag.Low_Battery_Flag = 1;

#if !defined(ENABLE_USART)
                            SdkEvalLedOn(LED1_R);
                            Clock_Wait(500);
                            SdkEvalLedOff(LED1_R);
                            Clock_Wait(500);
#endif
                        }
                        else
                        {
                            Adc_Data[2] = 0; //正常电量
                            System_flag.Low_Battery_Flag = 0;
                        }
#endif
                        BattDatatophone(&Adc_Data[2], 1);
                    }
                    //printf("Temperature_vlotage value: %d V,Batter_vlotage value: %d V,\r\n", Temperature_vlotage, Batter_vlotage);
										printf("Batter_vlotage value: %d V,\r\n", Batter_vlotage);
                    Clock_Wait(2);
                    ADC->CONF_b.CHSEL = ADC_Input_AdcPin1;
                    ADC_Cmd(ENABLE);
                }
            }

        }
#else



#if FILT_EN
        //多adc
        if(System_flag.Adc_Updata_Flag == 1) //200ms上报一次电压温度值
        {
            System_flag.Adc_Updata_Flag = 0;
            if (adc_switch < TIMES_SAMPLING)
            {
                if( ADC_GetFlagStatus(ADC_FLAG_EOC))
                {
                    vlotage = ADC_GetConvertedData(xADC_InitType.ADC_Input, xADC_InitType.ADC_ReferenceVoltage);
                    if(vlotage < 0)
                        vlotage = 0;

                    Filter_vlotage[adc_switch] = vlotage * 1000;
                }
            }
            adc_switch++;
            if(adc_switch == TIMES_SAMPLING)
            {
                adc_switch = 0;
                //ADC_Cmd(DISABLE);
                if (xADC_InitType.ADC_Input == ADC_Input_AdcPin1)
                {
                    Temperature_vlotage = SDK_ADC_Filter(Filter_vlotage);
                    // ADC_Configuration(ADC_Input_BattSensor);
                    ADC->CONF_b.CHSEL = ADC_Input_BattSensor;
                    ADC_Cmd(ENABLE);
                    //处理温度数据
                    Adc_Data[0] =	(uint8_t)(Temperature_vlotage >> 8); //H
                    Adc_Data[1] =	(uint8_t) Temperature_vlotage; //L
                    TempDatatophone(Adc_Data, 2);
                }
                else if (xADC_InitType.ADC_Input == ADC_Input_BattSensor)
                {
                    Batter_vlotage = SDK_ADC_Filter(Filter_vlotage);
                    //ADC_Configuration(ADC_Input_AdcPin1);
                    //处理电池数据
                    //ADC->CONF_b.CHSEL = ADC_Input_AdcPin1;
                    ADC->CONF_b.CHSEL = ADC_Input_AdcPin1;
                    ADC_Cmd(ENABLE);
                    BattDatatophone(&Adc_Data[2], 1);
#if 1
                    if(Batter_vlotage < 2500)
                    {
                        printf("ADC POWER OFF\r\n");
                        System_flag.Low_Battery_Flag = 0;
                        SdkEvalLedOff(EN_PWR);
                    }
                    else if(Batter_vlotage < 2800)
                    {
                        printf("ADC POWER LOW\r\n");
                        Adc_Data[2] = 1; //低电量
                        System_flag.Low_Battery_Flag = 1;

#if !defined(ENABLE_USART)
                        SdkEvalLedOn(LED1_R);
                        Clock_Wait(500);
                        SdkEvalLedOff(LED1_R);
                        Clock_Wait(500);
#endif
                    }
                    else
                    {
                        Adc_Data[2] = 0; //正常电量
                        System_flag.Low_Battery_Flag = 0;
                    }
#endif
                }
                else
                {
                    Temperature_vlotage = SDK_ADC_Filter(Filter_vlotage);
                    ADC->CONF_b.CHSEL = ADC_Input_AdcPin1;
                    ADC_Cmd(ENABLE);
                }
                printf("Temperature_vlotage value: %d V,Batter_vlotage value: %d V,\r\n", Temperature_vlotage, Batter_vlotage);
            }
        }
#else
        //***************************************************************///
        //多adc
        if(System_flag.Adc_Updata_Flag == 1) //1S上报一次电压温度值
        {
            adc_switch++;
            System_flag.Adc_Updata_Flag = 0;

            if (adc_switch == 1)
            {
                if( ADC_GetFlagStatus(ADC_FLAG_EOC))
                {
                    vlotage = ADC_GetConvertedData(xADC_InitType.ADC_Input, xADC_InitType.ADC_ReferenceVoltage);
                    if(vlotage < 0)
                        vlotage = 0;
                    if (xADC_InitType.ADC_Input == ADC_Input_AdcPin1)
                    {
                        Temperature_vlotage = vlotage;
                        Adc_Data[0] =	(uint8_t)((uint16_t)(Temperature_vlotage * 1000) >> 8); //H
                        Adc_Data[1] =	(uint8_t) (uint16_t)(Temperature_vlotage * 1000); //L
                    }
                    else if (xADC_InitType.ADC_Input == ADC_Input_BattSensor)
                    {
                        Batter_vlotage = vlotage;
#if 1
                        if(Batter_vlotage < (float)2.5)
                        {
                            printf("ADC POWER OFF\r\n");
                            System_flag.Low_Battery_Flag = 0;
                            SdkEvalLedOff(EN_PWR);
                        }
                        else if(Batter_vlotage < (float)2.8)
                        {
                            printf("ADC POWER LOW\r\n");
                            Adc_Data[2] = 1; //低电量
                            System_flag.Low_Battery_Flag = 1;

#if !defined(ENABLE_USART)
                            SdkEvalLedOn(LED1_R);
                            Clock_Wait(500);
                            SdkEvalLedOff(LED1_R);
                            Clock_Wait(500);
#endif
                        }
                        else
                        {
                            Adc_Data[2] = 0; //正常电量
                            System_flag.Low_Battery_Flag = 0;
                        }
#endif
                    }
                    else
                    {
                        Temperature_vlotage = vlotage;
                    }
                    TempDatatophone(Adc_Data, 3); //温度上报，每5S检测一次是否要上报
                    printf("Temperature_vlotage value: %.2f V,Batter_vlotage value: %.2f V,\r\n", Temperature_vlotage, Batter_vlotage);
                }
            }
            if (adc_switch == 2)
            {
                adc_switch = 0;
                ADC_Cmd(DISABLE);
                if (xADC_InitType.ADC_Input == ADC_Input_AdcPin1)
                {
                    ADC_Configuration(ADC_Input_BattSensor);
                }
                else if (xADC_InitType.ADC_Input == ADC_Input_BattSensor)
                {
                    ADC_Configuration(ADC_Input_AdcPin1);
                }
                else
                {
                    ADC_Configuration(ADC_Input_AdcPin1);
                }
                ADC_Cmd(ENABLE);
            }
        }
        //***************************************************************///
#endif

#endif
        //********************************************************************************//

    }

} /* end main() */


uint16_t SDK_ADC_Filter(uint16_t *value_buf)
{
    uint16_t i, j;
    uint16_t temp;

    for (j = 0; j < TIMES_SAMPLING - 1; j++)
    {
        for (i = 0; i < TIMES_SAMPLING - 1 - j; i++)
        {
            if ( value_buf[i] > value_buf[i + 1] )
            {
                temp = value_buf[i];
                value_buf[i] = value_buf[i + 1];
                value_buf[i + 1] = temp;
            }
        }
    }
    return value_buf[(TIMES_SAMPLING - 1) / 2];
}


#ifdef  USE_FULL_ASSERT

/**
* @brief  Reports the name of the source file and the source line number
*         where the assert_param error has occurred.
* @param  file: pointer to the source file name
* @param  line: assert_param error line source number
*/
void assert_failed(uint8_t *file, uint32_t line)
{
    /* User can add his own implementation to report the file name and line number,
    ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

    /* Infinite loop */
    while (1)
    {
    }
}

#endif

/******************* (C) COPYRIGHT 2015 STMicroelectronics *****END OF FILE****/
/** \endcond
 */
