/**
******************************************************************************
* @file    appli_generic.c
* @author  BLE Mesh Team
* @version V1.09.000
* @date    15-Oct-2018
* @brief   Application interface for Generic Mesh Models 
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
* Initial BlueNRG-Mesh is built over Motorola’s Mesh over Bluetooth Low Energy 
* (MoBLE) technology. The present solution is developed and maintained for both 
* Mesh library and Applications solely by STMicroelectronics.
*
******************************************************************************
*/

/* Includes ------------------------------------------------------------------*/
#include "hal_common.h"
#include "types.h"
#include "bluenrg_mesh.h"
#include "appli_mesh.h"
#include "mesh_cfg.h"
#include "generic.h"
#include "light.h"
#include "appli_generic.h"
#include "common.h"
#include "PWM_handlers.h"
#include "PWM_config.h"
/** @addtogroup BlueNRG_Mesh
 *  @{
 */

/** @addtogroup models_BlueNRG1
 *  @{
 */

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
#define POWER_OFF_STATE       0X02
#define POWER_ON_STATE        0X01
#define POWER_RESTORE_STATE   0X02
   
/* Private variables ---------------------------------------------------------*/
 

MOBLEUINT8 OptionalValidParam = 0;
MOBLEUINT8 LEDState;
MOBLEUINT8 StatusCode;

#pragma pack(1)
typedef struct
{
  MOBLEUINT8 Present_OnOff;
}Appli_Generic_OnOffSet;

Appli_Generic_OnOffSet AppliOnOffSet;

#pragma pack(1)
typedef struct
{
  MOBLEINT16 Present_Level16; 
}Appli_Generic_LevelSet;

Appli_Generic_LevelSet AppliLevelSet;


/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

#ifdef ENABLE_GENERIC_MODEL_SERVER_ONOFF
/**
* @brief  Appli_Generic_OnOff_Set: This function is callback for Application
           when Generic OnOff message is received
* @param  pGeneric_OnOffParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_OnOff_Set(Generic_OnOffStatus_t* pGeneric_OnOffParam, 
                                     MOBLEUINT8 OptionalValid)
{ 
    AppliOnOffSet.Present_OnOff = pGeneric_OnOffParam->Present_OnOff;    
    SetLed(AppliOnOffSet.Present_OnOff);
    if(AppliOnOffSet.Present_OnOff == 1)
    {
      Modify_PWM(PWM4, (PWM_TIME_PERIOD/2));   /* PWM_ID = PWM2, mapped on PWM2_PIN (GPIO_1 in mapping */
      Modify_PWM(PWM1, (PWM_TIME_PERIOD/2));   /* PWM_ID = PWM2, mapped on PWM2_PIN (GPIO_3 in mapping */
    }
    else
    {
      Modify_PWM(PWM4, 0);    /* PWM_ID = PWM2, mapped on PWM2_PIN (GPIO_1 in mapping */
      Modify_PWM(PWM1, 0);   /* PWM_ID = PWM2, mapped on PWM2_PIN (GPIO_3 in mapping */
    }

    return MOBLE_RESULT_SUCCESS;
}
#endif


#ifdef ENABLE_GENERIC_MODEL_SERVER_LEVEL
/**
* @brief  Appli_Generic_Level_Set: This function is callback for Application
           when Generic Level message is received
* @param  plevelParam: Pointer to the parameters message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_Level_Set(Generic_LevelStatus_t* plevelParam, 
                                     MOBLEUINT8 OptionalValid)
{
    uint16_t duty; 
  AppliLevelSet.Present_Level16= plevelParam->Present_Level16;   
    
  /* For demo, if Level is more than 100, switch ON the LED */
  
  /* increment of 20 percent at each level */
   duty = PwmValueMapping(AppliLevelSet.Present_Level16 , 0x7FFF ,0); 
     
   Modify_PWM(PWM2, duty);  /* PWM_ID = PWM2, mapped on PWM2_PIN (GPIO_6 in mapping */

  return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  Appli_Generic_LevelDelta_Set: This function is callback for Application
           when Generic Level Delta message is received
* @param  pdeltalevelParam: Pointer to the parameters message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_LevelDelta_Set(Generic_LevelStatus_t* pdeltalevelParam, 
                                     MOBLEUINT8 OptionalValid)
{
      
  AppliLevelSet.Present_Level16 = pdeltalevelParam->Present_Level16;
     
  /* For demo, if Level is more than 50, switch ON the LED */
  if (AppliLevelSet.Present_Level16 >= 50)
  {
    SetLed(1);
     LEDState = 1; 
  }
  else
  {
    SetLed(0);
     LEDState = 1; 
  }
  return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  Appli_Generic_LevelMove_Set: This function is callback for Application
           when Generic Level Move message is received
* @param  pdeltaMoveParam: Pointer to the parameters message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_LevelMove_Set(Generic_LevelStatus_t* pdeltaMoveParam, 
                                               MOBLEUINT8 OptionalValid)
{
     
    if(OptionalValid == 1)
    {
      AppliLevelSet.Present_Level16= pdeltaMoveParam->Present_Level16;   
      
      OptionalValidParam = 1;
    }
    return MOBLE_RESULT_SUCCESS;
}

#endif


/**
* @brief  Appli_Generic_GetOnOffState: This function is callback for Application
           when Generic on off status message is to be provided
* @param  pOnOff_status: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_GetOnOffStatus(MOBLEUINT8* pOnOff_Status)                                        
{
  
   *pOnOff_Status = AppliOnOffSet.Present_OnOff;
  
  return MOBLE_RESULT_SUCCESS; 
}


/**
* @brief  Appli_Generic_GetLevelStatus: This function is callback for Application
           when Generic Level status message is to be provided
* @param  pLevel_status: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_GetLevelStatus(MOBLEUINT8* pLevel_Status) 
                                        
{ 
   *pLevel_Status = AppliLevelSet.Present_Level16;
   *(pLevel_Status+1) = AppliLevelSet.Present_Level16 >> 8;
  
  return MOBLE_RESULT_SUCCESS; 
}
                                        
/**
 * @}
 */

/**
 * @}
 */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

