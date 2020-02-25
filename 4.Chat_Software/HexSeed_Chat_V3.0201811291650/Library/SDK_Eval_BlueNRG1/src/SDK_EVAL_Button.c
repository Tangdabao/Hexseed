/**
 * @file    SDK_EVAL_Button.c
 * @author  AMS VMA RF application team
 * @version V1.1.0
 * @date    September 29, 2015
 * @brief   This file provides all the low level API to manage buttons for eval board.
 * @details
 *
 * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
 * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
 * TIME. AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY
 * DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
 * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE
 * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
 *
 * THIS SOURCE CODE IS PROTECTED BY A LICENSE.
 * FOR MORE INFORMATION PLEASE CAREFULLY READ THE LICENSE AGREEMENT FILE LOCATED
 * IN THE ROOT DIRECTORY OF THIS FIRMWARE PACKAGE.
 *
 * <h2><center>&copy; COPYRIGHT 2015 STMicroelectronics</center></h2>
 */


/* Includes ------------------------------------------------------------------*/
#include "SDK_EVAL_Button.h"
#include "clock.h"
#include <stdio.h>
//#include "BlueNRG1_flash.h"
//typedef  void (*pFunction)(void);

tClockTime tBounce = 0;
enum ButtonState buttonState = BS_OFF;
extern volatile uint32_t ota_sw_activation;
//#define OTA_MESH_TAG      (0xAA5555AA)
//#define APP_FLAG_ADDRESS  0x100407F0
//#define APP_MESH_ADDRESS  0x10040800

/** @defgroup SDK_EVAL_Button_Private_Defines                   SDK EVAL Button Private Defines
 * @{
 */

/**
 * @}
 */


/** @defgroup SDK_EVAL_Button_Private_Macros                    SDK EVAL Button Private Macros
 * @{
 */

/**
 * @}
 */



/** @defgroup SDK_EVAL_Button_Private_FunctionPrototypes                        SDK EVAL Button Private Function Prototypes
 * @{
 */

/**
 * @}
 */

/** @defgroup SDK_EVAL_Button_Private_Functions                                 SDK EVAL Button Private Functions
 * @{
 */

/* Buttons IRQ Pin */
uint32_t Get_ButtonGpioPin(SdkEvalButton xButton)
{
    uint32_t button_pin;
    switch (xButton)
    {
    case(OFF_PWR_BUTTON):
        button_pin = PUSH_OFF_PWR_BUTTON_PIN;
        break;
    case(ON_PWR_BUTTON):
        button_pin = PUSH_ON_PWR_BUTTON_PIN;
        break;
    default:
        button_pin = PUSH_OFF_PWR_BUTTON_PIN;
        break;
    }
    return (button_pin);
}

/**
 * @}
 */




/** @defgroup SDK_EVAL_Button_Public_Functions                                 SDK EVAL Button Public Functions
 * @{
 */


/**
 * @brief  Configures Buttons.
 * @param  xButton Specifies the Button to be configured, @ref SdkEvalButton
 *         This parameter can be one of following parameters:
 *         @arg BUTTON_1: Push1 button
 *         @arg BUTTON_2: Push2 button
 * @retval None.
 */
void SdkEvalPushButtonInit(SdkEvalButton xButton)
{  
  GPIO_InitType GPIO_InitStructure;
    
  /* Enables the BUTTON Clock */
  SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_GPIO, ENABLE);

  /* Configures Button pin as input */
  GPIO_InitStructure.GPIO_Pin = Get_ButtonGpioPin(xButton);
  GPIO_InitStructure.GPIO_Mode = GPIO_Input;
  GPIO_InitStructure.GPIO_Pull = DISABLE;
  GPIO_InitStructure.GPIO_HighPwr = DISABLE;
  GPIO_Init(&GPIO_InitStructure);

}


/**
 * @brief  Configures buttons IRQ mode.
 * @param  xButton Specifies the Button to be configured, @ref SdkEvalButton
 *         This parameter can be one of following parameters:
 *         @arg BUTTON_1: Push1 button
 *         @arg BUTTON_2: Push2 button
 * @param  xButton Specifies the IRQ mode to be configured, @ref SdkEvalButtonIrq
 *         This parameter can be one of following parameters:
 *         @arg IRQ_ON_RISING_EDGE: IRQ on rising edge
 *         @arg IRQ_ON_FALLING_EDGE: IRQ on falling edge
 *         @arg IRQ_ON_BOTH_EDGE: IRQ on both edges
 * @retval None.
 */
void SdkEvalPushButtonIrq(SdkEvalButton xButton, SdkEvalButtonIrq xButtonIrq)
{  
  GPIO_EXTIConfigType GPIO_EXTIStructure;
  NVIC_InitType NVIC_InitStructure;

  /* Set the GPIO interrupt priority and enable it */
  NVIC_InitStructure.NVIC_IRQChannel = GPIO_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = LOW_PRIORITY;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  
  /* Configures EXTI line */
  GPIO_EXTIStructure.GPIO_Pin = Get_ButtonGpioPin(xButton);
  GPIO_EXTIStructure.GPIO_IrqSense = GPIO_IrqSense_Edge;
  GPIO_EXTIStructure.GPIO_Event = xButtonIrq;
  GPIO_EXTIConfig(&GPIO_EXTIStructure);

  /* Clear pending interrupt */
  GPIO_ClearITPendingBit(Get_ButtonGpioPin(xButton));
  
  /* Enable the interrupt */
  GPIO_EXTICmd(Get_ButtonGpioPin(xButton), ENABLE);
}


