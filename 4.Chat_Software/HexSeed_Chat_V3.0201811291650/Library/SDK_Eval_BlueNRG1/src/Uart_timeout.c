/* ========================================
 *
 * Copyright Jerry Liu, 2016
 * All Rights Reserved
 *
 * Author: Jerry Liu
 * Time: 13/1/2017
 * Version: 1.0
 *
 * ========================================
*/
#include "Uart_timeout.h"
#include "BlueNRG1_mft.h"
#include "BlueNRG1_it.h"
#include "BlueNRG1_conf.h"
#include "BlueNRG1_api.h"
#include "ble_status.h"

void Uarttimeout_Init(void)
{
  NVIC_InitType NVIC_InitStructure;
  MFT_InitType timer_init;
  
  SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_MTFX1, ENABLE);
  
  MFT_StructInit(&timer_init); //≥ı ºªØtimer_init
  
  timer_init.MFT_Mode = MFT_MODE_1;
  timer_init.MFT_Prescaler = 160-1;      /* 10 us clock */
  
  /* MFT1 configuration */
  timer_init.MFT_Clock1 = MFT_PRESCALED_CLK;
  timer_init.MFT_Clock2 = MFT_NO_CLK;
  timer_init.MFT_CRA = 500 - 1;       /* 5ms positive duration */
  MFT_Init(MFT1, &timer_init);
    
  /* Enable MFT1 Interrupt 1 */
  NVIC_InitStructure.NVIC_IRQChannel = MFT1A_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = LOW_PRIORITY;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  
  MFT_EnableIT(MFT1, MFT_IT_TNA, ENABLE);
}
//
void Uarttimeout_Start(void)
{
  MFT_Cmd(MFT1, ENABLE);
}
//
void Uarttimeout_Stop(void)
{
  MFT_Cmd(MFT1, DISABLE);
}
