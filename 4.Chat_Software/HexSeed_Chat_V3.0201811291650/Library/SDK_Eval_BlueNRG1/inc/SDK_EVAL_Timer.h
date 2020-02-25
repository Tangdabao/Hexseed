#ifndef __SDK_EVAL_TIMER_H
#define __SDK_EVAL_TIMER_H
/* Includes ------------------------------------------------------------------*/
#include "BlueNRG_x_device.h"
#include "BlueNRG1_conf.h"
#include "SDK_EVAL_Config.h"

#ifdef __cplusplus
 extern "C" {
#endif
	 
#define PWM1_PIN			GPIO_Pin_3 
#define TIME1_PERIOD 5000	//5ms 
#define TIME2_PERIOD 4000 //4mS
#define MFT2_TON_1  (20 - 1)
#define MFT2_TOFF_1 (3980 - 1)

	 
void SdkEvalTimerInit(void);
void SdkEvalTimer_Enable(FunctionalState NewState);
void SdkEvalPWM_Init(void);
void Modify_PWM( uint8_t PWM_ID,uint16_t duty_cycle); 
#ifdef __cplusplus
}
#endif

#endif
