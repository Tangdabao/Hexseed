#ifndef __SDK_EVAL_ADC_H
#define __SDK_EVAL_ADC_H

/* Includes ------------------------------------------------------------------*/
#include "BlueNRG_x_device.h"
#include "BlueNRG1_conf.h"
#include "SDK_EVAL_Config.h"
   
#ifdef __cplusplus
 extern "C" {
#endif

#define ADC_OUT_ADDRESS         (ADC_BASE + 0x16)
#define ADC_DMA_CH0             (DMA_CH0)
	 
#define ADC_DMA_BUFFER_LEN      (256)

void ADC_Configuration(void);
void DMA_Configuration(void);
void ADC_DMA_Start(void);
void ADC_BAT_Configuration(void);
#ifdef __cplusplus
}
#endif

#endif
