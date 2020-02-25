/**
******************************************************************************
* @file    appli_light.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   Application interface for Lighting Mesh Models 
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
#include "light.h"
#include "appli_light.h"
#include "appli_generic.h"
#include "common.h"
#include "mesh_cfg.h"
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
/* Private variables ---------------------------------------------------------*/
   
/* Light Lightness set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 PresentState16; 
  MOBLEUINT16 LastLightness16;
}Appli_Light_lightnessSet;

Appli_Light_lightnessSet ApplilightnessSet;

/* Light Lightness Linear set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 PresentState16;
}Appli_Light_lightnessLinearSet;

Appli_Light_lightnessLinearSet ApplilightnessLinearSet;

/* Light Lightness Default set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 LightnessDefault;
}Appli_Light_lightnessDefaultSet;

Appli_Light_lightnessDefaultSet ApplilightnessDefaultSet;

/* Light Lightness Range set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT8  StatusCode;
  MOBLEUINT16 RangeMin;     
  MOBLEUINT16 RangeMax;
}Appli_Light_lightnessRangeSet;

Appli_Light_lightnessRangeSet ApplilightnessRangeSet = {0x00,0x01,0xFFFF};

/* Light Ctl Set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 PresentLightness16;
  MOBLEUINT16 PresentTemperature16;
  MOBLEINT16 PresentCtlDelta16;
}Appli_Light_CtlSet;

Appli_Light_CtlSet AppliCtlSet;

#ifndef PTS_TEST_VALUE_SET 
Appli_Light_CtlSet AppliCtlSet = {0x00 , 0x0320 , 0x7FFE};
#endif

/* Light Ctl Temperature Range Set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT8  StatusCode;
  MOBLEUINT16 RangeMin;     
  MOBLEUINT16 RangeMax;
}Appli_Light_CtlTemperatureRangeSet;

Appli_Light_CtlTemperatureRangeSet AppliCtlTemperatureRangeSet;

#ifndef PTS_TEST_VALUE_SET 
Appli_Light_CtlTemperatureRangeSet AppliCtlTemperatureRangeSet = {0x00,0x0320,0x4E20};
#endif

/* Light Ctl Default set */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 CtlDefaultLightness16;
  MOBLEUINT16 CtlDefaultTemperature16;
  MOBLEINT16 CtlDefaultDeltaUv;    
}Appli_Light_CtlDefaultSet;

Appli_Light_CtlDefaultSet AppliCtlDefaultSet;

MOBLEUINT8 OptionalLightParam = 0;
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
* @brief  Appli_Light_Lightness_Set: This function is callback for Application
           when Light Lightness Set message is received
