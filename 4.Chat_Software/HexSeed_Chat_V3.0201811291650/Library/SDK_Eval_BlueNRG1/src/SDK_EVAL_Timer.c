#include "SDK_EVAL_Timer.h"

void SdkEvalTimerInit(void)
{
	  uint16_t prescaler = 16;
    NVIC_InitType NVIC_InitStructure;
    MFT_InitType timer_init;
    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_MTFX1, ENABLE);
    MFT_Cmd(MFT1, DISABLE);
    MFT_StructInit(&timer_init);

    timer_init.MFT_Mode = MFT_MODE_1;
    timer_init.MFT_Prescaler = prescaler - 1;    /* 1us clock */

    timer_init.MFT_Clock2 = MFT_PRESCALED_CLK;
    MFT_Init(MFT1, &timer_init);

    MFT_SetCounter2(MFT1, TIME1_PERIOD);//5ms
    /* Enable MFT2 Interrupt 2 */
    NVIC_InitStructure.NVIC_IRQChannel = MFT1B_IRQn;
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = LOW_PRIORITY;
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_InitStructure);

    MFT_EnableIT(MFT1, MFT_IT_TND, ENABLE);
}

void SdkEvalPWM_Init(void)
{
    /* Prescaler for clock freqquency for MFT */
//#if (HS_SPEED_XTAL == HS_SPEED_XTAL_32MHZ)
//   uint16_t prescaler = 32;
//#elif (HS_SPEED_XTAL == HS_SPEED_XTAL_16MHZ)
     uint16_t prescaler = 16;
//#endif
	
	

    /* GPIO Configuration */
    GPIO_InitType GPIO_InitStructure;

    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_GPIO, ENABLE);

    /* Configure PWM pins */
    GPIO_InitStructure.GPIO_Pin = PWM1_PIN;
    GPIO_InitStructure.GPIO_Mode = Serial1_Mode; //mode 1
    GPIO_InitStructure.GPIO_Pull = DISABLE;
    GPIO_InitStructure.GPIO_HighPwr = DISABLE;
    GPIO_Init( &GPIO_InitStructure);

    /* MFT Configuration */
    NVIC_InitType NVIC_InitStructure;
    MFT_InitType timer_init;
    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_MTFX2, ENABLE);

    MFT_StructInit(&timer_init);

    timer_init.MFT_Mode = MFT_MODE_1;
    timer_init.MFT_Prescaler = prescaler - 1;     
	

    /* MFT2 configuration */
    timer_init.MFT_Clock1 = MFT_PRESCALED_CLK;
    timer_init.MFT_CRA = MFT2_TON_1;      
    timer_init.MFT_CRB = MFT2_TOFF_1;     
    MFT_Init(MFT2, &timer_init);
    MFT_SetCounter1(MFT2, TIME2_PERIOD);//4ms

    NVIC_InitStructure.NVIC_IRQChannel = MFT2A_IRQn;
		NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = LOW_PRIORITY;
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_InitStructure);

    MFT_EnableIT(MFT2, MFT_IT_TNA, ENABLE);

    MFT_TnXEN(MFT2, MFT_TnA, ENABLE);
    MFT_Cmd(MFT2, ENABLE);

}


/* Enable MFT1 Interrupt 2 */
void SdkEvalTimer_Enable(FunctionalState NewState)
{
    if (NewState == ENABLE)
    {
			  MFT1->TNMCTRL_b.TNEN = SET;
    }
    else
    { 
				MFT1->TNMCTRL_b.TNEN = RESET;
    }
}

void SdkEvalPwm_Enable(FunctionalState NewState)
{
	  GPIO_InitType GPIO_InitStructure;
    if (NewState == ENABLE)
    {
			GPIO_InitStructure.GPIO_Pin = PWM1_PIN;
      GPIO_InitStructure.GPIO_Mode = Serial1_Mode; //mode 1
      GPIO_Init( &GPIO_InitStructure);
    }
    else
    { 
      GPIO_InitStructure.GPIO_Pin = PWM1_PIN;      
			GPIO_InitStructure.GPIO_Mode = GPIO_Output; //Ouput
      GPIO_Init( &GPIO_InitStructure);
			WRITE_REG(GPIO->DATC, PWM1_PIN);
    }
}

/**
  *@brief  PWM modification
  *@param  PWM_ID: PWM number
  *@param  duty_cycle: Duty cycle at output 
  *@retval None
  */
void Modify_PWM( uint8_t PWM_ID,uint16_t duty_cycle) 
{
	
	if (duty_cycle==0)
	{
	  SdkEvalPwm_Enable(DISABLE);
	}else
	{ 
	  SdkEvalPwm_Enable(ENABLE);
		
	switch (PWM_ID) 
  {
			case 0: // PWM0 
			{
					MFT2->TNCRA = duty_cycle;
					MFT2->TNCRB = TIME2_PERIOD - duty_cycle;
			}
			break;
			case 1: // PWM1 
			{
					//MFT2->TNCRA = duty_cycle;
					//MFT2->TNCRB = TIME_PERIOD - duty_cycle;
			}
			break;
			case 2: // PWM2 
			{
					//PWM2_on = duty_cycle;
			}
			break;
			case 3: // PWM3 
			{
					//PWM3_on = duty_cycle;
			}
			break;
			case 4: // PWM4 
			{
					//PWM4_on = duty_cycle;
                                        
			}
			break;
		    }
			
	}
}
