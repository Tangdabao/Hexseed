/**
******************************************************************************
* @file    light.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   User Application file 
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
#include "mesh_cfg.h"
#include "light.h"
#include "generic.h"
#include "bluenrg_mesh.h"
#include "common.h"
#include "Math.h"
#include "mesh_cfg.h"

#ifndef STM32
#include <bluenrg1_config.h>
#endif
#include <string.h>
/** @addtogroup MODEL_Light
*  @{
*/

/** @addtogroup Light_Model_Callbacks
*  @{
*/

/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
static Light_TimeParam_t Light_TimeParam;
static Light_ModelFlag_t Light_ModelFlag;
static Light_TemporaryStatus_t Light_TemporaryStatus;

static Light_LightnessParam_t Light_LightnessParam;
static Light_LightnessStatus_t Light_LightnessStatus;
static Light_LightnessDefaultParam_t Light_LightnessDefaultParam;
static Light_LightnessRangeParam_t Light_LightnessRangeParam ;

static Light_CtlParam_t Light_CtlParam;
static Light_CtlStatus_t Light_CtlStatus;
static Light_CtlDefaultParam_t Light_CtlDefaultParam;

static Light_CtlTemperatureRangeParam_t CtlTemperatureRangeParam;

const MODEL_OpcodeTableParam_t Light_Opcodes_Table[] = {

    {LIGHT_LIGHTNESS_GET,                 MOBLE_TRUE,  0, 0, LIGHT_LIGHTNESS_STATUS,        2, 5},
    {LIGHT_LIGHTNESS_SET,                 MOBLE_TRUE,  3, 5, LIGHT_LIGHTNESS_STATUS,        2, 5},
    {LIGHT_LIGHTNESS_SET_UNACK,           MOBLE_FALSE, 3, 5, NULL,                          0, 0},
    {LIGHT_LIGHTNESS_STATUS,              MOBLE_TRUE, 2, 5,  LIGHT_LIGHTNESS_STATUS,        2, 5},
    {LIGHT_LIGHTNESS_LINEAR_GET,          MOBLE_TRUE,  0, 0, LIGHT_LIGHTNESS_LINEAR_STATUS, 2, 5},
    {LIGHT_LIGHTNESS_LINEAR_SET,          MOBLE_TRUE,  3, 5, LIGHT_LIGHTNESS_LINEAR_STATUS, 2, 5},
    {LIGHT_LIGHTNESS_LINEAR_SET_UNACK,    MOBLE_FALSE, 3, 5, NULL,                          0, 0},
    {LIGHT_LIGHTNESS_LINEAR_STATUS,       MOBLE_TRUE, 2, 5,  LIGHT_LIGHTNESS_LINEAR_STATUS, 2, 5},
    {LIGHT_LIGHTNESS_LAST_GET,            MOBLE_TRUE,  0, 0, LIGHT_LIGHTNESS_LAST_STATUS,   2, 2},
    {LIGHT_LIGHTNESS_LAST_STATUS,         MOBLE_TRUE, 2, 2,  LIGHT_LIGHTNESS_LAST_STATUS,   2, 2},
    {LIGHT_LIGHTNESS_DEFAULT_GET,         MOBLE_TRUE,  0, 0, LIGHT_LIGHTNESS_DEFAULT_STATUS,2, 2},
    {LIGHT_LIGHTNESS_DEFAULT_STATUS,      MOBLE_TRUE, 2, 2,  LIGHT_LIGHTNESS_DEFAULT_STATUS,2, 5},
    {LIGHT_LIGHTNESS_RANGE_GET,           MOBLE_TRUE,  0, 0, LIGHT_LIGHTNESS_RANGE_STATUS,  5, 5},
    {LIGHT_LIGHTNESS_RANGE_STATUS,        MOBLE_TRUE, 2, 5, LIGHT_LIGHTNESS_RANGE_STATUS,  5, 5},

#ifdef ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS_SETUP     
    {LIGHT_LIGHTNESS_DEFAULT_SET,         MOBLE_TRUE, 2, 2, LIGHT_LIGHTNESS_DEFAULT_STATUS,  2, 2},                 
    {LIGHT_LIGHTNESS_DEFAULT_SET_UNACK,   MOBLE_FALSE, 2, 2, LIGHT_LIGHTNESS_DEFAULT_STATUS, 2, 2},    
    {LIGHT_LIGHTNESS_RANGE_SET,           MOBLE_TRUE, 2, 4, LIGHT_LIGHTNESS_RANGE_STATUS,  5, 5},    
    {LIGHT_LIGHTNESS_RANGE_SET_UNACK,     MOBLE_FALSE, 2, 4, LIGHT_LIGHTNESS_RANGE_STATUS,  5, 5}, 
#endif 
#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL    
    {LIGHT_CTL_GET,                        MOBLE_TRUE, 0, 0,  LIGHT_CTL_STATUS,  4, 9},     
    {LIGHT_CTL_SET,                        MOBLE_TRUE, 7, 9,  LIGHT_CTL_STATUS,  4, 9},     
    {LIGHT_CTL_SET_UNACK,                  MOBLE_FALSE, 7, 9, NULL,  4, 9},     
    {LIGHT_CTL_STATUS,                     MOBLE_TRUE, 4, 9,  LIGHT_CTL_STATUS,  4, 9},      
    {LIGHT_CTL_TEMPERATURE_RANGE_GET,      MOBLE_TRUE, 0, 0,  LIGHT_CTL_TEMPERATURE_RANGE_STATUS,  5, 5},
    {LIGHT_CTL_TEMPERATURE_RANGE_STATUS,   MOBLE_TRUE, 5, 5,  LIGHT_CTL_TEMPERATURE_RANGE_STATUS,  5, 5},
    {LIGHT_CTL_DEFAULT_GET,                MOBLE_TRUE, 0, 0,  LIGHT_CTL_DEFAULT_STATUS,  6, 6},   
    {LIGHT_CTL_DEFAULT_STATUS,             MOBLE_TRUE, 6, 6,  LIGHT_CTL_DEFAULT_STATUS,  6, 6},
#endif
#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL_SETUP 
    {LIGHT_CTL_DEFAULT_SET,                MOBLE_TRUE, 6, 6,  LIGHT_CTL_DEFAULT_STATUS,  6, 6},   
    {LIGHT_CTL_DEFAULT_SET_UNACK,          MOBLE_FALSE, 6, 6, LIGHT_CTL_DEFAULT_STATUS,  6, 6}, 
    {LIGHT_CTL_TEMPERTATURE_RANGE_SET,     MOBLE_TRUE, 4, 4,  LIGHT_CTL_TEMPERATURE_RANGE_STATUS,     5, 5},   
    {LIGHT_CTL_TEMPERTATURE_RANGE_SET_UNACK,  MOBLE_FALSE, 4, 4, LIGHT_CTL_TEMPERATURE_RANGE_STATUS,  5, 5},
    
#endif  
#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL_TEMPERATURE  
    {LIGHT_CTL_TEMPERATURE_GET,            MOBLE_TRUE, 0, 0,  LIGHT_CTL_TEMPERTAURE_STATUS,        4, 9},
    {LIGHT_CTL_TEMPERATURE_SET,            MOBLE_TRUE, 5, 7,  LIGHT_CTL_TEMPERTAURE_STATUS,        4, 9},
    {LIGHT_CTL_TEMPERATURE_SET_UNACK,      MOBLE_FALSE, 5, 7, LIGHT_CTL_TEMPERTAURE_STATUS,        4, 9},
    {LIGHT_CTL_TEMPERTAURE_STATUS ,        MOBLE_TRUE, 4, 9,  LIGHT_CTL_TEMPERTAURE_STATUS,        4, 9},
#endif       

};