* @param  pLight_LightnessParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_Lightness_Set(Light_LightnessStatus_t* pLight_LightnessParam,
                                     MOBLEUINT8 OptionalValid)
{
  ApplilightnessSet.PresentState16 = pLight_LightnessParam->PresentValue16;
  
  if(pLight_LightnessParam->PresentValue16 != 0x00)
  {
    ApplilightnessSet.LastLightness16 = pLight_LightnessParam->PresentValue16;
  }
               
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_Lightness_Linear_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_LightnessLinearParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_Lightness_Linear_Set(Light_LightnessStatus_t* pLight_LightnessLinearParam,
                                     MOBLEUINT8 OptionalValid)
{
  ApplilightnessLinearSet.PresentState16 = pLight_LightnessLinearParam->PresentValue16; 
  
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_Lightness_Default_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_LightnessDefaultParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_Lightness_Default_Set(Light_LightnessDefaultParam_t* pLight_LightnessDefaultParam,
                                     MOBLEUINT8 OptionalValid)
{
  SetLed(pLight_LightnessDefaultParam->LightnessDefaultStatus);
  ApplilightnessDefaultSet.LightnessDefault = pLight_LightnessDefaultParam->LightnessDefaultStatus;
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_Lightness_Range_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_LightnessRangeParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_Lightness_Range_Set(Light_LightnessRangeParam_t* pLight_LightnessRangeParam,
                                     MOBLEUINT8 OptionalValid)
{
  ApplilightnessRangeSet.StatusCode = pLight_LightnessRangeParam->StatusCode;
  ApplilightnessRangeSet.RangeMin = pLight_LightnessRangeParam->MinRangeStatus; 
  ApplilightnessRangeSet.RangeMax = pLight_LightnessRangeParam->MaxRangeStatus;
 
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_Ctl_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_CtlParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_Ctl_Set(Light_CtlStatus_t* pLight_CtlParam,
                                     MOBLEUINT8 OptionalValid)
{
  MOBLEINT16 duty;
  MOBLEINT16 duty1;
  AppliCtlSet.PresentLightness16  = pLight_CtlParam->PresentCtlLightness16;
  AppliCtlSet.PresentTemperature16 = pLight_CtlParam->PresentCtlTemperature16;
  //MFT_Cmd(MFT2, ENABLE);//modify 20181022
  duty = PwmValueMapping(AppliCtlSet.PresentLightness16 ,0XFFFF ,0);      
  Modify_PWM(2, duty); 
  duty1 = PwmValueMapping(AppliCtlSet.PresentTemperature16 ,0x4E20 ,0x0320);      
  Modify_PWM(2, duty1); 

  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_CtlTemperature_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_CtltempParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_CtlTemperature_Set(Light_CtlStatus_t* pLight_CtltempParam,
                                     MOBLEUINT8 OptionalValid)
{
  MOBLEINT16 duty; 
  AppliCtlSet.PresentTemperature16 = pLight_CtltempParam->PresentCtlTemperature16;
  AppliCtlSet.PresentCtlDelta16 = pLight_CtltempParam->PresentCtlDelta16;
   //MFT_Cmd(MFT2, ENABLE);//modify 20181022
   duty = PwmValueMapping(AppliCtlSet.PresentTemperature16 ,0x4E20 ,0x0320); 
   Modify_PWM(2, duty); 
 
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_CtlTemperature_Range_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_CtlTempRangeParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_CtlTemperature_Range_Set(Light_CtlTemperatureRangeParam_t* pLight_CtlTempRangeParam,
                                     MOBLEUINT8 OptionalValid)
{
  AppliCtlTemperatureRangeSet.RangeMin = pLight_CtlTempRangeParam->MinRangeStatus; 
  AppliCtlTemperatureRangeSet.RangeMax = pLight_CtlTempRangeParam->MaxRangeStatus;
  AppliCtlTemperatureRangeSet.StatusCode = pLight_CtlTempRangeParam->StatusCode;
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_CtlDefault_Set: This function is callback for Application
           when Light Lightness Linear Set message is received
* @param  pLight_CtlDefaultParam: Pointer to the parameters received for message
* @param  OptionalValid: Flag to inform about the validity of optional parameters 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_CtlDefault_Set(Light_CtlDefaultParam_t* pLight_CtlDefaultParam,
                                     MOBLEUINT8 OptionalValid)
{
  AppliCtlDefaultSet.CtlDefaultLightness16 = pLight_CtlDefaultParam->CtlDefaultLightness16; 
  AppliCtlDefaultSet.CtlDefaultTemperature16 = pLight_CtlDefaultParam->CtlDefaultTemperature16;
  AppliCtlDefaultSet.CtlDefaultDeltaUv = pLight_CtlDefaultParam->CtlDefaultDeltaUv;
  return MOBLE_RESULT_SUCCESS;
} 

/**
* @brief  Appli_Light_GetLightnessStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lLightnessState: Pointer to the status message
* @retval MOBLE_RESULT
*/  
MOBLE_RESULT Appli_Light_GetLightnessStatus(MOBLEUINT8* lLightnessState)
{
    *(lLightnessState) = ApplilightnessSet.PresentState16;
    *(lLightnessState+1) = ApplilightnessSet.PresentState16 >> 8;
    *(lLightnessState+2) = ApplilightnessSet.LastLightness16 ;
    *(lLightnessState+3) = ApplilightnessSet.LastLightness16 >> 8;
    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_GetLightnessLinearStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lLightnessState: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetLightnessLinearStatus(MOBLEUINT8* lLightnessState)
{
    *(lLightnessState) = ApplilightnessLinearSet.PresentState16;
    *(lLightnessState+1) = ApplilightnessLinearSet.PresentState16 >> 8;
    *(lLightnessState+2) = ApplilightnessSet.LastLightness16 ;
    *(lLightnessState+3) = ApplilightnessSet.LastLightness16 >> 8;
    return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  Appli_Light_GetLightnessDefaultStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lDefaultState: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetLightnessDefaultStatus(MOBLEUINT8* lDefaultState)
{
    *(lDefaultState) = ApplilightnessDefaultSet.LightnessDefault;
    *(lDefaultState+1) = ApplilightnessDefaultSet.LightnessDefault >> 8;

    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_GetLightnessRangeStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lRangeState: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetLightnessRangeStatus(MOBLEUINT8* lRangeState)
{
    *(lRangeState) = ApplilightnessRangeSet.StatusCode;
    *(lRangeState+1) = ApplilightnessRangeSet.RangeMin;
    *(lRangeState+2) = ApplilightnessRangeSet.RangeMin >> 8;
    *(lRangeState+3) = ApplilightnessRangeSet.RangeMax;
    *(lRangeState+4) = ApplilightnessRangeSet.RangeMax >> 8;

    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Light_GetCtlLightStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lCtlLightState: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetCtlLightStatus(MOBLEUINT8* lCtlLightState)
{
    *(lCtlLightState) = AppliCtlSet.PresentLightness16;
    *(lCtlLightState+1) = AppliCtlSet.PresentLightness16 >> 8;
    *(lCtlLightState+2) = AppliCtlSet.PresentTemperature16;
    *(lCtlLightState+3) = AppliCtlSet.PresentTemperature16 >>8;
    return MOBLE_RESULT_SUCCESS;
}  

/**
* @brief  Appli_Light_GetCtlTeperatureStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lCtlTempState: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetCtlTemperatureStatus(MOBLEUINT8* lCtlTempState)
{
    *(lCtlTempState) = AppliCtlSet.PresentTemperature16;
    *(lCtlTempState+1) = AppliCtlSet.PresentTemperature16 >> 8;
    *(lCtlTempState+2) = AppliCtlSet.PresentCtlDelta16;
    *(lCtlTempState+3) = AppliCtlSet.PresentCtlDelta16 >>8;
    return MOBLE_RESULT_SUCCESS;
}  

/**
* @brief  Appli_Light_GetCtlTempRange: This function is callback for Application
          application values used in middelware for transition change.
* @param  lCtlTempRange: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetCtlTempRange(MOBLEUINT8* lCtlTempRange)
{   
    *(lCtlTempRange) = AppliCtlTemperatureRangeSet.StatusCode;
    *(lCtlTempRange+1) = AppliCtlTemperatureRangeSet.RangeMin;
    *(lCtlTempRange+2) = AppliCtlTemperatureRangeSet.RangeMin >> 8;
    *(lCtlTempRange+3) = AppliCtlTemperatureRangeSet.RangeMax;
    *(lCtlTempRange+4) = AppliCtlTemperatureRangeSet.RangeMax >>8;
    return MOBLE_RESULT_SUCCESS;
}  

/**
* @brief  Appli_Light_GetCtlDefaultStatus: This function is callback for Application
          application values used in middelware for transition change.
* @param  lCtlDefaultState: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Light_GetCtlDefaultStatus(MOBLEUINT8* lCtlDefaultState)
{
    *(lCtlDefaultState) = AppliCtlDefaultSet.CtlDefaultLightness16;
    *(lCtlDefaultState+1) = AppliCtlDefaultSet.CtlDefaultLightness16 >> 8;
    *(lCtlDefaultState+2) = AppliCtlDefaultSet.CtlDefaultTemperature16;
    *(lCtlDefaultState+3) = AppliCtlDefaultSet.CtlDefaultTemperature16 >>8;
    *(lCtlDefaultState+4) = AppliCtlDefaultSet.CtlDefaultDeltaUv;
    *(lCtlDefaultState+5) = AppliCtlDefaultSet.CtlDefaultDeltaUv >>8;
    return MOBLE_RESULT_SUCCESS;
}  
/**
 * @}
 */

/**
 * @}
 */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

