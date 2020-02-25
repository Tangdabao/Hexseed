/**
  ******************************************************************************
  * @file    BlueNRG1_it.c
  * @author  VMA RF Application Team
  * @version V1.0.0
  * @date    September-2015
  * @brief   Main Interrupt Service Routines.
  *          This file provides template for all exceptions handler and
  *          peripherals interrupt service routine.
  ******************************************************************************
  * @attention
  *
  * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
  * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
  * TIME. AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY
  * DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
  * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE
  * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
  *
  * <h2><center>&copy; COPYRIGHT 2015 STMicroelectronics</center></h2>
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "BlueNRG1_it.h"
#include "BlueNRG1_conf.h"
#include "ble_const.h"
#include "bluenrg1_stack.h"
#include "SDK_EVAL_Com.h"
#include "clock.h"
#include "string.h"
#include "throughput.h"
#include "gatt_db.h"
#include "app_state.h"
/** @addtogroup BlueNRG1_StdPeriph_Examples
  * @{
  */

/** @addtogroup GPIO_Examples
  * @{
  */

/** @addtogroup GPIO_IOToggle
  * @{
  */

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
volatile uint16_t MsCouter = 0;
volatile uint16_t ADCCouter = 0;
static uint8_t UartData[128];
static uint8_t UartData_Len = 0;
static uint8_t Uart_Timer_En = 0;
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/******************************************************************************/
/*            Cortex-M0 Processor Exceptions Handlers                         */
/******************************************************************************/

/**
  * @brief  This function handles NMI exception.
  */
void NMI_Handler(void)
{
}

/**
  * @brief  This function handles Hard Fault exception.
  */
void HardFault_Handler(void)
{
    /* Go to infinite loop when Hard Fault exception occurs */
    while (1)
    {}
}

/**
  * @brief  This function handles SVCall exception.
  */
void SVC_Handler(void)
{
}

/**
  * @brief  This function handles PendSV_Handler exception.
  */
//void PendSV_Handler(void)
//{
//}

/**
  * @brief  This function handles SysTick Handler.
  */
void SysTick_Handler(void)
{
    SysCount_Handler();
    //�������������ʱ�򣬿�ʼ��ʱ
    if (Uart_Timer_En ==1)
    {
        MsCouter++;
    }
    if(MsCouter==5)//������������벢�ҳ���5ms������20�ֽڴ������
    {
        APP_FLAG_SET(TX_BUFFER_FULL);
        MsCouter = 0;//���������
        Uart_Timer_En=0;//�ص�������
    }
    //Ԥ��������ʱ
    if(MsCouter > BlUENRG_100MS)
    {
        MsCouter = 0;

    }
}

void GPIO_Handler(void)
{
}
/******************************************************************************/
/*                 BlueNRG-1 Peripherals Interrupt Handlers                   */
/*  Add here the Interrupt Handler for the used peripheral(s) (PPP), for the  */
/*  available peripheral interrupt handler's name please refer to the startup */
/*  file (system_bluenrg1.c).                                               */
/******************************************************************************/
/**
* @brief  This function handles UART interrupt request.
* @param  None
* @retval None
*/
void UART_Handler(void)
{
    //SdkEvalComIOUartIrqHandler();
    if(UART_GetITStatus(UART_IT_RX) != RESET)
    {
        UART_ClearITPendingBit(UART_IT_RX);
        Uart_Timer_En =0;
        UartData[UartData_Len]=(uint8_t) (UART_ReceiveData() & 0xFF);
        UartData_Len++;
        Uart_Timer_En =1;
    }
}
uint8_t UartRxDataLen(void)
{
    return UartData_Len;
}

void UartRxData(uint8_t **Data)
{
    *Data = UartData;
}

void ClearUartData(void)
{
    UartData_Len=0;
    APP_FLAG_CLEAR(TX_BUFFER_FULL);
    memset(UartData,0,20);
}

void Blue_Handler(void)
{
    //Call RAL_Isr
    RAL_Isr();
}
/**
  * @brief  This function handles MFT2A interrupt request.
  * @param  None
  * @retval None
  */
void MFT2A_Handler(void)
{
    if ( MFT_StatusIT(MFT2,MFT_IT_TNA) != RESET )
    {
        ADCCouter++;
        if (ADCCouter==250)//200ms�ϱ�һ��ADC��4ms��
        {
            ADCCouter=0;
            System_flag.Adc_Updata_Flag=1;
        }
        //MFT_SetCounter1(MFT2, TIME2_PERIOD);
        /** Clear MFT2 pending interrupt A */
        MFT_ClearIT(MFT2, MFT_IT_TNA);
    }
}

/**
  * @}
  */
//Timer Interrupt handler
//base 50ms
void MFT1B_Handler(void)
{
    if ( MFT_StatusIT(MFT1, MFT_IT_TND) != RESET )
    {
        //SdkEvalLedToggle(LED1);
        MFT_SetCounter2(MFT1, TIME1_PERIOD);
        CmdFromBt_st.BTCmdCount++;
        if(CmdFromBt_st.BTCmdCount > 10)//���50ms���������ڷ��ͣ������һ֡����
        {
            //System_flag.Com_Flag=1;
            CmdFromBt_st.BTFinalFlag = 1;//������ɱ�־
            CmdFromBt_st.BTCmdCount = 0;//�����������

            SdkEvalTimer_Enable(DISABLE);//�رն�ʱ��
            APP_FLAG_SET(RX_BUFFER_FULL);
        }
        else
        {
            CmdFromBt_st.BTFinalFlag = 0;
        }
        /** Clear MFT2 pending interrupt A */
        MFT_ClearIT(MFT1, MFT_IT_TND);
    }
}
/**
  * @}
  */

/**
  * @}
  */

/******************* (C) COPYRIGHT 2015 STMicroelectronics *****END OF FILE****/