/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
* @brief  Light_Lightness_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library
* @param  plightness_param : Pointer to the parameters received for message
* @param  length : Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Set(const MOBLEUINT8* plightness_param, MOBLEUINT32 length)
{
  /* 6.3.1.2 Light Lightness Set
  
  Lightness             2B The target value of the Light Lightness Actual state. 
  TID                   1B Transaction Identifier
  Transition Time       1B Format as defined in Section 3.1.3. (Optional)
  Delay                 1B Message execution delay in 5 millisecond steps (C.1)
  */
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Set callback received \r\n");
#endif  
   Light_LightnessParam.TargetLightnessStatus = (plightness_param[0] | plightness_param[1] << 8);
   Light_LightnessParam.TID = plightness_param[2];
   
    /* Binding of actual lightness value with lightness range */
    Light_Actual_RangeBinding(&Light_LightnessParam);
   /* Check for Optional Parameters */ 
  if (length > 3)
  {
    /* Transition_Time & Delay_Time Present */
    Light_LightnessParam.TransitionTime = plightness_param[3];
    Light_LightnessParam.Delay_Time = plightness_param[4]; 
    
    /* Copy the received data in status message which needs
       to be set in application messages */  
    Light_LightnessStatus.TargetValue16 = Light_LightnessParam.TargetLightnessStatus;
    Light_LightnessStatus.RemainingTime = Light_LightnessParam.TransitionTime;
    
    /* copy status parameters in Temporary parameters for transition 
       process.
    */
    Light_TemporaryStatus.TargetParam_1 = Light_LightnessStatus.TargetValue16;    
    Light_TemporaryStatus.RemainingTime = Light_LightnessStatus.RemainingTime;
    
    /* Function to calculate time parameters, step resolution
        step size for transition state machine.
     */
    Light_GetStepValue(plightness_param[3]);
    /*option parameter flag, enable to sent all required parameter in status.*/
    Light_ModelFlag.LightTransitionFlag = 1;  
    Light_ModelFlag.LightOptionalParam = 1;
  }
  else
  {
    /* When no optional parameter received, target value will
         be set as present value in application.
    */
    Light_LightnessStatus.PresentValue16 = Light_LightnessParam.TargetLightnessStatus;   
  }
    /* Application Callback */
   (LightAppli_cb.Lightness_Set_cb)(&Light_LightnessStatus, 0);
   
    /* Binding of actual light lightness with linear light lightness */
    Light_Linear_ActualImplicitBinding(BINDING_LIGHT_LIGHTNESS_ACTUAL_SET);
    
    /* Binding of Light Ctl with Actual Light Lightness */
    Light_BindingCtlToLightness_Actual(BINDING_LIGHT_LIGHTNESS_ACTUAL_SET);
    
    /* Binding of data b/w light lightness actual and Generic on off */
    LightActual_GenericOnOffBinding(&Light_LightnessParam);
    
    /* Binding of data b/w light lightness actual and Generic Level */
    LightActual_GenericLevelBinding(&Light_LightnessParam);
     
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light Lightness Status
* @param  pLightness_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Status(MOBLEUINT8* pLightness_status, MOBLEUINT32* pLength)
{
  /* 
  Following is the status message:
  Present Lightness     1B The present value of the Generic OnOff state. 
  Target Lightness      1B The target value of the Generic OnOff state (optional).
  Remaining Time        1B Time to complete the transition to the target Light Lightness
  
  */ 
    MOBLEUINT8 Light_GetBuff[2];
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Status callback received \r\n");
#endif
  
    /* reading the value from the application by passing Appli_LightParam
       array parameter 
    */    
     (Appli_Light_GetStatus_cb.GetLightLightness_cb)(Light_GetBuff);
     
     Light_LightnessStatus.PresentValue16 = Light_GetBuff[1] << 8;
     Light_LightnessStatus.PresentValue16 |= Light_GetBuff[0];
  
    /* This condition will be processed when message received will have
       transition time and delay parameter.
       or the transition will be in process
     */
    if((Light_ModelFlag.LightOptionalParam == 1) || (Light_TimeParam.StepValue != 0))
   {
      *(pLightness_status) = Light_LightnessStatus.PresentValue16;
      *(pLightness_status+1) = Light_LightnessStatus.PresentValue16 >> 8;
      *(pLightness_status+2) = Light_LightnessStatus.TargetValue16;
      *(pLightness_status+3) = Light_LightnessStatus.TargetValue16 >>8;
      *(pLightness_status+4) = Light_LightnessStatus.RemainingTime;
      *pLength = 5;     
      Light_ModelFlag.LightOptionalParam = 0;    
   }
  else
  {    
      /* When no optional parameter received then, target value will
         be sent in status message.
      */    
      *(pLightness_status) = Light_LightnessStatus.PresentValue16 ;
      *(pLightness_status+1) = Light_LightnessStatus.PresentValue16 >> 8;
      *pLength = 2;          
  }
  
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_Lightness_Linear_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library
* @param  plightnessLinear_param : Pointer to the parameters received for message
* @param  length : Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Linear_Set(const MOBLEUINT8* plightnessLinear_param, MOBLEUINT32 length)
{
  /* 6.3.1.6 Light Lightness Linear Set
  
  Lightness             2B The target value of the Light Lightness Actual state. 
  TID                   1B Transaction Identifier
  Transition Time       1B Format as defined in Section 3.1.3. (Optional)
  Delay                 1B Message execution delay in 5 millisecond steps (C.1)
  */
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Linear_Set callback received \r\n");
#endif  
  
  MOBLEUINT8 OptionalValid = 0;
  
  Light_LightnessParam.TargetLightnessLinearStatus = ((plightnessLinear_param[0])
                                                      | (plightnessLinear_param[1] << 8));
  Light_LightnessParam.TID = plightnessLinear_param[2];
  
  /* Check for Optional Parameters */ 
  if (length > 3)
  {
    /* Transition_Time & Delay_Time Present */
    Light_LightnessParam.TransitionTime = plightnessLinear_param[3];
    Light_LightnessParam.Delay_Time = plightnessLinear_param[4]; 
    
    /* Copy the received data in status message which needs
       to be set in application messages */
    Light_LightnessStatus.TargetValue16 = Light_LightnessParam.TargetLightnessLinearStatus;
    Light_LightnessStatus.RemainingTime = Light_LightnessParam.TransitionTime;
    /* copy status parameters in Temporary parameters for transition 
       process.
    */
    Light_TemporaryStatus.TargetParam_1 = Light_LightnessStatus.TargetValue16;    
    Light_TemporaryStatus.RemainingTime = Light_LightnessStatus.RemainingTime;
    /* Function to calculate time parameters, step resolution
        step size for transition state machine.
    */
    Light_GetStepValue(plightnessLinear_param[3]);
    /*transition process enable flag. */
    Light_ModelFlag.LightTransitionFlag = 2; 
    /*option parameter flag, enable to sent all required parameter in status.*/
    Light_ModelFlag.LightOptionalParam = 1;
  }
  else
  {
    Light_LightnessStatus.PresentValue16 = Light_LightnessParam .TargetLightnessLinearStatus;   
  }

    /* Application Callback */
   (LightAppli_cb.Lightness_Linear_Set_cb)(&Light_LightnessStatus, OptionalValid);
    /* Binding of data of light lightness with light linear */
    Light_Linear_ActualImplicitBinding(BINDING_LIGHT_LIGHTNESS_LINEAR_SET);
  return MOBLE_RESULT_SUCCESS;
}
/**
* @brief  Light Lightness Linear Status
* @param  pLightnessLinear_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Linear_Status(MOBLEUINT8* pLightnessLinear_status, MOBLEUINT32 *pLength)
{
  /* 
  Following is the status message:
  Present Lightness     2B The present value of the Light Lightness Linear state. 
  Target Lightness      2B The target value of the Light Lightness Linear state (Optional).
  Remaining Time        1B Time to complete the transition to the target Light Lightness Li
  */
    MOBLEUINT8 Light_GetBuff[2];
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Linear_Status callback received \r\n");
#endif
      /* reading the value from the application by passing Appli_LightParam
       array parameter 
    */   
     (Appli_Light_GetStatus_cb.GetLightLightnessLinear_cb)(Light_GetBuff);
      Light_LightnessStatus.PresentValue16 = Light_GetBuff[1] << 8;
      Light_LightnessStatus.PresentValue16 |= Light_GetBuff[0];
      
       /* This condition will be processed when message received will have
       transition time and delay parameter.
       or the transition will be in process
     */
  if((Light_ModelFlag.LightOptionalParam == 1) || (Light_TimeParam.StepValue != 0))
   {
      *(pLightnessLinear_status) = Light_LightnessStatus.PresentValue16;
      *(pLightnessLinear_status+1) = Light_LightnessStatus.PresentValue16 >> 8;
      *(pLightnessLinear_status+2) = Light_LightnessStatus.TargetValue16;
      *(pLightnessLinear_status+3) = Light_LightnessStatus.TargetValue16 >>8;
      *(pLightnessLinear_status+4) = Light_LightnessStatus.RemainingTime;
      *pLength = 5;
      
      Light_ModelFlag.LightOptionalParam = 0U;          
   }
   else
   { 
     /* When no optional parameter received then, target value will
         be sent in status message.
     */
    *(pLightnessLinear_status) = Light_LightnessStatus.PresentValue16;
    *(pLightnessLinear_status+1) = Light_LightnessStatus.PresentValue16 >> 8;
    *pLength = 2;
     
   }
  
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light Lightness Last Status
* @param  pLightnessLast_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Last_Status(MOBLEUINT8* pLightnessLast_status, MOBLEUINT32 *pLength)
{
  /* 6.3.1.10 Light Lightness Last State
  Following is the status message:
  Lightness     2B The value of the Light Lightness Last. 
  */
    MOBLEUINT8 Light_GetBuff[4];
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Last_Status callback received \r\n");
#endif
    /* Function call back to get the values from application*/
    (Appli_Light_GetStatus_cb.GetLightLightness_cb)(Light_GetBuff);
    
    *pLightnessLast_status = Light_GetBuff[2] ;
    *(pLightnessLast_status+1) = Light_GetBuff [3];
    *pLength = 2;
   
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_Lightness_Default_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library
* @param  plightnessDefault_param : Pointer to the parameters received for message
* @param  length : Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Default_Set(const MOBLEUINT8* plightnessDefault_param, MOBLEUINT32 length)
{
  /* 6.3.1.12 Light Default Lightness Set
  Lightness   2B The target value of the Light Lightness Actual state. 
  */
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Default_Set callback received \r\n");
#endif  
  
    MOBLEUINT8 OptionalValid = 0;
    
    Light_LightnessDefaultParam.LightnessDefaultStatus = plightnessDefault_param[1] << 8;
    Light_LightnessDefaultParam.LightnessDefaultStatus |= plightnessDefault_param[0];
    
    /* Application Callback */
    (LightAppli_cb.Lightness_Default_Set_cb)(&Light_LightnessDefaultParam, OptionalValid);
    return MOBLE_RESULT_SUCCESS;
}
/**
* @brief  Light Lightness Default Status
* @param  pLightnessDefault_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Default_Status(MOBLEUINT8* pLightnessDefault_status, MOBLEUINT32 *pLength)
{
  /* 
  Following is the status message:
  Lightness     2B The value of the Light Lightness Default state. 
  */
    MOBLEUINT8 Light_GetBuff[2];
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Default_Status callback received \r\n");
#endif
     /* Function call back to get the values from application*/
    (Appli_Light_GetStatus_cb.GetLightLightnessDefault_cb)(Light_GetBuff);
    *pLightnessDefault_status = Light_GetBuff[0] ;
    *(pLightnessDefault_status+1) = Light_GetBuff[1];
    *pLength = 2;
   
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_Lightness_Range_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library
* @param  plightnessRange_param : Pointer to the parameters received for message
* @param  length : Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Range_Set(const MOBLEUINT8* plightnessRange_param, MOBLEUINT32 length)
{
  /* 6.3.1.16 Light Lightness Range Set 
  Min Range    2B The Minimum range value of the Light Lightness state. 
  Max Range    2B The Maximum range value of the Light Lightness state         
  */
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Range_Set callback received \r\n");
#endif    
  MOBLEUINT8 OptionalValid = 0;
  
  Light_LightnessRangeParam.MinRangeStatus = plightnessRange_param[1] << 8;
  Light_LightnessRangeParam.MinRangeStatus |= plightnessRange_param[0];
  
  Light_LightnessRangeParam.MaxRangeStatus = plightnessRange_param[3] << 8;
  Light_LightnessRangeParam.MaxRangeStatus |= plightnessRange_param[2];
  Light_LightnessRangeParam.StatusCode = SUCCESS_STATUS_CODE;
  
  /* condition to check the minimum range value according to the specification*/
  /* set the status code for status message according to value of range*/  
  
#if !defined(DISABLE_TRACES)
 printf("Status code 0x%.2x , Min range 0x%.2x , Max range 0x%.2x  \r\n ",
         Light_LightnessRangeParam.StatusCode , Light_LightnessRangeParam.MinRangeStatus ,
                                   Light_LightnessRangeParam.MaxRangeStatus);
#endif  
  /* Application Callback */
  (LightAppli_cb.Lightness_Range_Set_cb)(&Light_LightnessRangeParam, OptionalValid);
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_Lightness_Range_Status
* @param  pLightnessRange_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Lightness_Range_Status(MOBLEUINT8* pLightnessRange_status, MOBLEUINT32 *pLength)
{
   /* 6.3.1.18 Light Lightness Range Status  
  Min Range      2B The Minimum range value of the Light Lightness state. 
  Max Range      2B The Maximum range value of the Light Lightness state         
  */
    MOBLEUINT8 Light_GetBuff[5];
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Range_Status callback received \r\n");
#endif
     /* Function call back to get the values from application*/
    (Appli_Light_GetStatus_cb.GetLightLightnessRange_cb)(Light_GetBuff);
    
    *(pLightnessRange_status) = Light_GetBuff[0];
    *(pLightnessRange_status+1) = Light_GetBuff[1];
    *(pLightnessRange_status+2) = Light_GetBuff[2];
    *(pLightnessRange_status+3) = Light_GetBuff[3];
    *(pLightnessRange_status+4) = Light_GetBuff[4];
    *pLength = 5;
   
    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CTL_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library
* @param  pLightCtl_param : Pointer to the parameters received for message
* @param  length : Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Ctl_Set(const MOBLEUINT8* pLightCtl_param, MOBLEUINT32 length)
{
  /* 6.3.2.2 Light Lightness Ctl Set
  
  Ctl Lightness         2B The target value of the Light Lightness Ctl state.
  Ctl Temperature       2B The target value of the Light Lightness Ctl state.
  Ctl Delta Uv          2B The target value of the Light Lightness Ctl state.
  TID                   1B Transaction Identifier
  Transition Time       1B Format as defined in Section 3.1.3. (Optional)
  Delay                 1B Message execution delay in 5 millisecond steps (C.1)
  */
#if !defined(DISABLE_TRACES)
  printf("Light_Ctl_Set callback received \r\n");
#endif   
  /* Received parameters from client */
  Light_CtlParam.CTL_Lightness    = pLightCtl_param[1] << 8;
  Light_CtlParam.CTL_Lightness   |= pLightCtl_param[0];
  Light_CtlParam.CTL_Temperature  = pLightCtl_param[3] << 8;
  Light_CtlParam.CTL_Temperature |= pLightCtl_param[2];
  Light_CtlParam.CTL_DeltaUv      = pLightCtl_param[5] << 8;
  Light_CtlParam.CTL_DeltaUv     |= pLightCtl_param[4];
  Light_CtlParam.CTL_TID          = pLightCtl_param[6];
  
  if(length > 7)
  {
    Light_CtlParam.CTL_TransitionTime = pLightCtl_param[7];
    Light_CtlParam.CTL_Delay          = pLightCtl_param[8];
    
    Light_CtlStatus.TargetCtlLightness16 = Light_CtlParam.CTL_Lightness;
    Light_CtlStatus.TargetCtlTemperature16 = Light_CtlParam.CTL_Temperature;
    Light_CtlStatus.RemainingTime = Light_CtlParam.CTL_TransitionTime;
    
    Light_TemporaryStatus.TargetParam_1 = Light_CtlStatus.TargetCtlLightness16;
    Light_TemporaryStatus.TargetParam_2 = Light_CtlStatus.TargetCtlTemperature16;
   
    Light_GetStepValue(pLightCtl_param[7]);
    Light_ModelFlag.LightOptionalParam = 1;
    Light_ModelFlag.LightTransitionFlag = 3;
  }
  else
  {
     /* When no optional parameter received, target value will
         be set as present value in application.
     */
    Light_CtlStatus.PresentCtlLightness16 = Light_CtlParam.CTL_Lightness;
    Light_CtlStatus.PresentCtlTemperature16 = Light_CtlParam.CTL_Temperature;
  }
   /* Application Callback */
   (LightAppli_cb.Light_Ctl_Set_cb)(&Light_CtlStatus, 0);
  
#if !defined(DISABLE_TRACES)
   printf("Ctl set callback PL 0x%.2x , TL 0x%.2x , PT 0x%.2x , TT 0x%.2x ,Remaining time  0x%.2x \r\n " ,
           Light_CtlStatus.PresentCtlLightness16,Light_CtlStatus.TargetCtlLightness16, Light_CtlStatus.PresentCtlTemperature16,
             Light_CtlStatus.TargetCtlTemperature16,Light_CtlStatus.RemainingTime );                
#endif     
  
   /* binding of light ctl with actual lightness */
    Light_BindingCtlToLightness_Actual(BINDING_LIGHT_CTL_LIGHTNESS_SET);
  
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light CTL Status
* @param  pLightCtl_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_Ctl_Status(MOBLEUINT8* pLightCtl_status, MOBLEUINT32 *pLength)
{
  /* 6.3.2.4 Light Lightness Ctl Status 
  Present Ctl Lightness           2B The Present ctl Lightness value of the model state. 
  Present Ctl Temperature         2B The Present ctl Temperature value of the model state. 
  Target Ctl Lightness            2B The Target ctl Lightness value of the model state.
  Target Ctl Temeperature         2B The Target ctl Temperature value of the model state.
  Remaining Time                  1B The Remaining Time value of the model state        
  */
    MOBLEUINT8 Light_GetBuff[4];
#if !defined(DISABLE_TRACES)
  printf("Light_Ctl_Status callback received \r\n");
#endif
     /* Function call back to get the values from application*/
     (Appli_Light_GetStatus_cb.GetLightCtl_cb)(Light_GetBuff);
      Light_CtlStatus.PresentCtlLightness16 = Light_GetBuff[1] << 8;
      Light_CtlStatus.PresentCtlLightness16 |= Light_GetBuff[0];
      Light_CtlStatus.PresentCtlTemperature16 = Light_GetBuff[3] << 8;
      Light_CtlStatus.PresentCtlTemperature16 |= Light_GetBuff[2];
  
   if((Light_ModelFlag.LightOptionalParam == 1) || (Light_TimeParam.StepValue != 0))
   {
      *(pLightCtl_status) =  Light_CtlStatus.PresentCtlLightness16; 
      *(pLightCtl_status+1) = Light_CtlStatus.PresentCtlLightness16  >> 8;
      *(pLightCtl_status+2) = Light_CtlStatus.PresentCtlTemperature16;
      *(pLightCtl_status+3) = Light_CtlStatus.PresentCtlTemperature16 >>8;
      *(pLightCtl_status+4) = Light_CtlStatus.TargetCtlLightness16;
      *(pLightCtl_status+5) = Light_CtlStatus.TargetCtlLightness16 >>8;
      *(pLightCtl_status+6) = Light_CtlStatus.TargetCtlTemperature16;
      *(pLightCtl_status+7) = Light_CtlStatus.TargetCtlTemperature16 >>8;
      *(pLightCtl_status+8) = Light_CtlStatus.RemainingTime;
      *pLength = 9;
       Light_ModelFlag.LightOptionalParam = 0;     
   }
   else
   {     
       *(pLightCtl_status) =  Light_CtlStatus.PresentCtlLightness16 ; 
       *(pLightCtl_status+1) = Light_CtlStatus.PresentCtlLightness16 >> 8;
       *(pLightCtl_status+2) = Light_CtlStatus.PresentCtlTemperature16;
       *(pLightCtl_status+3) = Light_CtlStatus.PresentCtlTemperature16 >> 8;
       *pLength = 4;         
   }
 
#if !defined(DISABLE_TRACES)
   printf("PL 0x%.2x , TL 0x%.2x , PT 0x%.2x , TT 0x%.2x ,Remaining time  0x%.2x \r\n " ,
           Light_CtlStatus.PresentCtlLightness16,Light_CtlStatus.TargetCtlLightness16, Light_CtlStatus.PresentCtlTemperature16,
             Light_CtlStatus.TargetCtlTemperature16,Light_CtlStatus.RemainingTime );                
#endif   
   
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CTLTemperature_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library
* @param  pLightCtlTemp_param : Pointer to the parameters received for message
* @param  length : Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_CtlTemperature_Set(const MOBLEUINT8* pLightCtlTemp_param, MOBLEUINT32 length)
{
  /* 6.3.2.6 Light Ctl Temperature Set 
  Ctl Temperature       2B The target value of the Light Temperature Ctl state.
  Ctl Delta Uv          2B The target value of the Light Temperature Ctl state.
  TID                   1B Transaction Identifier
  Transition Time       1B Format as defined in Section 3.1.3. (Optional)
  Delay                 1B Message execution delay in 5 millisecond steps (C.1)
  */
    
#if !defined(DISABLE_TRACES)
  printf("Light_CtlTemperature_Set callback received \r\n");
#endif   
  
  MOBLEUINT8 OptionalValid = 0;
  /* Received parameters from client */
  Light_CtlParam.CTL_Temperature   = pLightCtlTemp_param[1] << 8;
  Light_CtlParam.CTL_Temperature  |= pLightCtlTemp_param[0];
  Light_CtlParam.CTL_DeltaUv  = pLightCtlTemp_param[3] << 8;
  Light_CtlParam.CTL_DeltaUv |= pLightCtlTemp_param[2];
  Light_CtlParam.CTL_TID     = pLightCtlTemp_param[4] << 8;
  
  /* Binding with ctl temperature range value */
  Light_CtlTemperature_TempRangeBinding(&Light_CtlParam);
   
  if(length > 7)
  {
    Light_CtlParam.CTL_TransitionTime = pLightCtlTemp_param[5];
    Light_CtlParam.CTL_Delay          = pLightCtlTemp_param[6];
    
    Light_CtlStatus.TargetCtlTemperature16 = Light_CtlParam.CTL_Temperature;
    Light_CtlStatus.TargetCtlDeltaUv16 = Light_CtlParam.CTL_DeltaUv;
    Light_CtlStatus.RemainingTime = Light_CtlParam.CTL_TransitionTime;
    
    Light_TemporaryStatus.TargetParam_1 = Light_CtlStatus.TargetCtlTemperature16;
    Light_TemporaryStatus.TargetParam_2 = Light_CtlStatus.TargetCtlDeltaUv16;
    Light_ModelFlag.LightOptionalParam = 1;
    Light_ModelFlag.LightTransitionFlag = 3;
  }
  else
  {
    /* When no optional parameter received, target value will
         be set as present value in application.
    */
    Light_CtlStatus.PresentCtlTemperature16 = Light_CtlParam.CTL_Temperature;
    Light_CtlStatus.PresentCtlDelta16 = Light_CtlParam.CTL_DeltaUv;
  }
  
#if !defined(DISABLE_TRACES)
   printf("Ctl temperature set callback PT 0x%.2x , TT 0x%.2x , PU 0x%.2x , TU 0x%.2x ,Remaining time  0x%.2x \r\n " ,
           Light_CtlStatus.PresentCtlTemperature16,Light_CtlStatus.TargetCtlTemperature16, Light_CtlStatus.PresentCtlDelta16,
             Light_CtlStatus.TargetCtlDeltaUv16, Light_CtlStatus.RemainingTime);                
#endif  
  
   /* Application Callback */
   (LightAppli_cb.Light_CtlTemperature_Set_cb)(&Light_CtlStatus, OptionalValid);
   /* Binding of data Ctl Temperature  with Generic Level */
   Light_CtlTemp_GenericLevelBinding(&Light_CtlParam);
      
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CtlTemperature_Status
* @param  pLightCtlTemp_status: Pointer to the status message, which needs to be updated
* @param  pLength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_CtlTemperature_Status(MOBLEUINT8* pLightCtlTemp_status, MOBLEUINT32 *pLength)
{
  /* 6.3.2.4 Light Lightness Ctl Status
  
  Present Ctl Temperature         2B The Present ctl Temperature value of the model state. 
  Present Ctl Delta Uv            2B The Present ctl Delta Uv value of the model state. 
  Target Ctl Temperature          2B The Target ctl Tepmerature value of the model state.
  Target Ctl Delta Uv             2B The Target ctl Delta Uv value of the model state.
  Remaining Time                  1B The Remaining Time value of the model state
  */
    MOBLEUINT8 Light_GetBuff[4];
#if !defined(DISABLE_TRACES)
  printf("Light_CtlTemperature_Status callback received \r\n");
#endif
      /* Function call back to get the values from application*/
     (Appli_Light_GetStatus_cb.GetLightCtlTemp_cb)(Light_GetBuff);
      Light_CtlStatus.PresentCtlTemperature16 = Light_GetBuff[1] << 8;
      Light_CtlStatus.PresentCtlTemperature16 |= Light_GetBuff[0];
      Light_CtlStatus.PresentCtlDelta16 = Light_GetBuff[3] << 8;
      Light_CtlStatus.PresentCtlDelta16 |= Light_GetBuff[2];
     
  if((Light_ModelFlag.LightOptionalParam == 1) || (Light_TimeParam.StepValue != 0))
   {
      *(pLightCtlTemp_status) = Light_CtlStatus.PresentCtlTemperature16; 
      *(pLightCtlTemp_status+1) = Light_CtlStatus.PresentCtlTemperature16  >> 8;
      *(pLightCtlTemp_status+2) = Light_CtlStatus.PresentCtlDelta16;
      *(pLightCtlTemp_status+3) = Light_CtlStatus.PresentCtlDelta16 >>8;
      *(pLightCtlTemp_status+4) = Light_CtlStatus.TargetCtlTemperature16;
      *(pLightCtlTemp_status+5) = Light_CtlStatus.TargetCtlTemperature16 >>8;
      *(pLightCtlTemp_status+6) = Light_CtlStatus.TargetCtlDeltaUv16;
      *(pLightCtlTemp_status+7) = Light_CtlStatus.TargetCtlDeltaUv16 >>8;
      *(pLightCtlTemp_status+8) = Light_CtlStatus.RemainingTime;
      *pLength = 9;
       Light_ModelFlag.LightOptionalParam = 0;    
   }
  else
  {   
      /* When no optional parameter received then, target value will
         be sent in status message.
      */
      *(pLightCtlTemp_status) =  Light_CtlStatus.PresentCtlTemperature16; 
      *(pLightCtlTemp_status+1) = Light_CtlStatus.PresentCtlTemperature16  >> 8;
      *(pLightCtlTemp_status+2) = Light_CtlStatus.PresentCtlDelta16;
      *(pLightCtlTemp_status+3) = Light_CtlStatus.PresentCtlDelta16 >>8;
      *pLength = 4;             
  }
  
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CtlTemperature_Range_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library.
* @param  plightCtlTempRange_param : Pointer to the parameters received for message.
* @param  length : Length of the parameters received for message.
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_CtlTemperature_Range_Set(const MOBLEUINT8* plightCtlTempRange_param, MOBLEUINT32 length)
{
  /* 6.3.2.10 Light Ctl Temperature Set
  
  Min Range          2B The minimum value for Ctl temperature state.
  Max Range          2B The maximum value for Ctl temperature state.
  */
  
#if !defined(DISABLE_TRACES)
  printf("Light_CtlTemperature_Range_Set callback received \r\n");
#endif   
  
  MOBLEUINT8 OptionalValid = 0;
  
  CtlTemperatureRangeParam.MinRangeStatus = plightCtlTempRange_param[1] << 8;
  CtlTemperatureRangeParam.MinRangeStatus |= plightCtlTempRange_param[0];
  
  CtlTemperatureRangeParam.MaxRangeStatus = plightCtlTempRange_param[3] << 8;
  CtlTemperatureRangeParam.MaxRangeStatus |= plightCtlTempRange_param[2];
  CtlTemperatureRangeParam.StatusCode = SUCCESS_STATUS_CODE;
  
  /* condition to check the minimum range value according to the specification*/
  /* set the status code for status message according to value of range*/  
  if((CtlTemperatureRangeParam.MinRangeStatus < MIN_CTL_TEMP_RANGE) ||
             (CtlTemperatureRangeParam.MinRangeStatus >MAX_CTL_TEMP_RANGE))
  {
    CtlTemperatureRangeParam.StatusCode = MIN_RANGE_INVALID_STATUS_CODE;
  }
  if((CtlTemperatureRangeParam.MaxRangeStatus < MIN_CTL_TEMP_RANGE) ||
             (CtlTemperatureRangeParam.MaxRangeStatus >MAX_CTL_TEMP_RANGE))
  {
    CtlTemperatureRangeParam.StatusCode = MIN_RANGE_INVALID_STATUS_CODE;
  }
  
  if((CtlTemperatureRangeParam.MaxRangeStatus == UNKNOWN_CTL_TEMP_VALUE) ||
        (CtlTemperatureRangeParam.MaxRangeStatus < CtlTemperatureRangeParam.MinRangeStatus))
  {
    CtlTemperatureRangeParam.StatusCode = MAX_RANGE_INVALID_STATUS_CODE;
  } 
  /* Application Callback */
  (LightAppli_cb.Light_CtlTemperature_Range_Set_cb)(&CtlTemperatureRangeParam, OptionalValid);
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CtlTemperature_Range_Status
* @param  pCtlTempRange_status: Pointer to the status message, which needs to be updated.
* @param  pLength: Pointer to the Length of the Status message.
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_CtlTemperature_Range_Status(MOBLEUINT8* pCtlTempRange_status, MOBLEUINT32 *pLength)
{
  /* 6.3.2.12 Light Ctl Temperature status 
  Status Code        1B The Status code for the temperature range status.
  Min Range          2B The minimum value for Ctl temperature state.
  Max Range          2B The maximum value for Ctl temperature state.
  */
    MOBLEUINT8 Light_GetBuff[5];
#if !defined(DISABLE_TRACES)
  printf("Light_Lightness_Range_Status callback received \r\n");
#endif
     /* Function call back to get the values from application*/
     (Appli_Light_GetStatus_cb.GetLightCtlTempRange_cb)(Light_GetBuff);
    
    CtlTemperatureRangeParam.StatusCode = Light_GetBuff[0];
    CtlTemperatureRangeParam.MinRangeStatus = Light_GetBuff[2] << 8;
    CtlTemperatureRangeParam.MinRangeStatus |= Light_GetBuff[1];
    CtlTemperatureRangeParam.MaxRangeStatus = Light_GetBuff[4] << 8;
    CtlTemperatureRangeParam.MaxRangeStatus |= Light_GetBuff[3];
    
    memcpy(pCtlTempRange_status ,Light_GetBuff, 5); 
    *pLength = 5;
    
    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CtlDefault_Set: This function is called for both Acknowledged and 
          unacknowledged message. The Acknowledgement is taken care by 
          the Library.
* @param  pCtlDefault_param : Pointer to the parameters received for message.
* @param  length : Length of the parameters received for message.
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_CtlDefault_Set(const MOBLEUINT8* pCtlDefault_param, MOBLEUINT32 length)
{
  /* 6.3.2.6 Light Ctl Default Set  
  Ctl Lightness         2B The Default value of the Ctl Lightness.
  Ctl Temperature       2B The Default value of the Ctl Temperature..
  Ctl Delta Uv          2B The Default value of the Ctl Delta Uv..  
  */
#if !defined(DISABLE_TRACES)
  printf("Light_CtlDefault_Set callback received \r\n");
#endif 
  
  MOBLEUINT8 OptionalValid = 0;
  
  Light_CtlDefaultParam.CtlDefaultLightness16 = pCtlDefault_param[1] << 8;
  Light_CtlDefaultParam.CtlDefaultLightness16 |= pCtlDefault_param[0];
  
  Light_CtlDefaultParam.CtlDefaultTemperature16 = pCtlDefault_param[3] << 8;
  Light_CtlDefaultParam.CtlDefaultTemperature16 |= pCtlDefault_param[2];
  
  Light_CtlDefaultParam.CtlDefaultDeltaUv = pCtlDefault_param[5] << 8;
  Light_CtlDefaultParam.CtlDefaultDeltaUv |= pCtlDefault_param[4];
  
#if !defined(DISABLE_TRACES)
   printf("Inside the Ctl Default set Default Lightness 0x%.2x , Default temperature 0x%.2x , Default delta 0x%.2x  \r\n " ,
           Light_CtlDefaultParam.CtlDefaultLightness16,Light_CtlDefaultParam.CtlDefaultTemperature16, Light_CtlDefaultParam.CtlDefaultDeltaUv );                
#endif   
  /* Application Callback */
  (LightAppli_cb.Light_CtlDefault_Set_cb)(&Light_CtlDefaultParam , OptionalValid);
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Light_CtlDefault_Status
* @param  pCtlDefault_status: Pointer to the status message, which needs to be updated.
* @param  pLength: Pointer to the Length of the Status message.
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Light_CtlDefault_Status(MOBLEUINT8* pCtlDefault_status, MOBLEUINT32 *pLength)
{
  /* 6.3.2.16 Light Ctl Default Status 
  Ctl Lightness         2B The Default value of the Ctl Lightness.
  Ctl Temperature       2B The Default value of the Ctl Temperature..
  Ctl Delta Uv          2B The Default value of the Ctl Delta Uv.. 
  */
    MOBLEUINT8 Light_GetBuff[6];
#if !defined(DISABLE_TRACES)
  printf("Light_Ctl_DefaultStatus callback received \r\n");
#endif
     /* Function call back to get the values from application*/
     (Appli_Light_GetStatus_cb.GetLightCtlDefault_cb)(Light_GetBuff);
     
    Light_CtlDefaultParam.CtlDefaultLightness16 = Light_GetBuff[1] << 8;
    Light_CtlDefaultParam.CtlDefaultLightness16 |= Light_GetBuff[0];
    Light_CtlDefaultParam.CtlDefaultTemperature16 = Light_GetBuff[3] << 8;
    Light_CtlDefaultParam.CtlDefaultTemperature16 |= Light_GetBuff[2];
    Light_CtlDefaultParam.CtlDefaultDeltaUv = Light_GetBuff[5] << 8;
    Light_CtlDefaultParam.CtlDefaultDeltaUv |= Light_GetBuff[4];
    
    memcpy(pCtlDefault_status , Light_GetBuff, 6); 
    *pLength = 6;
  
   return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  LightModelServer_GetLightOpcodeTableCb: This function is call-back 
          from the library to send Model Opcode Table info to library
* @param  MODEL_OpcodeTableParam_t:  Pointer to the Light Model opcode array 
* @param  length: Pointer to the Length of Light Model opcode array
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT LightModelServer_GetLightOpcodeTableCb(const MODEL_OpcodeTableParam_t **data, 
                                    MOBLEUINT16 *length)
{
  *data = Light_Opcodes_Table;
  *length = sizeof(Light_Opcodes_Table)/sizeof(Light_Opcodes_Table[0]);

  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic model add function
* @param  function adds all the sub model of Light model.
          Function uses the mid of the model for adding.
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT BluenrgMesh_AddLightingModels(void)
{
  MOBLE_RESULT res = MOBLE_RESULT_FAIL;
  
#ifdef ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS 
  
  if(MOBLE_FAILED(LightModel_Add_Server(LIGHT_MODEL_SERVER_LIGHTNESS_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to Light Lightness Model \n\r");
#endif
    res = MOBLE_RESULT_FAIL;
  }
#endif    
  
#ifdef ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS_SETUP   
  
  if(MOBLE_FAILED(LightModel_Add_Server(LIGHT_MODEL_SERVER_LIGHTNESS_SETUP_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Light Lightness Setup Model \n\r");
#endif		
    res = MOBLE_RESULT_FAIL;
  }                                         
#endif 
  
#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL          
  if(MOBLE_FAILED(LightModel_Add_Server(LIGHT_MODEL_SERVER_CTL_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Light CTL Model \n\r");
#endif
    res = MOBLE_RESULT_FAIL;
  }     
#endif   
  
#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL_SETUP       
  
  if(MOBLE_FAILED(LightModel_Add_Server(LIGHT_MODEL_SERVER_CTL_SETUP_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Light CTL Setup Model \n\r");
#endif
    res = MOBLE_RESULT_FAIL;
  }      
#endif  

#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL_TEMPERATURE    
  
  if(MOBLE_FAILED(LightModel_Add_Server(LIGHT_MODEL_SERVER_CTL_TEMPERATURE_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Light CTL Temperature Model \n\r");
#endif
    res = MOBLE_RESULT_FAIL;
  }    
#endif      
  
   return res;    
}
  
/**
* @brief  LightModelServer_GetStatusRequestCb : This function is call-back 
          from the library to send response to the message from peer
* @param  peer_addr: Address of the peer
* @param  dst_peer: destination send by peer for this node. It can be a
*                                                     unicast or group address 
* @param  opcode: Received opcode of the Status message callback
* @param  pResponsedata: Pointer to the buffer to be updated with status
* @param  plength: Pointer to the Length of the data, to be updated by application
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT LightModelServer_GetStatusRequestCb(MOBLE_ADDRESS peer_addr, 
                                    MOBLE_ADDRESS dst_peer, 
                                    MOBLEUINT16 opcode, 
                                    MOBLEUINT8 *responsedata, 
                                    MOBLEUINT32 *plength, 
                                    MOBLEBOOL response)
{
  switch(opcode)
  {
  case LIGHT_LIGHTNESS_STATUS:
    {
      Light_Lightness_Status(responsedata, plength);
      break;
    }
    
  case LIGHT_LIGHTNESS_LINEAR_STATUS:
    {
      Light_Lightness_Linear_Status(responsedata, plength);
      break;
    }
    
  case LIGHT_LIGHTNESS_LAST_STATUS:
    {
      Light_Lightness_Last_Status(responsedata, plength);
      break;
    }
   case LIGHT_LIGHTNESS_DEFAULT_STATUS:
    {
      Light_Lightness_Default_Status(responsedata, plength);
      break;
    }  
    case LIGHT_LIGHTNESS_RANGE_STATUS:
    {
      Light_Lightness_Range_Status(responsedata, plength);
      break;
    }   
    case LIGHT_CTL_STATUS:
    {      
      Light_Ctl_Status(responsedata , plength);    
      break;
    }
    case LIGHT_CTL_TEMPERTAURE_STATUS:    
    {
      Light_CtlTemperature_Status(responsedata , plength);
      break;
    }
  case LIGHT_CTL_TEMPERATURE_RANGE_STATUS:
    {    
      Light_CtlTemperature_Range_Status(responsedata , plength);
      break;
    }
  case LIGHT_CTL_DEFAULT_STATUS:
    {
      Light_CtlDefault_Status(responsedata , plength);          
      break;
    }
  default:
    {
      break;
    }
  }
  return MOBLE_RESULT_SUCCESS;    
}

/**
* @brief  LightModelServer_ProcessMessageCb: This is a callback function from
           the library whenever a Light Model message is received
* @param  peer_addr: Address of the peer
* @param  dst_peer: destination send by peer for this node. It can be a
*                                                     unicast or group address 
* @param  opcode: Received opcode of the Status message callback
* @param  pData: Pointer to the buffer to be updated with status
* @param  length: Length of the parameters received 
* @param  response: if TRUE, the message is an acknowledged message 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT LightModelServer_ProcessMessageCb(MOBLE_ADDRESS peer_addr, 
                                    MOBLE_ADDRESS dst_peer, 
                                    MOBLEUINT16 opcode, 
                                    MOBLEUINT8 const *data, 
                                    MOBLEUINT32 length, 
                                    MOBLEBOOL response
                                    )
{
  MOBLE_RESULT result = MOBLE_RESULT_SUCCESS;
  
  switch(opcode)
  {
    case LIGHT_LIGHTNESS_GET:
    case LIGHT_LIGHTNESS_STATUS:
    case LIGHT_LIGHTNESS_LINEAR_GET:
    case LIGHT_LIGHTNESS_LINEAR_STATUS:
    case LIGHT_LIGHTNESS_LAST_GET:
    case LIGHT_LIGHTNESS_LAST_STATUS:
    case LIGHT_LIGHTNESS_DEFAULT_GET:             
    case LIGHT_LIGHTNESS_DEFAULT_STATUS:          
    case LIGHT_LIGHTNESS_RANGE_GET:               
    case LIGHT_LIGHTNESS_RANGE_STATUS:            
      {
        /* Nothing to do here  */
        /* Callback of LightModelServer_GetStatusRequestCb will be called */
        break;
      }
      
    
    case LIGHT_LIGHTNESS_SET:
    case LIGHT_LIGHTNESS_SET_UNACK:
      {       
        result = Chk_ParamMinMaxValidity(0X00 ,data , 0xFFFF );
        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Light_Lightness_Set(data, length);
        }
        break;
      }
      
    case LIGHT_LIGHTNESS_LINEAR_SET:
    case LIGHT_LIGHTNESS_LINEAR_SET_UNACK: 
      {
        result = Chk_ParamMinMaxValidity(0x00 , data , 0xFFFF);
        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Light_Lightness_Linear_Set(data, length);
        }
        break;
      }
    case LIGHT_LIGHTNESS_DEFAULT_SET:
    case LIGHT_LIGHTNESS_DEFAULT_SET_UNACK:
      {      
        result = Chk_ParamMinMaxValidity(0x00 , data , 0xFFFF);
        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Light_Lightness_Default_Set(data , length);
        }
        break;
      }
    case LIGHT_LIGHTNESS_RANGE_SET:
    case LIGHT_LIGHTNESS_RANGE_SET_UNACK:
      {
        result = Chk_RangeValidity(0x01 , data , 0xFFFF);
        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Light_Lightness_Range_Set(data , length);
        }
        break;
      }
    case LIGHT_CTL_SET:
    case LIGHT_CTL_SET_UNACK:
     {       
        result = Chk_TwoParamValidity(0x00 ,0xFFFF ,0x0320 ,0x4E20 ,data);
        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Light_Ctl_Set(data , length);
        }        
        break;
     }
      
    case LIGHT_CTL_TEMPERATURE_SET:
    case LIGHT_CTL_TEMPERATURE_SET_UNACK:
     {
       result = Chk_ParamMinMaxTempValidity(0X320 , data , 0X4E20);
        
       if(result == MOBLE_RESULT_SUCCESS)
       {
         Light_CtlTemperature_Set(data , length);
       }
       break;
     }
    case LIGHT_CTL_TEMPERTATURE_RANGE_SET:
    case LIGHT_CTL_TEMPERTATURE_RANGE_SET_UNACK:
    {
      result = Chk_RangeValidity(0x0320 , data , 0x4E20);
      
      if(result == MOBLE_RESULT_SUCCESS)
      {
        Light_CtlTemperature_Range_Set(data , length);
      }
       break;
    }
    case LIGHT_CTL_DEFAULT_SET:
    case LIGHT_CTL_DEFAULT_SET_UNACK:
     { 
       result = Chk_MultiParamValidity(0x00 ,0xFFFF ,0x0320 ,0x4E20 , 0x8000 ,0x7FFF ,data);
       
       if(result == MOBLE_RESULT_SUCCESS) 
       {
          Light_CtlDefault_Set(data , length);
       }
        break;
     }
    
  default:
    {
      break;
    }    
  } /* Switch ends */
  
  if((result == MOBLE_RESULT_SUCCESS) && (response == MOBLE_TRUE))
  {
    Light_SendResponse(peer_addr, dst_peer ,opcode ,length);                                            
  }

  return MOBLE_RESULT_SUCCESS;
}


/*
* @Brief Light Lightness Transition behaviour funtion is used for the Light Lightness model
*         when transition time is  received in message.     
* @param GetValue Pointer of the array
* @retval MOBLE_RESULT
*/
MOBLE_RESULT Light_LightnessTransitionBehaviour(MOBLEUINT8 *GetValue)
{
  
  static MOBLEUINT8 Clockflag = 0;
  static MOBLEUINT32 Check_time;
  MOBLEUINT16 targetRange;
  MOBLEUINT16 targetSlot;
  
  if(Clockflag == 0)
  {
    Check_time = Clock_Time();
    Clockflag = 1;
  }
    /* Values from application are copied into temporary vaiables for processing */    
     Light_TemporaryStatus.PresentParam_1 = GetValue[1] << 8;
     Light_TemporaryStatus.PresentParam_1 |= GetValue[0];   
    /*if condition to wait untill the time is equal to the given resolution time */  
     if(((Clock_Time()- Check_time) >= Light_TimeParam.Res_Value))
     {
        if(Light_TimeParam.StepValue == 0)
        {
          Light_TimeParam.StepValue = 1;
        }
        if(Light_TemporaryStatus.TargetParam_1 > Light_TemporaryStatus.PresentParam_1)
        {
          /* calulating the target range to be acheived which is traget value
              which is traget value minus present value if target value is greater 
              than present value.   
           */
           targetRange = Light_TemporaryStatus.TargetParam_1 - Light_TemporaryStatus.PresentParam_1;  
           /*target slot = time to cover in single step */
           targetSlot = targetRange/Light_TimeParam.StepValue;
           /* target slot added to present value to achieve target value */
           Light_TemporaryStatus.PresentParam_1 += targetSlot;             
        }              
        else
        { 
           /* if present value is greater than target value, this condition executes */
           targetRange = Light_TemporaryStatus.PresentParam_1 - Light_TemporaryStatus.TargetParam_1;;
           targetSlot = targetRange/Light_TimeParam.StepValue;          
           Light_TemporaryStatus.PresentParam_1 -= targetSlot;
        } 
           Light_TimeParam.StepValue--;         
           /* updating the remaining time after each step covered*/
           Light_TemporaryStatus.RemainingTime =  Light_TimeParam.StepValue  | (Light_TimeParam.ResBitValue << 6) ;
                                                   
           Check_time = 0;
           Clockflag = 0;
          /* when transition is completed, disable the transition by disabling 
             transition flag
          */
          if(Light_TimeParam.StepValue == 0)
          {              
            Light_ModelFlag.LightTransitionFlag = 0;
          }
#if !defined(DISABLE_TRACES)               
      printf("Inside light lightness transmition time at %d, Current state 0x%.2x , target state 0x%.2x , Remaining Time 0x%.2x\n\r", 
           Clock_Time(), Light_TemporaryStatus.PresentParam_1,Light_TemporaryStatus.TargetParam_1, Light_TemporaryStatus.RemainingTime);
#endif          
    
       }
       
      return MOBLE_RESULT_SUCCESS;         
} 


/*
* @Brief Light Ctl transition behaviour funtion is used for the Light Lightness model
*         when transition time is  received in message.     
* @param GetValue Pointer of the array
* @retval MOBLE_RESULT
*/
MOBLE_RESULT Light_CtlTransitionBehaviour(MOBLEUINT8 *GetValue )
{
  
  static MOBLEUINT8 Clockflag = 0;
  static MOBLEUINT32 Check_time;
  MOBLEUINT16 targetRangeLightness;
  MOBLEUINT16 targetRangeTemperature;
  MOBLEUINT16 targetSlotLightness;
  MOBLEUINT16 targetSlotTemperature;
  
  if(Clockflag == 0)
  {
    Check_time = Clock_Time();
    Clockflag = 1;
  }
    /* Values from application are copied into Temporary vaiables for processing */
     Light_TemporaryStatus.PresentParam_1 = GetValue[1] << 8;
     Light_TemporaryStatus.PresentParam_1 |= GetValue[0];
     Light_TemporaryStatus.PresentParam_2 = GetValue[3] << 8;
     Light_TemporaryStatus.PresentParam_2 |= GetValue[2];
    /*if condition to wait untill the time is equal to the given resolution time */   
     if(((Clock_Time()- Check_time) >= Light_TimeParam.Res_Value))
     {
        if(Light_TimeParam.StepValue == 0)
        {
          Light_TimeParam.StepValue = 1;
        }
        if(Light_TemporaryStatus.TargetParam_1 > Light_TemporaryStatus.PresentParam_1)
        {
           /* calulating the target range to be acheived which is traget value
              which is traget value minus present value if target value is greater 
              than present value.   
           */
           targetRangeLightness =  Light_TemporaryStatus.TargetParam_1 - Light_TemporaryStatus.PresentParam_1;            
           /*target slot = time to cover in single step */
           targetSlotLightness = targetRangeLightness/Light_TimeParam.StepValue;
           /* target slot added to present value to achieve target value */
           Light_TemporaryStatus.PresentParam_1 += targetSlotLightness;             
        }              
        else
        { 
           /* condition execute when transition is negative */
           /* target range = total range to be covered */ 
           targetRangeLightness = Light_TemporaryStatus.PresentParam_1 - Light_TemporaryStatus.TargetParam_1; 
           /*target slot = time to cover in single step */
           targetSlotLightness = targetRangeLightness/Light_TimeParam.StepValue;
            /*target slot = time to cover in single step */
           Light_TemporaryStatus.PresentParam_1 -= targetSlotLightness;
        } 
        if(Light_TemporaryStatus.TargetParam_2 > Light_TemporaryStatus.PresentParam_2 )
        {
           targetRangeTemperature = Light_TemporaryStatus.TargetParam_2 - Light_TemporaryStatus.PresentParam_2;
           targetSlotTemperature = targetRangeTemperature/Light_TimeParam.StepValue; 
           Light_TemporaryStatus.PresentParam_2 += targetSlotTemperature;
        }
        else
        {
           targetRangeTemperature = Light_TemporaryStatus.PresentParam_2 - Light_TemporaryStatus.TargetParam_2;
           targetSlotTemperature = targetRangeTemperature/Light_TimeParam.StepValue; 
           Light_TemporaryStatus.PresentParam_2 -= targetSlotTemperature;
        }
                 
          Light_TimeParam.StepValue--;                           
          /* updating the remaining time after each step covered*/
          Light_TemporaryStatus.RemainingTime = Light_TimeParam.StepValue | (Light_TimeParam.ResBitValue << 6) ;
                                                   
          Check_time = 0;
          Clockflag = 0;
          /* when transition is completed, disable the transition by disabling 
           transition flag
          */
          if(Light_TimeParam.StepValue <= 0)
          {
            Light_ModelFlag.LightTransitionFlag = 0;        
          }
#if !defined(DISABLE_TRACES)               
    printf("Inside light Ctl transmition %d,PL 0x%.2x ,TL 0x%.2x ,PT 0x%.2x ,TT 0x%.2x, Remaining Time 0x%.2x \n\r", 
         Clock_Time(),  Light_TemporaryStatus.PresentParam_1,Light_TemporaryStatus.TargetParam_1, 
          Light_TemporaryStatus.PresentParam_2,Light_TemporaryStatus.TargetParam_2,Light_TemporaryStatus.RemainingTime);
#endif          
    
       }
return MOBLE_RESULT_SUCCESS;         
} 
/*
* @Brief  Light_GetStepValue:Function calculates parameters for transition time 
*         for light model.
* @param stepParam is transition time set value.
* retval void.
*/
void Light_GetStepValue(MOBLEUINT8 stepParam)
{
    /*
     Two MSB bit of transition time is dedicated to resolution.
     00 = resolution is 100 ms.
     01 = resolution is 1000 ms. 
     10 = resolution is 10000 ms.
     11 = resolution is 600000 ms. 
    Last bits from 0 to 5th index is step number.
  */
  
   Light_TimeParam.ResBitValue = stepParam >> 6 ;
   Light_TimeParam.Res_Value = Get_StepResolutionValue(Light_TimeParam.ResBitValue);
   Light_TimeParam.StepValue = stepParam & 0x3F ;
   
#if !defined(DISABLE_TRACES)   
   printf(" step resolution 0x%.2x, number of step 0x%.2x \r\n",Light_TimeParam.Res_Value , 
          Light_TimeParam.StepValue  );
#endif    
}

/**
* @brief  Function to execute the trnsition state machine for
          particular Light Model
* @param  void
* @retval void
*/ 
void Lighting_Process(void)
{ 
  MOBLEUINT8 Light_GetBuff[8];
    
#ifdef ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS
  if(Light_ModelFlag.LightTransitionFlag == 1)
  {  
    (Appli_Light_GetStatus_cb.GetLightLightness_cb)(Light_GetBuff);     
    Light_LightnessTransitionBehaviour(Light_GetBuff);
    LightLightnessStateUpdate_Process();
    (LightAppli_cb.Lightness_Set_cb)(&Light_LightnessStatus,0);  
  }  
  if(Light_ModelFlag.LightTransitionFlag == 2)
  {
    (Appli_Light_GetStatus_cb.GetLightLightnessLinear_cb)(Light_GetBuff); 
    Light_LightnessTransitionBehaviour(Light_GetBuff);
    LightLinearStateUpdate_Process();
    (LightAppli_cb.Lightness_Linear_Set_cb)(&Light_LightnessStatus,0);
  }
#endif
#ifdef ENABLE_LIGHT_MODEL_SERVER_CTL   
  if(Light_ModelFlag.LightTransitionFlag == 3)
  {
    (Appli_Light_GetStatus_cb.GetLightCtl_cb)(Light_GetBuff);
    Light_CtlTransitionBehaviour(Light_GetBuff);
    LightCtlStateUpdate_Process();
    (LightAppli_cb.Light_Ctl_Set_cb)(&Light_CtlStatus , 0);
  }
#endif
  
}

/*
* @Brief LightLightnessStateUpdate_Process:Function to update the parametes of light
*         lightness model in application file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
MOBLE_RESULT LightLightnessStateUpdate_Process(void)
{
  Light_LightnessStatus.PresentValue16 = Light_TemporaryStatus.PresentParam_1;
  Light_LightnessStatus.TargetValue16 = Light_TemporaryStatus.TargetParam_1;;
  Light_LightnessStatus.RemainingTime = Light_TemporaryStatus.RemainingTime ;
  return MOBLE_RESULT_SUCCESS;
}

/*
* @Brief LightLinearStateUpdate_Process:function to update the parametes of light 
*        lightness linear model in application file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
MOBLE_RESULT LightLinearStateUpdate_Process(void)
{
  Light_LightnessStatus.PresentValue16 = Light_TemporaryStatus.PresentParam_1;
  Light_LightnessStatus.TargetValue16 =  Light_TemporaryStatus.TargetParam_1;;
  Light_LightnessStatus.RemainingTime = Light_TemporaryStatus.RemainingTime ;
  return MOBLE_RESULT_SUCCESS;
}

/*
* @Brief LightCtlStateUpdate_Process:Function to update the parametes of light  
*        CTL model in application file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
MOBLE_RESULT LightCtlStateUpdate_Process(void)
{
  Light_CtlStatus.PresentCtlLightness16 =Light_TemporaryStatus.PresentParam_1; 
  Light_CtlStatus.PresentCtlTemperature16 = Light_TemporaryStatus.PresentParam_2;
  Light_CtlStatus.RemainingTime = Light_TemporaryStatus.RemainingTime;
  return MOBLE_RESULT_SUCCESS;
}

/*
* @Brief LightCtlTemperatureStateUpdate_Process:Function to update the parametes of 
*        light CTL Temperature model in application  file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
MOBLE_RESULT LightCtlTemperatureStateUpdate_Process(void)
{
  Light_CtlStatus.PresentCtlTemperature16 = Light_TemporaryStatus.PresentParam_1; 
  Light_CtlStatus.PresentCtlDelta16 = Light_TemporaryStatus.PresentParam_2;
  Light_CtlStatus.RemainingTime = Light_TemporaryStatus.RemainingTime;
  return MOBLE_RESULT_SUCCESS;
}

/*
* @Brief Light_BindingCtlToLightness_Actual:Function for binding the data of actual 
*        lightness and light Ctl set.
* @param bindingFlag
* return void
*/
void Light_BindingCtlToLightness_Actual(MOBLEUINT8 bindingFlag)
{ 
   if(bindingFlag == BINDING_LIGHT_CTL_LIGHTNESS_SET)
   {
     Light_LightnessStatus.PresentValue16 = Light_CtlParam.CTL_Lightness;
     (LightAppli_cb.Lightness_Set_cb)(&Light_LightnessStatus, 0);
   }
   if(bindingFlag == BINDING_LIGHT_LIGHTNESS_ACTUAL_SET)
   {
     Light_CtlStatus.PresentCtlLightness16 = Light_LightnessParam.TargetLightnessStatus;
     (LightAppli_cb.Light_Ctl_Set_cb)(&Light_CtlStatus, 0);
   }
}

/*
* @Brief  LightActual_GenericOnOffBinding: Reverse Data binding b/w Generic On Off and 
*         light lightness Actual. this function will set the On Off status of
*         Light when the light lightness Actual is set.
* @param lightActual used to select the binding and reverse binding 
* return void.
*/
void LightActual_GenericOnOffBinding(Light_LightnessParam_t* lightActual)
{
  /*
   6.1.2.2.3 - Binding of actual light lightness with generic on off,
               As actual lightness will set which changes the on off state in 
               generic model
  */
  Generic_OnOffStatus_t bGeneric_OnOffParam;
     
  if(lightActual ->TargetLightnessStatus == 0x00)
  {
    bGeneric_OnOffParam.Present_OnOff = 0x00;
  }
  else
  {
    bGeneric_OnOffParam.Present_OnOff = 0x01;
  }
#if !defined(DISABLE_TRACES)  
  printf("LightActual_GenericOnOffBinding Function - Present OnOff value 0x%.2x \r\n" 
             , bGeneric_OnOffParam.Present_OnOff);  
#endif   
  (GenericAppli_cb.OnOff_Set_cb)(&bGeneric_OnOffParam, 0); 
}

/*
* @Brief  LightActual_GenericLevelBinding: Data binding b/w Generic Level and 
*         light lightness Actual. this function will set the actual light lightness
*         value at the time of  generic Level set. 
* @param lightActual Pointer to the data which needs to be checked.
* return void.
*/
void LightActual_GenericLevelBinding(Light_LightnessParam_t* lightActual)
{
  /*
    6.1.2.2.2 - Binding of actual light lightness with generic level
                As Actual lightness changes, the generic level value will
                change.
  */
  Generic_LevelStatus_t bGeneric_LevelParam ; 
 
  bGeneric_LevelParam.Present_Level16 = lightActual->TargetLightnessStatus - 32768;  
   
  (GenericAppli_cb.Level_Set_cb)(&bGeneric_LevelParam, 0); ;
}

/*
* @Brief Light_Linear_ActualImplicitBinding:Function for binding the data of actual 
         lightness and Linear Lightness is implicit binding with  generic on off state.              
* @param bindingFlag 
* return void
*/
void Light_Linear_ActualImplicitBinding(MOBLEUINT8 bindingFlag)
{ 
   /*
     6.1.2.1.1 - actual lightness = 655354 * squareroot(linear lightness/ 655354).
   */
  
   Light_LightnessParam_t bLightnessActual;
   
   if(bindingFlag == BINDING_LIGHT_LIGHTNESS_LINEAR_SET)
   {
        
     bLightnessActual.TargetLightnessStatus = Light_Linear_ActualBinding();
     /* Implicit binding of linear lightness with generic on off.
        linear lightnes set -> actual lightness set -> generic on off set.
        As linear lightness changes, it changes the value of actual lightness
        which in turn changes the state of generic on off state.
     */
     LightActual_GenericOnOffBinding(&bLightnessActual);
     /* Implicit binding of linear lightness with generic level.
        linear lightnes set -> actual lightness set -> generic Level set.
        As linear lightness changes, it changes the value of actual lightness
        which in turn changes the state of generic level state.
    */
       LightActual_GenericLevelBinding(&bLightnessActual);
   }
   if(bindingFlag == BINDING_LIGHT_LIGHTNESS_ACTUAL_SET)
   {
      Light_Actual_LinearBinding();
   }
   
#if !defined(DISABLE_TRACES)    
  printf("Light_Linear_ActualImplicitBinding - Actual Lightness value 0x%.2x , Linear Lightness value 0x%.2x \r\n " ,
             Light_LightnessStatus.PresentValue16,Light_LightnessStatus.PresentValue16  );
#endif  
            
}

/*Light_Actual_LinearBinding
* @Brief Light_Actual_LinearBinding:Light_Actual_LinearBinding:Function used for 
*        binding the data of actual lightness and lineaer lightness.this function
*        changes the value of linear lightness as actual lightness value is set.
* @param void 
* return MOBLEUINT16
*/
MOBLEUINT16 Light_Actual_LinearBinding(void)
{
  
   float productValue;
   MOBLEUINT8 Light_GetBuff[2];
   
  (Appli_Light_GetStatus_cb.GetLightLightness_cb)(Light_GetBuff);
   
   Light_LightnessStatus.PresentValue16 = Light_GetBuff[1] << 8;
   Light_LightnessStatus.PresentValue16 |= Light_GetBuff[0];
   
   productValue = pow((((float)Light_LightnessStatus.PresentValue16)/65535) , 2);
   Light_LightnessStatus.PresentValue16 = (MOBLEUINT16)(65535 * productValue);
   (LightAppli_cb.Lightness_Linear_Set_cb)(&Light_LightnessStatus, 0);
  
    return Light_LightnessStatus.PresentValue16;
  
}

/*
* @Brief Light_Linear_ActualBinding:Function used for binding the data of actual 
*        lightness and linear lightness. this function changes the value of Actual 
*        lightness as Linear lightness value is set.
* @param void 
* return MOBLEUINT16
*/
MOBLEUINT16 Light_Linear_ActualBinding(void)
{
  /*
     6.1.2.1.1 - actual lightness = 655354 * squareroot(linear lightness/ 655354).
  */
   float productValue;
  
   productValue = sqrt((((float)Light_LightnessStatus.PresentValue16) / 65535));
   Light_LightnessStatus.PresentValue16 = (MOBLEUINT16)(65535 * productValue);
   (LightAppli_cb.Lightness_Set_cb)(&Light_LightnessStatus, 0);
    
    return Light_LightnessStatus.PresentValue16;  
}

/*
* @Brief Light_Actual_RangeBinding:Function used for binding the data of actual 
*        lightness and lightness range this function set the value of Actual 
*        lightness according to the min range  and max range value.
* @param lightActual Pointer which needs to be set. 
* return void
*/
void Light_Actual_RangeBinding(Light_LightnessParam_t* lightActual)
{
  /*
     6.1.2.2.5 - actual lightness = range minimum if actual lighteness is less than range min
                value.
                actual lightness = range maximum if actual lighteness is greater than range max
                value.
  */
    MOBLEUINT8 Light_GetBuff[5];
   (Appli_Light_GetStatus_cb.GetLightLightnessRange_cb)(Light_GetBuff);
    Light_LightnessRangeParam.MinRangeStatus = Light_GetBuff[2] << 8;
    Light_LightnessRangeParam.MinRangeStatus |= Light_GetBuff[1];
    Light_LightnessRangeParam.MaxRangeStatus = Light_GetBuff[4] << 8;
    Light_LightnessRangeParam.MaxRangeStatus |= Light_GetBuff[3];
    
   if((lightActual->TargetLightnessStatus < Light_LightnessRangeParam.MinRangeStatus)
         && (lightActual->TargetLightnessStatus != 0))
   {
     lightActual->TargetLightnessStatus = Light_LightnessRangeParam.MinRangeStatus;
   }
   else if((lightActual->TargetLightnessStatus > Light_LightnessRangeParam.MaxRangeStatus)
           && (lightActual->TargetLightnessStatus != 0))
   {
     lightActual->TargetLightnessStatus = Light_LightnessRangeParam.MaxRangeStatus;
   }
   else
   {
     /* no codition to execute */
   }
}

/*Light_CtlTemperature_TempRangeBinding
* @Brief Light_CtlTemperature_TempRangeBinding: Function used for binding the data of 
*        Ctl temperature and Ctl temperature range this function changes the value of 
*        Ctl temperature according to the min range  and max rsnge value.
* @param ctlTempemerature Pointer which needs to be set.  
* return void
*/
void Light_CtlTemperature_TempRangeBinding(Light_CtlParam_t* ctlTempemerature)
{
  /*
     6.1.2.2.5 - actual lightness = range minimum if actual lighteness is less than range min
                value.
                actual lightness = range maximum if actual lighteness is greater than range max
                value.
  */
    MOBLEUINT8 Light_GetBuff[5];
   (Appli_Light_GetStatus_cb.GetLightCtlTempRange_cb)(Light_GetBuff);
    CtlTemperatureRangeParam.MinRangeStatus = Light_GetBuff[2] << 8;
    CtlTemperatureRangeParam.MinRangeStatus |= Light_GetBuff[1];
    CtlTemperatureRangeParam.MaxRangeStatus = Light_GetBuff[4] << 8;
    CtlTemperatureRangeParam.MaxRangeStatus |= Light_GetBuff[3];
    
   if(ctlTempemerature->CTL_Temperature < CtlTemperatureRangeParam.MinRangeStatus)        
   {
     ctlTempemerature->CTL_Temperature = CtlTemperatureRangeParam.MinRangeStatus;
   }
   else if(ctlTempemerature->CTL_Temperature > CtlTemperatureRangeParam.MaxRangeStatus)           
   {
     ctlTempemerature->CTL_Temperature = CtlTemperatureRangeParam.MaxRangeStatus;
   }
   else
   {
     /* no codition to execute */
   }
}

/*
* @Brief  Light_CtlTemp_GenericLevelBinding: Data binding b/w Generic Level and 
*         light lightness Actual. this function will set the actual light lightness
*         value at the time of  generic Level set. 
* @param bCtlTempParam Pointer to the data which needs to be checked.
* return void.
*/
void Light_CtlTemp_GenericLevelBinding(Light_CtlParam_t* bCtlTempParam)
{
   /* 6.1.3.1.1 Binding with the Generic Level state.
       Generic Level = (Light CTL Temperature - T _MIN) * 65535 / (T_MAX - T_MIN) - 32768
       T_MIN = minimum range of ctl temperature
       T_MAX = maximum range of ctl temperature
   */
    Generic_LevelStatus_t bLevelStatus;
    MOBLEUINT32 productValue;
    
    productValue = (bCtlTempParam->CTL_Temperature - 0x0320) * 65535;
    bLevelStatus.Present_Level16 = (productValue / (0x4E20 - 0x0320)) - 32768;
    /* application callback */
    (GenericAppli_cb.Level_Set_cb)(&bLevelStatus, 0); 
}
/**
* @}
*/

/**
* @}
*/

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/


