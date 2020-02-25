/**
******************************************************************************
* @file    hal.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   Hardware Abstraction Layer
******************************************************************************
* @attention
*
* <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*   1. Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
*   2. Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
*   3. Neither the name of STMicroelectronics nor the names of its contributors
*      may be used to endorse or promote products derived from this software
*      without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
* Initial BlueNRG-Mesh is built over Motorola抯 Mesh over Bluetooth Low Energy 
* (MoBLE) technology. The present solution is developed and maintained for both 
* Mesh library and Applications solely by STMicroelectronics.
*
******************************************************************************
*/

/* Includes ------------------------------------------------------------------*/
#include "hal.h"
#include "hal_common.h"
#include "mesh_cfg.h"
#include "BlueNRG1_mft.h"
/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
* @brief  SetLed sets the state of led
* @param  int state
* @retval void
*/ 
void SetLed(int state)
{
#if LOW_POWER_FEATURE
    /* do nothing */
#else
    if (state)
    {
        SdkEvalLedOn(LED2_R_PIN);
    }
    else
    {
        SdkEvalLedOff(LED2_R_PIN);

    }
#endif
}

/**
* @brief  GetButtonState 
* @param  void
* @retval BUTTON_STATE returns the state of the button
*/ 
BUTTON_STATE GetButton2State(void)
{
  return SdkEvalPushButtonGetState(BUTTON_2);
}

/**
* @brief  Change State of Yellow led
* @param  none
* @retval void
*/ 
void StateYellowLed(MOBLEUINT8 const *data)
{
    if(*(data + 1) == 0x00)
        SdkEvalLedOff(LED1_R_PIN);
    else if(*(data + 1) == 0xFF)
        SdkEvalLedOn(LED1_R_PIN);
}

/**
* @brief  Change State of Blue led
* @param  none
* @retval void
*/ 
void StateBlueLed(MOBLEUINT8 const *data)
{
    if(*(data + 2) == 0x00)
        SdkEvalLedOff(LED2_R_PIN);
    else if(*(data + 2) == 0xFF)
        SdkEvalLedOn(LED2_R_PIN);
}

/**
* @brief  Change Status of Red led
* @param  none
* @retval void
*/ 
void StateRedLed(MOBLEUINT8 const *data)
{
    if(*data == 0x00)
        SdkEvalLedOff(LED2_G_PIN);
    else if(*data == 0xFF)
        SdkEvalLedOn(LED2_G_PIN);
}
/**
* @brief  GetButtonState 
* @param  void
* @retval BUTTON_STATE returns the state of the button
*/ 
BUTTON_STATE GetButtonState(void)
{
  return SdkEvalPushButtonGetState(BUTTON_1);
}

/**
* @brief  InitButton Initializes the Button
* @param  void
* @retval void
*/ 
static void InitButton(void)
{
  SdkEvalPushButtonInit(BUTTON_1);
}

/**
* @brief  InitDevice Initializes the device
* @param  void
* @retval void
*/
void InitDevice(void)
{
  GPIO_EXTIConfigType GPIO_EXTIStructure;
  
  SystemInit();/* Device Initialization */
  SdkEvalIdentification();
  NVIC->ICPR[0] = 0xFFFFFFFF;/* Clear pending interrupt on cortex */
#ifdef ENABLE_USART /* ENABLE_USART */
    SdkEvalComUartInit(UART_BAUDRATE);
#else
   	SdkEvalLedInit(LED1_G_PIN);
    SdkEvalLedInit(LED1_R_PIN);
#endif /* ENABLE_USART */
    Clock_Init();
    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_PKA, ENABLE);
    //**Start init **/
    //SdkEvalLedInit(LED1_G_PIN);
    //SdkEvalLedInit(LED1_R_PIN);
    SdkEvalLedInit(LED2_G_PIN);
    SdkEvalLedInit(LED2_R_PIN);
    SdkEvalLedInit(EN_PWR_PIN);
    SdkEvalLedInit(OG_PIN);
    //**Power up**//
		//Clock_Wait(500);
		Clock_Wait(500);//防止误触发
    SdkEvalLedOn(EN_PWR_PIN);
    //**Power ADC**//
    //SdkEvalLedOn(OG_PIN);

    //ADC_DMA_Start();
    ADC_Configuration();
	  //ADC_Configuration();
    ADC_Cmd(ENABLE);

    /* Delay for debug purpose, in order to see printed data at startup. */
    Clock_Wait(200);

#if 1//modify 20181013暂时去掉按键部分 
    /* Configures Button pin as input */
    InitButton();//need modify
    SdkEvalPushButtonIrq(BUTTON_1, IRQ_ON_RISING_EDGE);

    /* Enables the BUTTON Clock */
    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_GPIO, ENABLE);
#if 0
    /* Configure SWD_CLK as source of interrupt */
    GPIO_EXTIStructure.GPIO_Pin = SWD_CLK_PIN;
    GPIO_EXTIStructure.GPIO_IrqSense = GPIO_IrqSense_Edge;
    GPIO_EXTIStructure.GPIO_Event = GPIO_Event_High;
    GPIO_EXTIConfig( &GPIO_EXTIStructure);


    /* Clear GPIO pending interrupt on SWD_CLK */
    GPIO_ClearITPendingBit(SWD_CLK_PIN);

    /* Enable interrupt on WD_CLK*/
    GPIO_EXTICmd(SWD_CLK_PIN, ENABLE);
#endif
#endif

    SystemSleepCmd(ENABLE);
}
/**
* @brief  ShouldSleepFunc sleep mode fuction   
* @param  void
* @retval void
*/
void ShouldSleepFunc(void)
{
  __WFI();
}
/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/