/**
 * @brief  Returns the selected Button state.
 * @param  xButton Specifies the Button to be configured, @ref SdkEvalButton
 *         This parameter can be one of following parameters:
 *         @arg BUTTON_1: Push1 button
 *         @arg BUTTON_2: Push2 button
 * @retval FlagStatus: error status of the button @ref FlagStatus
 *         This parameter can be: SET or RESET.
 */
FlagStatus SdkEvalPushButtonGetState(SdkEvalButton xButton)
{
  if(GPIO_ReadBit(Get_ButtonGpioPin(xButton)))
    return SET;
  else
    return RESET;
}


/**
 * @brief  Get the pending bit state.
 * @param  xButton Specifies the Button to be configured, @ref SdkEvalButton
 *         This parameter can be one of following parameters:
 *         @arg BUTTON_1: Push1 button
 *         @arg BUTTON_2: Push2 button
 * @retval FlagStatus: error status of the button @ref FlagStatus
 *         This parameter can be: SET or RESET.
 */
FlagStatus SdkEvalPushButtonGetITPendingBit(SdkEvalButton xButton)
{
  return GPIO_GetITPendingBit(Get_ButtonGpioPin(xButton));
}


/**
 * @brief  Clear the pending bit state.
 * @param  xButton Specifies the Button to be configured, @ref SdkEvalButton
 *         This parameter can be one of following parameters:
 *         @arg BUTTON_1: Push1 button
 *         @arg BUTTON_2: Push2 button
 * @retval None
 */
void SdkEvalPushButtonClearITPendingBit(SdkEvalButton xButton)
{
  GPIO_ClearITPendingBit(Get_ButtonGpioPin(xButton));
}

/**
* @brief  GetButtonState
* @param  void
* @retval BUTTON_STATE returns the state of the button
*/
BUTTON_STATE GetButtonState(void)
{
    return SdkEvalPushButtonGetState(OFF_PWR_BUTTON);
}

static void Appli_ShortButtonPress(void)
{

    printf("This is Test for ShortButtonPress\r\n");

}

/**
* @brief  Updates the button status
* @param  int isPressed
* @retval void
*/
 static void Appli_UpdateButtonState(int isPressed)
{
    /* Check for button state */
    switch (buttonState)
    {
    /* Case for Button State off */
    case BS_OFF:
        /* if button is pressed */
        if (isPressed)
        {
            buttonState = BS_DEBOUNCE;
            tBounce = Clock_Time();
        }
        break;

    /* Case for Button Debouncing */
    case BS_DEBOUNCE:
        if (isPressed)
        {
            /* Debouncing Delay check */
            if (Clock_Time() - tBounce > BOUNCE_THRESHOLD)
            {
                if (GetButtonState() == BUTTON_PRESSED)
                    buttonState = BS_SHORT_PRESS;
            }
            else
            {
                break;
            }
        }
        else
        {
            buttonState = BS_OFF;
            break;
        }
    /* Case if Button is pressed for small duration */
    case BS_SHORT_PRESS:
        if (isPressed && ((Clock_Time() - tBounce) > LONG_PRESS_THRESHOLD))
        {
            buttonState = BS_LONG_PRESS;
        }
        else
        {
            if (!isPressed)
            {
                Appli_ShortButtonPress();

            }
            break;
        }
    /* Case if Button is pressed for long duration */
    case BS_LONG_PRESS:
        /* Second Button handling in BlueNRG-1*/
        /*
        		if (GetButton2State() == BUTTON_PRESSED)
        {
            //SdkEvalLedOn(LED1);
            Appli_LongButtonPress();
        }*/
        //SdkEvalLedOff(EN_PWR_PIN);//按键时间大于1S，关闭设备
        printf("This is Long Button\r\n");
        SdkEvalLedFlicker(LED2_G);
        SdkEvalLedOff(EN_PWR);
		    SdkEvalLedOff(EN_PWR);
        SdkEvalLedOff(EN_PWR);
        break;
    /* Default case */
    default:
        buttonState = BS_OFF;
        break;
    }
    if (!isPressed)
    {
        buttonState = BS_OFF;
    }
}

/**
* @brief  Application processing
*         This function should be called in main loop
* @param  void
* @retval void
*/
void Appli_Process(void)
{
    Appli_UpdateButtonState(GetButtonState() == BUTTON_PRESSED);
}



/**
 * @}
 */


/**
 * @}
 */


/**
 * @}
 */


/******************* (C) COPYRIGHT 2015 STMicroelectronics *****END OF FILE****/
