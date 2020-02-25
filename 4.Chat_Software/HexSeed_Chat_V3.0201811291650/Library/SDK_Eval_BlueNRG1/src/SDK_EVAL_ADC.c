#include "SDK_EVAL_ADC.h"

uint16_t buffer_adc[ADC_DMA_BUFFER_LEN];
ADC_InitType xADC_InitType;

/**
* @brief  ADC_Configuration.
* @param  None
* @retval None
*/
void ADC_Configuration(uint8_t input_cha)
{
   
    /* Configure ADC */
    /* ADC_Input_AdcPin1 == ADC1 */
    /* ADC_Input_AdcPin2 == ADC2 */
    /* ADC_Input_AdcPin12 == ADC1 - ADC2 */
    xADC_InitType.ADC_OSR = ADC_OSR_200;
    //ADC_Input_BattSensor; //ADC_Input_TempSensor;// ADC_Input_AdcPin1 // ADC_Input_AdcPin12 // ADC_Input_AdcPin2
    xADC_InitType.ADC_Input = input_cha; //ADC_Input_BattSensor; //ADC_Input_AdcPin1;//ADC_Input_AdcPin2;
    xADC_InitType.ADC_ConversionMode = ADC_ConversionMode_Single;
    xADC_InitType.ADC_ReferenceVoltage = ADC_ReferenceVoltage_0V6; //ADC_ReferenceVoltage_0V6;
    xADC_InitType.ADC_Attenuation = ADC_Attenuation_9dB54;

    ADC_Init(&xADC_InitType);

    /* Enable auto offset correction */
    ADC_Calibration(ENABLE);
    ADC_AutoOffsetUpdate(ENABLE);
    ADC_Filter(ENABLE);
}
/**
* @brief  DMA_Configuration.
* @param  None
* @retval None
*/
void DMA_Configuration(void)
{
    DMA_InitType DMA_InitStructure;

    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_DMA, ENABLE);

    /* DMA_CH_UART_TX Initialization */
    DMA_InitStructure.DMA_PeripheralBaseAddr = ADC_OUT_ADDRESS;
    DMA_InitStructure.DMA_MemoryBaseAddr = (uint32_t)buffer_adc;
    DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;
    DMA_InitStructure.DMA_BufferSize = (uint32_t)ADC_DMA_BUFFER_LEN;
    DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
    DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
    DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_HalfWord;
    DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_HalfWord;
    DMA_InitStructure.DMA_Mode = DMA_Mode_Normal; //DMA_Mode_Circular;
    DMA_InitStructure.DMA_Priority = DMA_Priority_High;
    DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;
    DMA_Init(ADC_DMA_CH0, &DMA_InitStructure);

    /* Enable DMA ADC CHANNEL 0 Transfer Complete interrupt */
    DMA_FlagConfig(ADC_DMA_CH0, DMA_FLAG_TC, ENABLE);

    /* Select DMA ADC CHANNEL 0 */
    DMA_SelectAdcChannel(DMA_ADC_CHANNEL0, ENABLE);

    /* Enable DMA ADC CHANNEL 0 */
    DMA_Cmd(ADC_DMA_CH0, ENABLE);
}

void ADC_DMA_Start(void)
{
    /* DMA Initialization */
    DMA_Configuration();

    /* ADC Initialization */
    ADC_Configuration(ADC_Input_BattSensor);

    /* ADC Initialization */
    ADC_DmaCmd(ENABLE);

    /* Start new conversion */
    ADC_Cmd(ENABLE);
}


void ADC_BAT_Configuration(void)
{
    SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_ADC, ENABLE);

    xADC_InitType.ADC_OSR = ADC_OSR_200;
    xADC_InitType.ADC_Input = ADC_Input_BattSensor;//ADC_Input_AdcPin1;//ADC_Input_AdcPin12; //ADC_Input_AdcPin12;
    xADC_InitType.ADC_ConversionMode = ADC_ConversionMode_Continuous;
    xADC_InitType.ADC_ReferenceVoltage = ADC_ReferenceVoltage_0V6;
    xADC_InitType.ADC_Attenuation = ADC_Attenuation_9dB54;

    ADC_Init(&xADC_InitType);

    /* Enable auto offset correction */
    ADC_Calibration(ENABLE);
    ADC_AutoOffsetUpdate(ENABLE);
}
