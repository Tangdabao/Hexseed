/**
******************************************************************************
* @file    generic.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   Generic model middleware file
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
#include "generic.h"
#include "bluenrg_mesh.h"
#include "models_if.h"
#include "appli_generic.h"
#include "common.h"
#include "vendor.h"
#include "mesh_cfg.h"
#include <string.h>


/** @addtogroup MODEL_GENERIC
*  @{
*/

/** @addtogroup Generic_Model_Callbacks
*  @{
*/

/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/


#define PROPERTY_ID     10
#define PROPERTY_VAL    10

/* Private variables ---------------------------------------------------------*/

Generic_TemporaryStatus_t Generic_TemporaryStatus;

Generic_TimeParam_t Generic_TimeParam;

Generic_LevelStatus_t Generic_LevelStatus;
 
Generic_OnOffStatus_t Generic_OnOffStatus;

extern MOBLEUINT8 ProxyFlag;

#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
Generic_BatteryLevelStatus_t BatteryLevelStatus;
#endif
Generic_ModelFlag_t Generic_ModelFlag;

 const MODEL_OpcodeTableParam_t generic_on_off_opcodes[] = {
  /* Generic OnOff Server */
  /*    MOBLEUINT32 opcode, MOBLEBOOL reliable, MOBLEUINT16 min_payload_size, 
    MOBLEUINT16 max_payload_size;
    Here in this array, Handler is not defined; */
       
    {GENERIC_ON_OFF_GET,                                    MOBLE_TRUE,  0, 0,              GENERIC_ON_OFF_STATUS , 1, 3},
    {GENERIC_ON_OFF_SET_ACK,                                MOBLE_TRUE,  2, 4,              GENERIC_ON_OFF_STATUS , 1, 3},  
    {GENERIC_ON_OFF_SET_UNACK,                              MOBLE_FALSE, 2, 4,              NULL, 0, 0},
    {GENERIC_ON_OFF_STATUS,                                 MOBLE_TRUE,  1, 3,              GENERIC_ON_OFF_STATUS , 1, 3},    
     
    /* Generic Level Server */
    {GENERIC_LEVEL_GET,                                     MOBLE_TRUE,  0, 0,              GENERIC_LEVEL_STATUS , 2 , 5}, 
    {GENERIC_LEVEL_SET_ACK,                                 MOBLE_TRUE,  3, 5,              GENERIC_LEVEL_STATUS , 2 , 5},
    {GENERIC_LEVEL_SET_UNACK,                               MOBLE_FALSE,  3, 5,             NULL,  0 , 0},
    {GENERIC_LEVEL_STATUS,                                  MOBLE_TRUE,  2, 5,              GENERIC_LEVEL_STATUS , 2 , 5},
    {GENERIC_LEVEL_DELTA_SET,                               MOBLE_TRUE,  5, 7,              GENERIC_LEVEL_STATUS , 2 , 5},
    {GENERIC_LEVEL_DELTA_SET_UNACK,                         MOBLE_FALSE,  5, 7,             NULL,  0, 0},
    {GENERIC_LEVEL_DELTA_MOVE_SET,                          MOBLE_TRUE,  3, 5,              GENERIC_LEVEL_STATUS , 2 , 5},
    {GENERIC_LEVEL_DELTA_MOVE_SET_UNACK,                    MOBLE_FALSE,  3, 5,             NULL,  0 , 0},
 
#ifdef ENABLE_GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME     
    /* Generic Default Transition Time Server Model  */
    {GENERIC_DEFAULT_TRANSITION_TIME_GET,                   MOBLE_TRUE, 0, 0,               GENERIC_DEFAULT_TRANSITION_TIME_STATUS , 1, 1}, 
    {GENERIC_DEFAULT_TRANSITION_TIME_SET,                   MOBLE_TRUE, 1, 1,               GENERIC_DEFAULT_TRANSITION_TIME_STATUS , 1, 1},
    {GENERIC_DEFAULT_TRANSITION_TIME_SET_UNACK,             MOBLE_FALSE, 1, 1,              NULL ,0 ,0},
    {GENERIC_DEFAULT_TRANSITION_TIME_STATUS,                MOBLE_TRUE,  1, 1 ,             GENERIC_DEFAULT_TRANSITION_TIME_STATUS , 1,1},
#endif  
    
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY     
    /* Generic Battery Server Model  */
    {GENERIC_BATTERY_GET,                                   MOBLE_TRUE,  0, 0,              GENERIC_BATTERY_STATUS , 8 , 8},      
    {GENERIC_BATTERY_STATUS,                                MOBLE_TRUE,  8, 8,              GENERIC_BATTERY_STATUS , 8 , 8},    
#endif
   
};

/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
* @brief  Generic_OnOff_Set: This function is called for both Acknowledged and 
          unacknowledged message
* @param  pOnOff_param: Pointer to the parameters received for message
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_OnOff_Set(const MOBLEUINT8* pOnOff_param, MOBLEUINT32 length)
{
  
  /* 3.2.1.2 Generic OnOff Set 
  OnOff: 1B The target value of the Generic OnOff state 
  TID :  1B Transaction Identifier
  Transition Time: 1B Format as defined in Section 3.1.3. (Optional)
  Delay: 1B Message execution delay in 5 millisecond steps (C.1)
  */
#if !defined(DISABLE_TRACES)
  printf("Generic_OnOff_Set callback received \r\n");
#endif    

  Generic_OnOffParam_t Generic_OnOffParam; 
  
  Generic_OnOffParam.TargetOnOffState = pOnOff_param[0];
  Generic_OnOffParam.Generic_TID = pOnOff_param[1];
  
  if(length > 2)
  {
      /* Transition_Time & Delay_Time Present */
      Generic_OnOffParam.Transition_Time = pOnOff_param[2];
      Generic_OnOffParam.Delay_Time = pOnOff_param[3];
      
      /* Copy the received data in status message which needs
        to be set in application messages
     */
      Generic_OnOffStatus.Target_OnOff =  Generic_OnOffParam.TargetOnOffState;;
      Generic_OnOffStatus.RemainingTime = Generic_OnOffParam.Transition_Time;
      
      /* copy status parameters in Temporary parameters for transition 
         process
      */
      Generic_TemporaryStatus.TargetValue16 = Generic_OnOffStatus.Target_OnOff;
      Generic_TemporaryStatus.RemainingTime = Generic_OnOffStatus.RemainingTime;
      /* Function to calculate time parameters, step resolution
        step size for transition state machine
      */
      Generic_GetStepValue(pOnOff_param[2]);
      
      /*option parameter flag, enable to sent all required parameter in status.*/      
      Generic_ModelFlag.GenericOptionalParam = 1;
      /*Flag to enable the on Off transition state machine */
      Generic_ModelFlag.GenericTransitionFlag = 1;   
  } 
  else
  {
      /* When no optional parameter received, target value will
         be set as present value in application.
      */
       Generic_OnOffStatus.Present_OnOff = Generic_OnOffParam.TargetOnOffState;
  }
#if !defined(DISABLE_TRACES)
  printf("Generic set Present Value 0x%.2x , Target Value 0x%.2x , Remaining Time 0x%.2x \r\n " ,Generic_OnOffStatus.Present_OnOff,
          Generic_OnOffStatus.Target_OnOff, Generic_OnOffStatus.RemainingTime );
#endif 
     /* Application Callback */
     (GenericAppli_cb.OnOff_Set_cb)(&Generic_OnOffStatus, 0);
     /* Binding of data b/w Generic on off and Light lightness Actual model */
     GenericOnOff_LightActualBinding(&Generic_OnOffParam);
     return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_OnOff_Status
* @param  pOnoff_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_OnOff_Status(MOBLEUINT8* pOnOff_status, MOBLEUINT32 *plength)
{
  /* 
  Following is the status message:
  Present OnOff The present value of the Generic OnOff state. 
  Target OnOff The target value of the Generic OnOff state (optional).
  Remaining Time is transition time. 
   
  */
   MOBLEUINT8 Generic_GetBuff[1] ; 
#if !defined(DISABLE_TRACES)
  printf("Generic_OnOff_Status callback received \r\n");
#endif    
   /* Function call back to get the values from application*/
    (Appli_GenericState_cb.GetOnOffStatus_cb)(Generic_GetBuff);
    Generic_OnOffStatus.Present_OnOff = Generic_GetBuff[0];
   
   if((Generic_ModelFlag.GenericOptionalParam == 1) || (Generic_TimeParam.StepValue != 0))
   {   
       *pOnOff_status = Generic_OnOffStatus.Present_OnOff;
       *(pOnOff_status+1) = Generic_OnOffStatus.Target_OnOff;
       *(pOnOff_status+2) = Generic_OnOffStatus.RemainingTime;
       *plength = 3; 
       Generic_ModelFlag.GenericOptionalParam = 0;
   }
   else
   {   /* When no optional parameter received, target value will
         be sent in status message.
      */
       *pOnOff_status = Generic_OnOffStatus.Present_OnOff;
       *plength = 1;
   }
      return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_Level_Set: This function is called for both Acknowledged and 
          unacknowledged message
* @param  plevel_param: Pointer to the parameters received for message
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_Level_Set(const MOBLEUINT8* plevel_param, MOBLEUINT32 length)
{
  /*
  3.2.2.2 Generic Level Set
  Level: 2B The target value of the Generic Level state
  TID :  1B Transaction Identifier
  Transition Time: 1B Format as defined in Section 3.1.3. (Optional)
  Delay:1B Message execution delay in 5 milliseconds steps (C.1)
  */
#if !defined(DISABLE_TRACES)
  printf("Generic_Level_Set callback received \r\n");
#endif  
  Generic_LevelParam_t Generic_LevelParam;
  MOBLEUINT32 setValue;
  
  Generic_LevelParam.TargetLevel = *(MOBLEUINT16*) plevel_param;
  Generic_LevelParam.Generic_TID = plevel_param[2]; 
  
  setValue =  Generic_LevelParam.TargetLevel;
  /* Check for Optional Parameters. */ 
  if(length > 3)
  {
     Generic_LevelParam.Transition_Time = plevel_param[3];
     Generic_LevelParam.Delay_Time = plevel_param[4];
     /* Copy the data into status message which needs to be update in 
       application message.
     */
     Generic_LevelStatus.Target_Level16 = setValue;
     Generic_LevelStatus.RemainingTime = Generic_LevelParam.Transition_Time;
     /* copy status parameters in Temporary parameters for transition 
         process.
     */
     Generic_TemporaryStatus.TargetValue16 = Generic_LevelStatus.Target_Level16;
     Generic_TemporaryStatus.RemainingTime = Generic_LevelStatus.RemainingTime;
     /* Function to calculate time parameters, step resolution
        step size for transition state machine
     */
     Generic_GetStepValue(plevel_param[3]); 
     /*option parameter flag, enable to sent all required parameter in status.*/
 
     /*transition process enable flag. */
     Generic_ModelFlag.GenericTransitionFlag = 2;
  }
  else
  {     
     /* When no optional parameter received, target value will
         be set as present value in application.
     */
     Generic_LevelStatus.Present_Level16= setValue; 
  }  
     Generic_LevelStatus.Last_Present_Level16 = Generic_LevelStatus.Present_Level16;
 
#if !defined(DISABLE_TRACES)
   printf("Present Value 0x%.2x , Target Value 0x%.2x , Remaining Time 0x%.2x \r\n " ,Generic_LevelStatus.Present_Level16,
           Generic_LevelStatus.Target_Level16, Generic_LevelStatus.RemainingTime);
#endif
     /* Application Callback */
     (GenericAppli_cb.Level_Set_cb)(&Generic_LevelStatus, 0); 
     
     /* Binding of Generic level with light lightnes actual */
      GenericLevel_LightActualBinding(&Generic_LevelParam);
     /* Binding of Generic Level data with ctl temperature data */ 
      GenericLevel_CtlTempBinding(&Generic_LevelParam);
        
   return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  Generic_LevelDelta_Set: This function is called for both Acknowledged 
          and unacknowledged message
* @param  plevel_param: Pointer to the parameters received for message
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_LevelDelta_Set(const MOBLEUINT8* plevel_param, MOBLEUINT32 length)
{
  /*
  3.2.2.4 Generic Delta Set
  Delta Level: 4B The Delta change of the Generic Level state
  TID:   1B Transaction Identifier
  Transition Time: 1B Format as defined in Section 3.1.3. (Optional)
  Delay: 1B Message execution delay in 5 milliseconds steps (C.1)
  */
#if !defined(DISABLE_TRACES)
    printf("Generic_LevelDelta_Set callback received \r\n");
#endif 
  Generic_DeltaLevelParam_t Generic_DeltaLevelParam ;
  MOBLEUINT32 delta;
  
  /* Copy the 4Bytes data to local variable */
  delta = (plevel_param[3] << 24);
  delta |= (plevel_param[2] << 16);
  delta |= (plevel_param[1] << 8);
  delta |= (plevel_param[0]);
  Generic_DeltaLevelParam.TargetDeltaLevel32 = delta;
  
  Generic_DeltaLevelParam.Generic_TID = plevel_param[4];
  
  /* Check for Optional Parameters */   
  if(length > 5)
  {
       Generic_DeltaLevelParam.Transition_Time = plevel_param[5];
       Generic_DeltaLevelParam.Delay_Time = plevel_param[6];
      /* Copy the data into status message which needs to be update in 
         application message.
      */ 
       Generic_LevelStatus.Target_Level16 = Generic_LevelStatus.Present_Level16 + 
                                                Generic_DeltaLevelParam.TargetDeltaLevel32;
       Generic_LevelStatus.RemainingTime = Generic_DeltaLevelParam.Transition_Time;
       
       /* copy status parameters in Temporary parameters for transition 
         process.
       */
       Generic_TemporaryStatus.TargetValue16 = Generic_LevelStatus.Target_Level16;
       Generic_TemporaryStatus.RemainingTime = Generic_LevelStatus.RemainingTime;
       /* Function to calculate time parameters, step resolution
        step size for transition state machine.
       */
       Generic_GetStepValue(plevel_param[5]);
       
       /*option parameter flag, enable to sent all required parameter in status.*/ 
       Generic_ModelFlag.GenericOptionalParam = 1;
       
       /*transition process enable flag. */
       Generic_ModelFlag.GenericTransitionFlag = 2;
  }
  else
    {   
      if(Generic_LevelStatus.Last_Level_TID == Generic_DeltaLevelParam.Generic_TID)
      {
         Generic_LevelStatus.Present_Level16 =  Generic_LevelStatus.Last_Present_Level16 
                                                  + Generic_DeltaLevelParam.TargetDeltaLevel32;
      }
      else
      {         
         Generic_LevelStatus.Present_Level16 += Generic_DeltaLevelParam.TargetDeltaLevel32;  
      }
    }
         Generic_LevelStatus.Last_Level_TID = Generic_DeltaLevelParam.Generic_TID;   
      
#if !defined(DISABLE_TRACES)
   printf("Present Value 0x%.2x , Target Value 0x%.2x , Remaining Time 0x%.2x \r\n " ,
           Generic_LevelStatus.Present_Level16,Generic_LevelStatus.Target_Level16, Generic_LevelStatus.RemainingTime);                
#endif   
    /* Application Callback */
   (GenericAppli_cb.LevelDelta_Set_cb)(&Generic_LevelStatus, 0);
   
   return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_LevelMove_Set: This function is called for both 
           Acknowledged and unacknowledged message
* @param  plevel_param: Pointer to the parameters received for message
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_LevelMove_Set(const MOBLEUINT8* plevel_param, MOBLEUINT32 length)
{
  /*
  3.2.2.6 Generic Move Set
  Level: 2B The target value of the Generic Level state
  TID:   1B Transaction Identifier
  Transition Time: 1B Format as defined in Section 3.1.3. (Optional)
  Delay: 1B Message execution delay in 5 milliseconds steps (C.1)
  */
#if !defined(DISABLE_TRACES)
    printf("Generic_LevelMove_Set callback received \r\n");
#endif  
    Generic_LevelMoveParam_t  Generic_LevelMoveParam;
  
   Generic_LevelMoveParam.TargetMoveLevel16  = (plevel_param[1] << 8);
   Generic_LevelMoveParam.TargetMoveLevel16 |= (plevel_param[0]);
   Generic_LevelMoveParam.Generic_TID = plevel_param[2];
  
  /* Check for Optional Parameters */   
  if(length > 3)
  {
     Generic_LevelMoveParam.Transition_Time = plevel_param[3];
     Generic_LevelMoveParam.Delay_Time = plevel_param[4];
     /* Copy the data into status message which needs to be update in 
        application message.
    */ 
     Generic_LevelStatus.Target_Level16 = Generic_LevelStatus.Present_Level16 + 
                                              Generic_LevelMoveParam.TargetMoveLevel16;
     Generic_LevelStatus.RemainingTime = Generic_LevelMoveParam.Transition_Time;
     /* Function to calculate time parameters, step resolution
        step size for transition state machine.
      */
     Generic_GetStepValue(plevel_param[3]);
     /*option parameter flag, enable to sent all required parameter in status.*/
     Generic_ModelFlag.GenericOptionalParam = 1;
     
     /*transition process enable flag. */
     Generic_ModelFlag.GenericTransitionFlag = 2;
  }
  else
  {   
    if(Generic_LevelStatus.Last_Level_TID == Generic_LevelMoveParam.Generic_TID)
    {
       Generic_LevelStatus.Present_Level16 =  Generic_LevelStatus.Last_Present_Level16 
                                                + Generic_LevelMoveParam.TargetMoveLevel16;
    }
    else
    {
       Generic_LevelStatus.Present_Level16 += Generic_LevelMoveParam.TargetMoveLevel16;  
    }
  }    Generic_LevelStatus.Last_Level_TID = Generic_LevelMoveParam.Generic_TID; 
 
#if !defined(DISABLE_TRACES)
   printf("Present Value 0x%.2x , Target Value 0x%.2x , Remaining Time 0x%.2x \r\n " ,Generic_LevelStatus.Present_Level16,
           Generic_LevelStatus.Target_Level16, Generic_LevelStatus.RemainingTime);
#endif
   /* Application Callback */
  (GenericAppli_cb.LevelDeltaMove_Set_cb)(&Generic_LevelStatus, 0); 
   return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_Level_Status
* @param  plevel_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_Level_Status(MOBLEUINT8* plevel_status, MOBLEUINT32 *plength)
{
  /* 
  3.2.2.8 Generic Level Status
  Following is the status message:
  Present Level: 2B The present value of the Generic Level state. 
  Target Level: 2B The target value of the Generic Level state (Optional). 
  Remaining Time: 1B Format as defined in Section 3.1.3 (C.1).
  
  */
      MOBLEUINT8 Generic_GetBuff[2] ;   
#if !defined(DISABLE_TRACES)
  printf("Generic_Level_Status callback received \r\n");
#endif
      /* Function call back to get the values from application*/
      (Appli_GenericState_cb.GetLevelStatus_cb)(Generic_GetBuff);
       Generic_LevelStatus.Present_Level16 = Generic_GetBuff[1] << 8;
       Generic_LevelStatus.Present_Level16 |= Generic_GetBuff[0];
      
       /* checking the transition is in process.
        checking for remaining time is not equal to zero.
       */

   if((Generic_ModelFlag.GenericOptionalParam ==1) || (Generic_TimeParam.StepValue != 0))
   {
      *(plevel_status) = Generic_LevelStatus.Present_Level16;
      *(plevel_status+1) = Generic_LevelStatus.Present_Level16 >> 8;
      *(plevel_status+2) = Generic_LevelStatus.Target_Level16;
      *(plevel_status+3) = Generic_LevelStatus.Target_Level16 >> 8;
      *(plevel_status+4) = Generic_LevelStatus.RemainingTime;
      *plength = 5;
       Generic_ModelFlag.GenericOptionalParam = 0;    
   }
  else
  {
      *(plevel_status) = Generic_LevelStatus.Present_Level16;
      *(plevel_status+1) = Generic_LevelStatus.Present_Level16 >> 8;
      *plength = 2;             
  }
#if !defined(DISABLE_TRACES)
   printf("Generic Level Status value of Present Value 0x%.2x , Target Value 0x%.2x , Remaining Time 0x%.2x \r\n ", 
           Generic_LevelStatus.Present_Level16, Generic_LevelStatus.Target_Level16, Generic_LevelStatus.RemainingTime);
#endif
   
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_TransitionDefaultTime_Set 
* @param  transition_defaultTime_param: Pointer to the Transition Time parameter ,
          which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_TransitionDefaultTime_Set(const MOBLEUINT8 *transitionTime_param , 
                                                                        MOBLEUINT32 length)                   
{
  /* 
  3.2.3.2 Generic Default Transition Time
  Following is the set message:
  Transition Time: Parameter 1B .  
  */
  Generic_TransitionTimeParam_t Generic_TransitionTimeParam; 
  MOBLEUINT8 stepNumValue;
  
  stepNumValue   = (transitionTime_param[0] ) & 0x3F ;
  if(stepNumValue > MAXSTEPVALUE)
  {
#if !defined(DISABLE_TRACES)
		printf("Transition number of steps value is exceeded \r\n");
#endif		
     Generic_TransitionTimeParam.DefalutTransitionTime = 0x3F;
  }
  if((stepNumValue == MINSTEPVALUE) || (stepNumValue <= MAXSTEPVALUE))
  {
    Generic_TransitionTimeParam.DefalutTransitionTime = transitionTime_param[0];
  }

#if !defined(DISABLE_TRACES)
  printf("Generic_TransitionDefaultTime_Set callback received \r\n");
#endif   
  /* Application Callback */
  (GenericAppli_cb.Transit_time_set)(&Generic_TransitionTimeParam,length);
   return MOBLE_RESULT_SUCCESS;
}
                                                           
/**
* @brief  Generic_TransitionDefaultTime_Status
* @param  transitionTime_status: Pointer to the status message, 
*          which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_TransitionDefaultTime_Status(MOBLEUINT8 *transitionTime_status ,
                                                               MOBLEUINT32 *plength)             
{
  /* 
  3.2.3.4 Generic Default Transition Time Status
  Following is the status message:
  Transition Time: 1B is the status parameter. 
  */
     MOBLEUINT8 Generic_GetBuff[1]; 
#if !defined(DISABLE_TRACES)
  printf("Generic_TransitionDefaultTime_Status callback received \r\n");
#endif 
     /* Function call back to get the values from application*/
    (Appli_GenericState_cb.GetTransitionStatus_cb)(Generic_GetBuff);
    *transitionTime_status = Generic_GetBuff[0];
    *plength = 1;
  
   return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic On Power Up set 
* @param  on_PowerUp_param: Pointer to the power up data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_OnPowerUp_Set(const MOBLEUINT8 *on_PowerUp_param , MOBLEUINT32 length) 
{
   /* 
  3.2.4.2 Generic Power On Off Time
  Following is the set message:
  On Power up:1B parameter is received to set the power on off model.  
  */
  Generic_OnPowerUpParam_t Generic_OnPowerUpParam;
#if !defined(DISABLE_TRACES)
  printf("Generic_OnPowerUp callback received \r\n");
#endif 
  
  (GenericAppli_cb.OnPowerUp_Set_cb)(&Generic_OnPowerUpParam, length);
   return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_On PowerUp Status
* @param  OnPowerUp_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_OnPowerUp_Status(MOBLEUINT8 *onPowerUp_status , MOBLEUINT32 *plength) 
{  
  /* 
  3.2.4.4 Generic Default Transition Time Status
  Following is the status message:
  onPowerUp_status: 1B is the status parameter of the Power on off model. 
  */
#if !defined(DISABLE_TRACES)
  printf("Generic_OnPowerUp_Status callback received \r\n");
#endif
 
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Generic_ActualPowerLevel_Set: Set Actual Power level 
* @param  plevel_param: Pointer to the power up data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
MOBLE_RESULT Generic_ActualPowerLevel_Set(const MOBLEUINT8 *plevel_param , MOBLEUINT32 length) 
{
  /*
  3.2.5.2 Generic Power Level Set
  Level: 2B The target value of the Generic Level state
  TID:   1B Transaction Identifier
  Transition Time: 1B Format as defined in Section 3.1.3. (Optional)
  Delay: 1B Message execution delay in 5 milliseconds steps (C.1)
  */
     /* Application Callback */
  (GenericAppli_cb.PowerLevel_Set_cb)(&Generic_PowerLevelStatus, OptionalValid);
    
   return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Generic_ActualPowerLevel_Status: Actual Power level Status 
* @param  plevel_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_ActualPowerLevel_Status(MOBLEUINT8 *plevel_status , 
                                              MOBLEUINT32 *plength)
{
  /* 
  3.2.5.4 Generic Power Level Status
  Following is the status message:
  Present Level: 2B The present value of the Generic Power Level state. 
  Target Level: 2B The target value of the Generic Power Level state (Optional). 
  Remaining Time: 1B Format as defined in Section 3.1.3 (C.1).
  
  */
#if !defined(DISABLE_TRACES)
  printf("Generic_PowerLevel_Status callback received \r\n");
#endif
      
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_LastPowerLevel_Status: Last Power Level Status
* @param  plevel_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_LastPowerLevel_Status(MOBLEUINT8 *plevel_status , 
                                               MOBLEUINT32 *plength)
{
  /* 
  3.2.5.4 Generic Last Power Level  Status
  Following is the status message:
  Power Level: 2B The Last Power Level saved value of the Generic Last Power Level state.  
  */ 
#if !defined(DISABLE_TRACES)
  printf("Generic_LastPowerLevel_Status callback received \r\n");
#endif
     
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_DefaultPower_Set: Default power set  
* @param  plevel_param: Pointer to the power up data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 

MOBLE_RESULT Generic_DefaultPower_Set(const MOBLEUINT8 *plevel_param , 
                                             MOBLEUINT32 length)
{
  /*
  3.2.5.8 Generic Default Power Level Set
  Default Power Level: 2B The target value of the Generic Default Power Level state
  */
  
#if !defined(DISABLE_TRACES)
  printf("Generic_DefaultPower_Set callback received \r\n");
#endif
   /* Application Callback */
  (GenericAppli_cb.PowerDefault_Set_cb)(&Generic_PowerLevelParam , length);
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Generic_DefaultPower_Status: Default Power Status
* @param  plevel_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_DefaultPower_Status(MOBLEUINT8 *plevel_status , 
                                                MOBLEUINT32 *plength)
{
   /* 
  3.2.2.8 Generic Default Power Level Status
  Following is the status message:
  Default Power Level: 2B The present value of the Generic Level state  
  */ 
#if !defined(DISABLE_TRACES)
  printf("Generic_DefaultPower_Status callback received \r\n");
#endif
    
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_PowerRange_Set: Set Power Range  
* @param  pRange_param: Pointer to the power up data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_PowerRange_Set(const MOBLEUINT8 *pRange_param , 
                                                  MOBLEUINT32 length) 
{
  /*
  3.2.5.12 Generic Power Level Range Set
  Range minimum: 2B the minimum power level range is set.
  Range maximum: 2B the minimum power level range is set. 
  */
   
#if !defined(DISABLE_TRACES)
  printf("Generic_PowerRange_Set callback received \r\n");
#endif
   /* Application Callback */
  (GenericAppli_cb.PowerRange_Set_cb)(&powerRange , length);
  
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Generic_PowerRange_Status
* @param  pRange_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_PowerRange_Status(MOBLEUINT8 *pRange_status , 
                                              MOBLEUINT32 *plength)
{
  /* 
  3.2.5.14 Generic Power level Range Status
  Following is the status message:
  Status code: 1B The status code for the range set success or unsuccess.. 
  Range minimum: 2B the minimum power level range is set.
  Range maximum: 2B the minimum power level range is set. 
  */  
#if !defined(DISABLE_TRACES)
  printf("Generic_PowerRange_Status callback received \r\n");
#endif
      
  return MOBLE_RESULT_SUCCESS;   
}
#endif

/**
* @brief  Generic_Battery_Level_Status: Battery Level Status 
* @param  p_blevel_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY  
MOBLE_RESULT Generic_BatteryLevel_Status(MOBLEUINT8* p_blevel_status , 
                                                 MOBLEUINT32 *plength)
{
  
#if !defined(DISABLE_TRACES)
  printf("Generic_BatteryLevel_Status callback received \r\n");
#endif
    /* Function call back to get the values from application*/
    (Appli_GenericState_cb.GetBatteryLevelStatus_cb)(Appli_Param);
    
     *p_blevel_status = Appli_Param[0];
    *(p_blevel_status+1) = Appli_Param[1];
    *(p_blevel_status+2) = Appli_Param[2];
    *(p_blevel_status+3) = Appli_Param[3];
    *(p_blevel_status+4) = Appli_Param[4];
    *(p_blevel_status+5) = Appli_Param[5];
    *(p_blevel_status+6) = Appli_Param[6];
    *(p_blevel_status+7) = Appli_Param[7];
       
  return MOBLE_RESULT_SUCCESS;   
}
#endif

/**
* @brief  Generic_GlobalLocation_Set: Set Global location  
* @param  plocation_param: Pointer for Global location set , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_GlobalLocation_Set(const MOBLEUINT8 *plocation_param , 
                                                         MOBLEUINT32 length)
{
  /*
  3.2.7.2 Generic Global Location Set
  Global Latitude: 4B The global coordinates latitude is set.
  Global Longitude: 4B The global coordinates Longitude is set.
  Global Altitude: 2B The global coordinates Altitude is set.
  */   
   
#if !defined(DISABLE_TRACES)
  printf("Generic_GlobalLocation_Set callback received \r\n");
#endif

  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_GlobalLocation_status: Global location status
* @param  plocation_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_GlobalLocation_Status(MOBLEUINT8* plocation_status , 
                                                     MOBLEUINT32 *plength)
{
  /* 
  3.2.7.4 Generic Global Location Status
  Following is the status message:
  Global Latitude: 4B the Global Latitude value of global location status message.
  Global Longitude: 4B the Global Longitude value of global location status messag.
  Global Altitude: 2B the Global Altitude value of global location status message
  Remaining Time: 1B Format as defined in Section 3.1.3 (C.1). 
  */

#if !defined(DISABLE_TRACES)
  printf("Generic_GlobalLocation_status callback received \r\n");
#endif
   
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_LocationLocal_Set: Local location set  
* @param  p_locallocation_param: Pointer for Global location set , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_LocationLocal_Set(const MOBLEUINT8 *p_locallocation_param , 
                                                         MOBLEUINT32 length)
{
  /*
  3.2.7.6 Generic Local Location Set
  Local North: 2B The Local North Coordinates Value is set.
  Local East: 2B The Local east Coordinates Value is set.
  Local Altitude: 2B The Local altitude Coordinates Value is set.
  Local Floor: number 1B The Local floor number Value is set.
  Uncertainity: 2B The uncertainity Value is set.
  */
   
#if !defined(DISABLE_TRACES)
  printf("Generic_LocationLocal_Set callback received \r\n");
#endif
   
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_LocalLocation_status: Local Location Status
* @param  p_locallocation_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_LocalLocation_Status(MOBLEUINT8* p_locallocation_status , 
                                                     MOBLEUINT32 *plength)
{
  /* 
  3.2.7.8 Generic Local location  Status
  Following is the status message:
  Local North: 2B The Local North Coordinates Value for local location status.
  Local East: 2B The Local east Coordinates Value for local location status.
  Local Altitude: 2B The Local altitude Coordinates Value for local location status.
  Local Floor: number 1B The Local floor number Value for local location status.
  Uncertainity: 2B The uncertainity Value for local location status. 
  */  
#if !defined(DISABLE_TRACES)
  printf("Generic_LocalLocation_status callback received \r\n");
#endif
  
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_UserProperty_Set: Generic User Property set 
* @param  p_uProperty_param: Pointer to the user property data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_UserProperty_Set(const MOBLEUINT8 *p_uProperty_param , 
                                                        MOBLEUINT32 length)
{
  /*
  3.2.8.4 Generic User Property Set
  User ID: 2B The User Id value is set for the user property.
  User Property Value: The user property value is set for the user property.
                       raw value for user property.
  */
 
#if !defined(DISABLE_TRACES)
  printf("Generic_UserProperty_Set callback received \r\n");
#endif
 
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Generic_UserProperty_status: User property status
* @param  p_uProperty_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_UserProperty_Status(MOBLEUINT8 *p_uProperty_status , 
                                                    MOBLEUINT32 *plength)
{ 
   /* 
  3.2.8.6 Generic User Property Status
  Following is the status message:
  User ID: 2B The User Id value is status parameter for user property.
  User Access: 1B The User Access value is status parameter for user property.(optional)
  user property value: The user property value is status parameter for the user property(C1).
  */
 
#if !defined(DISABLE_TRACES)
  printf("Generic_UserProperty_status callback received \r\n");
#endif
 
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_AdminProperty_Set: Admin Property Set 
* @param  a_Property_param: Pointer to the admin property data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_AdminProperty_Set(const MOBLEUINT8 *p_aProperty_param , 
                                                         MOBLEUINT32 length) 
{
  /*
  3.2.8.10 Generic Admin Property Set
  Admin Property ID: 2B The User Id value is set for the user property.
  Admin User Access: 1B Indicating User access.
  Admin Property Value: The user property value is set for the user property.
                       raw value for user property.
  */
  
#if !defined(DISABLE_TRACES)
  printf("Generic_AdminProperty_Set callback received \r\n");
#endif
 
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Generic_AdminProperty_status: Admin property status
* @param  a_Property_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_AdminProperty_Status(MOBLEUINT8 *p_aProperty_status , 
                                                     MOBLEUINT32 *plength)
{
  /* 
  3.2.8.8 Generic Admin Property Status
  Following is the status message:
  Admin Property ID: 2B The User Id value is status parameter for Admin property.
  Admin Access: 1B The User Access value is status parameter for Admin property.(optional)
  Admin Property Value: The user property value is status parameter for the Admin property(C1).
  */       
#if !defined(DISABLE_TRACES)
  printf("Generic_AdminProperty_status callback received \r\n");
#endif
 
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_ManufacturerProperty_Set 
* @param  p_mProperty_param: Pointer to the user property data , which needs to be set
* @param  length: Length of the parameters received for message
* @retval MOBLE_RESULT
*/ 

MOBLE_RESULT Generic_ManufacturerProperty_Set(const MOBLEUINT8 *p_mProperty_param , 
                                                             MOBLEUINT32 length)  
{
   /*
  3.2.8.16 Generic Manufacturer Property Set
  Manufacturer Property ID: 2B The User Id value is set for the Manufacturer property.
  Manufacturer User Access: 1B Indicating Manufacturer access.
  */
  
#if !defined(DISABLE_TRACES)
  printf("Generic_ManufacturerProperty_Set callback received \r\n");
#endif
   /* Application Callback */
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Generic_ManufacturerProperty_status: Manufacturer Property status
* @param  p_mProperty_status: Pointer to the status message, which needs to be updated
* @param  plength: Pointer to the Length of the Status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_ManufacturerProperty_Status(MOBLEUINT8 *p_mProperty_status , 
                                                           MOBLEUINT32 *plength)
{
   /* 
  3.2.8.18 Generic Manufacturer Property Status
  Following is the status message:
  Manufacturer Property ID: 2B The Manufacturer Id value is status parameter for 
                             Manufacturer property.
  Manufacturer User Access: 1B The Manufacturer Access value is status parameter 
                               for Manufacturer property.(optional)
  Manufacturer Property Value: Variable The Manufacturer property value is status
                                parameter for the user property(C1).
  */     
#if !defined(DISABLE_TRACES)
  printf("Generic_ManufacturerProperty_status callback received \r\n");
#endif
   
  return MOBLE_RESULT_SUCCESS;   
}

/**
* @brief  Generic_BatteryLevel_Validity: This function if to check the validity of range
*         of battery level
* @param  battery_value: battery level Parameter for the function 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_BatteryLevel_Validity(MOBLEUINT8 battery_value)
{
  MOBLE_RESULT status;
  if(battery_value <= MAX_BATTERY_LEVEL)
  {
    status = MOBLE_RESULT_SUCCESS;
  }
  else if((battery_value >= PROHIBITED_MIN_BATTERY_LEVEL) && 
                       (battery_value <= PROHIBITED_MAX_BATTERY_LEVEL ))
  {
    status = MOBLE_RESULT_FAIL;
  }
  else if(battery_value == UNKNOWN_BATTERY_LEVEL)
  {
    status =  MOBLE_RESULT_FAIL;
  }
  return status;
}

/**
* @brief  Generic_BatteryDischargeTime_Validity: This function if to check the validity
*        of range of time to discharge time of battery
* @param  discharge_time: time of discharge Parameter for the function 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_BatteryDischargeTime_Validity(MOBLEUINT32 discharge_time)
{
  MOBLE_RESULT status;
  if(discharge_time <= BATTERY_VALID_DISCHARGE_TIME)
  {
    status = MOBLE_RESULT_SUCCESS;
  }
  else if(discharge_time == BATTERY_UNKLNOWN_DISCHARGE_TIME )
  {
    status = MOBLE_RESULT_FAIL;
  }
  return status;
}

/**
* @brief  Generic_BatteryChargeTime_Validity: This function if to check the validity
*         of range of time to charge time of battery
* @param  charge_time: time of charge Parameter for the function 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Generic_BatteryChargeTime_Validity(MOBLEUINT32 charge_time)
{
  MOBLE_RESULT status;
  if(charge_time <= BATTERY_VALID_CHARGE_TIME)
  {
    status = MOBLE_RESULT_SUCCESS;
  }
  else if(charge_time == BATTERY_UNKLNOWN_CHARGE_TIME )
  {
    status = MOBLE_RESULT_FAIL;
  }
  return status;
}

/**
* @brief  Generic_Battery_CheckPresence: This function if to check the validity
          the presence of battery and set the bit accordingly
* @param  flag_param: parameter is Predefined value by user  
* @retval MOBLEUINT8
*/
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
MOBLEUINT8 Generic_Battery_CheckPresence(MOBLEUINT8 flag_param)
{
  
  if(BatteryLevelStatus.IsBatteryPresent == BATTERY_ABSENT)
  {
     flag_param &= ~(1 << 0) ;                   /* reset the 0th bit of byte */
     flag_param &= ~(1 << 1) ;                   /* reset the 1st bit of byte*/
  }
  else if(BatteryLevelStatus.IsBatteryPresent == BATTERY_PRESENT_REMOVABLE)
  {
     flag_param |=  (1 << 0) ;                   /* set the 0th bit of byte*/
     flag_param &= ~(1 << 1) ;                   /* reset the 1th bit of byte*/
  }
  else if(BatteryLevelStatus.IsBatteryPresent == BATTERY_PRESENT_NON_REMOVABLE)
  {
     flag_param &= ~(1 << 0) ;                  /* reset the 0th bit of byte*/
     flag_param |=  (1 << 1) ;                  /* set the 1st bit of byte*/
  }
  else if(BatteryLevelStatus.IsBatteryPresent == BATTERY_UNKNOWN)
  {
     flag_param |=  (1 << 0) ;                 /* set the 0th bit of byte*/
     flag_param |=  (1 << 1) ;                 /* set the 01st bit of byte*/
  }
     return flag_param;  
}
#endif
/**
* @brief  Generic_Battery_CheckIndication: This function if to check the battery 
          level left and set the bit accordingly
* @param  flag_param: parameter is Level of the battery  
* @retval MOBLEUINT8
*/ 
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
MOBLEUINT8 Generic_Battery_CheckIndication(MOBLEUINT8 flag_param)
{
  
  if(BatteryLevelStatus.BatteryLevel <= 15)
  {
     flag_param &= ~(1 << 2) ;                   /* reset the 2nd bit of byte */
     flag_param &= ~(1 << 3) ;                   /* reset the 3rd bit of byte */
  }
  else if((BatteryLevelStatus.BatteryLevel >=16) && (BatteryLevelStatus.BatteryLevel <=25))
  {
     flag_param |= (1 << 2) ;                    /* set the 2nd bit of byte */
     flag_param &= ~(1 << 3) ;                   /* reset the 3rd bit of byte */
  }
  else if((BatteryLevelStatus.BatteryLevel >=26) && (BatteryLevelStatus.BatteryLevel <=100))
  {
     flag_param &= ~(1 << 2) ;                  /* reset the 2nd bit of byte */
     flag_param |=  (1 << 3) ;                  /* set the 3rd bit of byte */
  }
  else 
  {
     flag_param |=  (1 << 2) ;                  /* set the 2nd bit of byte */
     flag_param |=  (1 << 3) ;                  /* set the 3rd bit of byte */
  }
     return flag_param;  
}
#endif

/**
* @brief  Generic_Battery_CheckChargeable: This function if to check the 
* @param  flag_param: parameter is Level of the battery  
* @retval MOBLEUINT8
*/
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
MOBLEUINT8 Generic_Battery_CheckChargeable( MOBLEUINT8 flag_param)
{
   
  if(BatteryLevelStatus.IsChargeable == BATTERY_NOT_CHARGEABLE)
  {
     flag_param &= ~(1 << 4) ;                /* reset the 4th bit of byte */ 
     flag_param &= ~(1 << 5) ;                /* reset the 5th bit of byte */
  }
  else if(BatteryLevelStatus.IsChargeable == BATTERY_NOT_CHARGING)
  {
     flag_param |= (1 << 4) ;                 /* set the 4th bit of byte */
     flag_param &=  ~(1 << 5) ;               /* reset the 5th bit of byte */
  }
  else if(BatteryLevelStatus.IsChargeable == BATTERY_IS_CHARGING)
  {
     flag_param &= ~(1 << 4) ;                /* reset the 4th bit of byte */
     flag_param |=  (1 << 5) ;                /* set the 5th bit of byte */
  }
  else if(BatteryLevelStatus.IsChargeable == BATTERY_CHARGING_UNKNOWN)
  {
     flag_param |=  (1 << 4) ;               /* set the 4th bit of byte */
     flag_param |=  (1 << 5) ;               /* set the 5th bit of byte */
  }
  return flag_param;  
}
#endif

/**
* @brief  Generic_Battery_CheckServiceable: This function if to check the condition for 
          battery servicing and set the bit accordingly
* @param  flag_param: parameter is Level of the battery  
* @retval MOBLEUINT8
*/ 
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
MOBLEUINT8 Generic_Battery_CheckServiceable(MOBLEUINT8 flag_param)
{
  
  if(BatteryLevelStatus.IsServiceable == BATTERY_SERVICE_RFU)
  {
     flag_param &= ~(1 << 6) ;              /* reset the 6th bit of byte */
     flag_param &= ~(1 << 7) ;              /* reset the 7th bit of byte */
  }
  else if(BatteryLevelStatus.IsServiceable == BATTERY_REQUIRE_NO_SERVICE)
  {
     flag_param |= (1 << 6) ;               /* set the 6th bit of byte */
     flag_param &= ~(1 << 7) ;              /* reset the 7th bit of byte */
  }
  else if(BatteryLevelStatus.IsServiceable == BATTERY_REQUIRE_SERVICE)
  {
     flag_param &= ~(1 << 6) ;              /* reset the 6th bit of byte */
     flag_param |= (1 << 7) ;               /* set the 7th bit of byte */
  }
  else if(BatteryLevelStatus.IsServiceable == BATTERY_SERVICE_UNKNOWN)
  {
     flag_param |= (1 << 6) ;               /* set the 6th bit of byte */
     flag_param |= (1 << 7) ;               /* set the 7th bit of byte */
  }
  return flag_param;  
}
#endif

/*
* @brief  BluenrgMesh_AddGenericModels
* @param  Function adds all the sub model of generic model. this function 
*         uses Mid of the particular model for adding.
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT BluenrgMesh_AddGenericModels(void)
{
  MOBLE_RESULT result = MOBLE_RESULT_SUCCESS;
  

#ifdef ENABLE_GENERIC_MODEL_SERVER_ONOFF   
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_ONOFF_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  } 
#endif    


#ifdef ENABLE_GENERIC_MODEL_SERVER_LEVEL   
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_LEVEL_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }
#endif   


#ifdef ENABLE_GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME  
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }
#endif   


#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF   
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_POWER_ONOFF_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }  
#endif 


#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF_SETUP 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_POWER_ONOFF_SETUP_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }  
  
#endif  


#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_POWER_LEVEL_MODEL_ID)))
  {

#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }  
#endif

#ifdef MOBLE_GENERIC_POWERLEVEL_SERVERSETUP_MODEL 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_POWER_LEVEL_SETUP_MODEL_ID)))
  {

#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }  

#endif  


#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_BATTERY_MODEL_ID)))
  {

#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }  
#endif   


#ifdef ENABLE_GENERIC_MODEL_SERVER_LOCATION 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_LOCATION_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  }  
#endif  


#ifdef ENABLE_GENERIC_MODEL_SERVER_LOCATION_SETUP 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_LOCATION_SETUP_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  } 
#endif    


#ifdef ENABLE_GENERIC_MODEL_SERVER_ADMIN_PROPERTY 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_ADMIN_PROPERTY_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  } 
#endif   


#ifdef ENABLE_GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES)
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  } 
#endif  
  

#ifdef ENABLE_GENERIC_MODEL_SERVER_USER_PROPERTY 
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_USER_PROPERTY_MODEL_ID)))
  {
#if !defined(DISABLE_TRACES) 
    printf("Failed to add Generic On Off Model \n\r");
#endif		
    result = MOBLE_RESULT_FAIL;
  } 
#endif   

#ifdef MOBLE_GENERIC_CLIENTPROPERTY_MODEL
  if(MOBLE_FAILED(GenericModel_Add_Server(GENERIC_MODEL_SERVER_CLIENT_PROPERTY_MODEL_ID)))
  {
    printf("Failed to add Generic On Off Model \n\r");
    result = MOBLE_RESULT_FAIL;
  } 
#endif   
     return result;    
}
/**
* @brief   GenericModelServer_GetOpcodeTableCb: This function is call-back 
*          from the library to send Model Opcode Table info to library
* @param  MODEL_OpcodeTableParam_t:  Pointer to the Generic Model opcode array 
* @param  length: Pointer to the Length of Generic Model opcode array
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT GenericModelServer_GetOpcodeTableCb(const MODEL_OpcodeTableParam_t **data, 
                                    MOBLEUINT16 *length)
{
  *data = generic_on_off_opcodes;
  *length = sizeof(generic_on_off_opcodes)/sizeof(generic_on_off_opcodes[0]);

  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  GenericModelServer_GetStatusRequestCb : This function is call-back 
          from the library to send response to the message from peer
* @param  peer_addr: Address of the peer
* @param  dst_peer: destination send by peer for this node. It can be a
*                                                     unicast or group address 
* @param  opcode: Received opcode of the Status message callback
* @param  pResponsedata: Pointer to the buffer to be updated with status
* @param  plength: Pointer to the Length of the data, to be updated by application
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT GenericModelServer_GetStatusRequestCb(MOBLE_ADDRESS peer_addr, 
                                    MOBLE_ADDRESS dst_peer, 
                                    MOBLEUINT16 opcode, 
                                    MOBLEUINT8 *pResponsedata, 
                                    MOBLEUINT32 *plength, 
                                    MOBLEBOOL response)
{
  switch(opcode)
  {
  case GENERIC_ON_OFF_STATUS:
    {
#ifdef ENABLE_GENERIC_MODEL_SERVER_ONOFF       
      Generic_OnOff_Status(pResponsedata, plength);      
#endif   
      break;
    }
    
  case GENERIC_LEVEL_STATUS:
    {
  
#ifdef ENABLE_GENERIC_MODEL_SERVER_LEVEL    
      Generic_Level_Status(pResponsedata, plength);
#endif      
      break;
    }
  case GENERIC_DEFAULT_TRANSITION_TIME_STATUS:
    {
         
#ifdef ENABLE_GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME          
      Generic_TransitionDefaultTime_Status(pResponsedata ,plength);
#endif
      break;
    }
  case GENERIC_ONPOWERUP_STATUS:
    {
     
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF       
      Generic_OnPowerUp_Status(pResponsedata ,plength);
#endif
      break;
    }
  case GENERIC_POWER_LEVEL_STATUS:
    {
    
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL       
      Generic_ActualPowerLevel_Status(pResponsedata ,plength);                                                 
#endif
      break;
    }
  case GENERIC_POWER_LAST_STATUS:
    {
    
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL      
      Generic_LastPowerLevel_Status(pResponsedata ,plength);
#endif
      break;
    }
  case GENERIC_POWER_DEFAULT_STATUS:
    {
      
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL       
      Generic_DefaultPower_Status(pResponsedata ,plength);
#endif      
      break;
    }
  case GENERIC_POWER_RANGE_STATUS:
    {
     
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL       
      Generic_PowerRange_Status(pResponsedata ,plength);
#endif
      break;
    }
  case GENERIC_BATTERY_STATUS:
    {
   
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY     
      Generic_BatteryLevel_Status(pResponsedata , plength);                                                 
#endif      
      break;
    }
  case GENERIC_LOCATION_GLOBAL_STATUS:
    {
      
#ifdef ENABLE_GENERIC_MODEL_SERVER_LOCATION       
      Generic_GlobalLocation_Status(pResponsedata ,plength);
#endif      
      break;
    }
  case GENERIC_LOCATION_LOCAL_STATUS:
    {
 
#ifdef ENABLE_GENERIC_MODEL_SERVER_LOCATION      
      Generic_LocalLocation_Status(pResponsedata ,plength);
#endif  
      break;
    }
  case GENERIC_USER_PROPERTY_STATUS:
    {
     
#ifdef ENABLE_GENERIC_MODEL_SERVER_USER_PROPERTY      
      Generic_UserProperty_Status(pResponsedata ,plength);
#endif
      break;
    }
  case GENERIC_ADMIN_PROPERTY_STATUS:
    {
     
#ifdef ENABLE_GENERIC_MODEL_SERVER_ADMIN_PROPERTY      
      Generic_AdminProperty_Status(pResponsedata ,plength);
#endif
      break;
    }
  case GENERIC_MANUFACTURER_PROPERTY_STATUS:
    {
      
#ifdef ENABLE_GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY       
      Generic_ManufacturerProperty_Status(pResponsedata ,plength);
#endif      
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
* @brief  GenericModelServer_ProcessMessageCb: This is a callback function from
           the library whenever a Generic Model message is received
* @param  peer_addr: Address of the peer
* @param  dst_peer: destination send by peer for this node. It can be a
*                                                     unicast or group address 
* @param  opcode: Received opcode of the Status message callback
* @param  pData: Pointer to the buffer to be updated with status
* @param  length: Length of the parameters received 
* @param  response: if TRUE, the message is an acknowledged message 
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT GenericModelServer_ProcessMessageCb(MOBLE_ADDRESS peer_addr, 
                                    MOBLE_ADDRESS dst_peer, 
                                    MOBLEUINT16 opcode, 
                                    MOBLEUINT8 const *pData, 
                                    MOBLEUINT32 length, 
                                    MOBLEBOOL response
                                    )
{

  MOBLE_RESULT result = MOBLE_RESULT_SUCCESS;
  tClockTime delay_t = Clock_Time();
  
  switch(opcode)
  {
    case GENERIC_ON_OFF_GET:
    case GENERIC_ON_OFF_STATUS:
      {
        
        /* Callback of GenericModelServer_GetStatusRequestCb will be called */
        break;
      }   
    case GENERIC_ON_OFF_SET_ACK:
    case GENERIC_ON_OFF_SET_UNACK:
      {

        result = Chk_ParamValidity(pData[0], 1); 
        /* 3.1.1 Generic OnOff 0x02–0xFF Prohibited */
        /* 3.2.1.2 Generic OnOff Set If the Transition Time field is present, 
        the Delay field shall also be present; otherwise these fields shall 
        not be present*/
      
        /* 3.2.1.2 Generic OnOff Set 
        Check if Transition Time field is present or Not,
        If present, Only values of 0x00 through 0x3E shall be used to specify 
        the value of the Transition Number of Steps field. */

        result |= Chk_OptionalParamValidity (length, 2, (pData[2]&0x3F), 0x3E );        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          /*
           when device is working as proxy and is a part of node
           delay will be included in the toggelinf of led.
          */
          if((ProxyFlag == 1) && (ADDRESS_IS_GROUP(dst_peer)))
          {
            while ((Clock_Time() - delay_t) < 100); 
          }
            Generic_OnOff_Set(pData, length);   
        }
        
        break;
      }
  
    case GENERIC_LEVEL_SET_ACK:
    case GENERIC_LEVEL_SET_UNACK: 
      {   
       
        result = Chk_ParamMinMaxValidity(0X00 ,pData , 0xFFFF );        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Generic_Level_Set(pData, length);   
        }
       
        break;
      }
    
    case GENERIC_LEVEL_DELTA_SET:
    case GENERIC_LEVEL_DELTA_SET_UNACK:
      { 
        /*
        Delta Level 4 The Delta change of the Generic Level state 
        TID 1 Transaction Identifier 
        Transition Time 1 Format as defined in Section 3.1.3. (Optional) 
        Delay 1 Message execution delay in 5 milliseconds steps (C.1)
        */
       
        result = Chk_ParamMinMaxValidity(0X00 ,pData , 0xFFFF );        
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Generic_LevelDelta_Set(pData, length);
        }
        break;
      }
      
    case GENERIC_LEVEL_DELTA_MOVE_SET:
    case GENERIC_LEVEL_DELTA_MOVE_SET_UNACK:
      {    
       
        result = Chk_ParamMinMaxValidity(0X00 ,pData , 0xFFFF );       
        if(result == MOBLE_RESULT_SUCCESS)
        {
        Generic_LevelMove_Set(pData, length); 
        }
        break;
      }
    case GENERIC_DEFAULT_TRANSITION_TIME_SET:
    case GENERIC_DEFAULT_TRANSITION_TIME_SET_UNACK: 
      {
 
#ifdef ENABLE_GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME 
 
        result = Chk_ParamValidity ((pData[0]&0x3F), 0x3E );
        if(result == MOBLE_RESULT_SUCCESS)
        {
          Generic_TransitionDefaultTime_Set(pData, length);
        }
 
#endif        
        break;
      }
    case GENERIC_ONPOWERUP_SET:  
    case GENERIC_ONPOWERUP_SET_UNACK: 
      {
       
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF         
        Generic_OnPowerUp_Set(pData, length);
#endif        
        break;
      }
    case GENERIC_POWER_LEVEL_SET:
    case GENERIC_POWER_LEVEL_SET_UNACK:
      {
     
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL       
        Generic_ActualPowerLevel_Set(pData, length);
#endif        
        break;
      }
    case GENERIC_POWER_DEFAULT_SET:
    case GENERIC_POWER_DEFAULT_SET_UNACK:
      {
      
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL       
        Generic_DefaultPower_Set(pData, length);
#endif
        break;
      }
    case GENERIC_POWER_RANGE_SET:
    case GENERIC_POWER_RANGE_SET_UNACK:
      {
        
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL        
        Generic_PowerRange_Set(pData, length);
#endif
        break;
      }
    case GENERIC_LOCATION_GLOBAL_SET:
    case GENERIC_LOCATION_GLOBAL_SET_UNACK:
      {
         
#ifdef ENABLE_GENERIC_MODEL_SERVER_LOCATION_SETUP         
        Generic_GlobalLocation_Set(pData, length);
#endif
        break;
      }
    case GENERIC_LOCATION_LOCAL_SET:
    case GENERIC_LOCATION_LOCAL_SET_UNACK:
      {
        
#ifdef ENABLE_GENERIC_MODEL_SERVER_LOCATION_SETUP        
        Generic_LocationLocal_Set(pData, length);
#endif
        break;
      }
    case GENERIC_USER_PROPERTY_SET:
    case GENERIC_USER_PROPERTY_SET_UNACK:
      {
      
#ifdef ENABLE_GENERIC_MODEL_SERVER_USER_PROPERTY         
        Generic_UserProperty_Set(pData , length);
#endif
        break;
      }
    case GENERIC_ADMIN_PROPERTY_SET:
    case GENERIC_ADMIN_PROPERTY_SET_UNACK:
      {
             
#ifdef ENABLE_GENERIC_MODEL_SERVER_ADMIN_PROPERTY             
        Generic_AdminProperty_Set(pData, length);
#endif        
        break;
      }
    case GENERIC_MANUFACTURER_PROPERTY_SET:
    case GENERIC_MANUFACTURER_PROPERTY_SET_UNACK:
      {
      
#ifdef ENABLE_GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY       
        Generic_ManufactureProperty_Set(pData, length);
#endif        
        break;
      }
  default:
    {
      break;
    }          
  } /* Switch ends */
  

  if((result == MOBLE_RESULT_SUCCESS) && (response == MOBLE_TRUE))
  {
    Generic_SendResponse(peer_addr, dst_peer,opcode, length);
  }
  return MOBLE_RESULT_SUCCESS;
}


/* @Brief  Generic_OnOffTransitionBehaviour: Generic On Off Transition behaviour 
*          used for the Generic On Off model when transition time is received in
           message.        
* @param GetValue Pointer of the array
* @retval MOBLE_RESULT
*/
MOBLE_RESULT Generic_OnOffTransitionBehaviour(MOBLEUINT8 *GetValue)
{
  
  static MOBLEUINT8 Clockflag = 0;
  static MOBLEUINT32 Check_time;
  
  /* Taking the time stamp for particular time */
  if(Clockflag == 0)
  {
    Check_time = Clock_Time();
    Clockflag = 1;
  }
   /* Values from application are copied into Temporary vaiables for processing */
  
   Generic_TemporaryStatus.PresentValue16 = GetValue[0];
  
    /*if condition to wait untill the time is equal to the given resolution time */
   if(((Clock_Time()- Check_time) >= Generic_TimeParam.Res_Value))
   {     
        
      if(Generic_TimeParam.StepValue == 0)
      {
        Generic_TimeParam.StepValue = 1;
      }
        Generic_TimeParam.StepValue--;
        
        Generic_TemporaryStatus.PresentValue16 = Generic_TemporaryStatus.TargetValue16;
        
        /* updating the remaining time after each step covered*/
        Generic_TemporaryStatus.RemainingTime = Generic_TimeParam.StepValue | (Generic_TimeParam.ResBitValue << 6) ;
     
        Check_time = 0;
        Clockflag = 0;
        /* when transition is completed, disable the transition by disabling 
           transition flag
        */
        if(Generic_TimeParam.StepValue <= 0)
        {
          Generic_ModelFlag.GenericTransitionFlag = 0;           
        }
#if !defined(DISABLE_TRACES)         
      printf("Inside virtual application at %d, Current state 0x%.2x, Target state 0x%.2x, Remaining Time 0x%.2x \n\r", 
             Clock_Time(), Generic_TemporaryStatus.PresentValue16,Generic_TemporaryStatus.TargetValue16,Generic_TemporaryStatus.RemainingTime);  
#endif                    
    }
return MOBLE_RESULT_SUCCESS;       

} 

/* Generic_LevelTransitionBehaviour: This funtion is used for the Generic Level 
*                                    and Power Level model when transition time is 
*                                    received in message.
* @param GetValue Pointer of the array
* @retval MOBLE_RESULT
*/
MOBLE_RESULT Generic_LevelTransitionBehaviour(MOBLEUINT8 *GetValue)
{
  
  static MOBLEUINT8 Clockflag = 0;
  static MOBLEUINT32 Check_time;
  MOBLEUINT16 targetRange;
  MOBLEUINT16 targetSlot;
  /* Taking the time stamp for particular time */
  if(Clockflag == 0)
  {
    Check_time = Clock_Time();
    Clockflag = 1;
  }
   /* Values from application are copied into Temporary vaiables for processing */
    Generic_TemporaryStatus.PresentValue16  = GetValue[1] << 8;
    Generic_TemporaryStatus.PresentValue16 |= GetValue[0];
   /*if condition to wait untill the time is equal to the given resolution time */
   if(((Clock_Time()- Check_time) >= Generic_TimeParam.Res_Value) )
   {   
      if(Generic_TimeParam.StepValue == 0)
      {
        Generic_TimeParam.StepValue = 1;
      }
      if(Generic_TemporaryStatus.TargetValue16 > Generic_TemporaryStatus.PresentValue16)
      {
         /* target range = total range to be covered */
         targetRange = Generic_TemporaryStatus.TargetValue16 - Generic_TemporaryStatus.PresentValue16; 
         /*target slot = time to cover in single step */
         targetSlot = targetRange/Generic_TimeParam.StepValue; 
         /* target slot added to present value to achieve target value */
         Generic_TemporaryStatus.PresentValue16 += targetSlot;             
      }              
      else
      {  
        /* condition execute when transition is negative */
        /* target range = total range to be covered */ 
         targetRange = Generic_TemporaryStatus.PresentValue16 - Generic_TemporaryStatus.TargetValue16;
         /*target slot = time to cover in single step */
         targetSlot = targetRange/Generic_TimeParam.StepValue;
         /*target slot = time to cover in single step */
         Generic_TemporaryStatus.PresentValue16 -= targetSlot;
      }     
         Generic_TimeParam.StepValue--;
         /* updating the remaining time after each step covered*/
         Generic_TemporaryStatus.RemainingTime  = Generic_TimeParam.StepValue | (Generic_TimeParam.ResBitValue << 6) ;
                                                        
         Check_time = 0;
         Clockflag = 0;
        /* when transition is completed, disable the transition by disabling 
         transition flag
        */
        if(Generic_TimeParam.StepValue <= 0)
        {
          Generic_ModelFlag.GenericTransitionFlag = 0;           
        }
#if !defined(DISABLE_TRACES)         
      printf("Inside virtual level application at %d, Current state 0x%.2x ,target state 0x%.2x , Remaining Time 0x%.2x \n\r",
                Clock_Time(),Generic_TemporaryStatus.PresentValue16,Generic_TemporaryStatus.TargetValue16,               
                    Generic_TemporaryStatus.RemainingTime);
#endif    
    }

return MOBLE_RESULT_SUCCESS;         
} 

/** 
* @brief Generic_GetStepValue: This function calculates parameters for transition time
* @param stepParam: Transition time set value of particular model
* retval void
*/
void Generic_GetStepValue(MOBLEUINT8 stepParam)
{
  /*
     Two MSB bit of transition time is dedicated to resolution.
     00 = resolution is 100 ms.
     01 = resolution is 1000 ms. 
     10 = resolution is 10000 ms.
     11 = resolution is 600000 ms. 
    Last bits from 0 to 5th index is step number.
  */
  
   Generic_TimeParam.ResBitValue = stepParam >> 6 ;
   Generic_TimeParam.Res_Value = Get_StepResolutionValue(Generic_TimeParam.ResBitValue);
   Generic_TimeParam.StepValue = stepParam & 0x3F ;
#if !defined(DISABLE_TRACES)     
   printf(" step resolution 0x%.2x, number of step 0x%.2x \r\n",
          Generic_TimeParam.Res_Value , Generic_TimeParam.StepValue );
#endif   
}

/**
* @brief  Generic_Process: Function to execute the transition state machine for
          particular Generic Model
* @param  void
* @retval void
*/ 
void Generic_Process(void)
{       
     MOBLEUINT8 Generic_GetBuff[8]; 
  
#ifdef ENABLE_GENERIC_MODEL_SERVER_ONOFF   
 if(Generic_ModelFlag.GenericTransitionFlag == 1)
  {   
     (Appli_GenericState_cb.GetOnOffStatus_cb)(Generic_GetBuff);
      Generic_OnOffTransitionBehaviour(Generic_GetBuff);
      GenericOnOffStateUpdate_Process();
     (GenericAppli_cb.OnOff_Set_cb)(&Generic_OnOffStatus, 0);
  }    
#endif 
 
   
#ifdef ENABLE_GENERIC_MODEL_SERVER_LEVEL       
  if(Generic_ModelFlag.GenericTransitionFlag == 2)
  {    
     (Appli_GenericState_cb.GetLevelStatus_cb)(Generic_GetBuff);
      Generic_LevelTransitionBehaviour(Generic_GetBuff);
      GenericLevelStateUpdate_Process();
     (GenericAppli_cb.Level_Set_cb)(&Generic_LevelStatus, 0);                             
  }   
#endif
    
}

 /**
* @brief  Generic_Publish: Publish command for Generic Model
* @param  void
* @retval void
*/ 
void Generic_Publish(void)
{
  /*Publish Command*/
}

/*
* @brief GenericOnOffStateUpdate_Process:Function to update the parametes of 
*        Generic On Off model in application file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
MOBLE_RESULT GenericOnOffStateUpdate_Process(void)
{
   Generic_OnOffStatus.Present_OnOff = Generic_TemporaryStatus.PresentValue16;
   Generic_OnOffStatus.Target_OnOff  = Generic_TemporaryStatus.TargetValue16;
   Generic_OnOffStatus.RemainingTime = Generic_TemporaryStatus.RemainingTime;
   
  return MOBLE_RESULT_SUCCESS;
}

/*
* @brief GenericLevelStateUpdate_Process:function to update the parametes of Generic 
*        Level model in application file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
MOBLE_RESULT GenericLevelStateUpdate_Process(void)
{
   Generic_LevelStatus.Present_Level16 = Generic_TemporaryStatus.PresentValue16;
   Generic_LevelStatus.Target_Level16  = Generic_TemporaryStatus.TargetValue16;
   Generic_LevelStatus.RemainingTime   = Generic_TemporaryStatus.RemainingTime;
   
  return MOBLE_RESULT_SUCCESS;
}

/*
* @brief GenericPowerLevelStateUpdate_Process: function to update the parametes of Generic 
* Power Level parameter in application  file from Temporary parameter in model file.
* @param void
* return MOBLE_RESULT.
*/
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
MOBLE_RESULT GenericPowerLevelStateUpdate_Process(void)
{
   Generic_PowerLevelStatus.PresentPowerLevel16 = Generic_TemporaryStatus.PresentValue16;  
   Generic_PowerLevelStatus.TargetPowerLevel16  = Generic_TemporaryStatus.TargetValue16; 
   Generic_PowerLevelStatus.RemainingTime   = Generic_TemporaryStatus.RemainingTime;
   
  return MOBLE_RESULT_SUCCESS;
}
#endif

/*
* @brief Generic_PowerLevelBinding: Data binding b/w Generic power level and Generic level.
* @param bindingFlag used to select the binding and reverse binding 
* return void.
*/
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
void Generic_PowerLevelBinding(MOBLEUINT8 bindingFlag)
{
  if(bindingFlag == 0)
  {
    Generic_PowerLevelStatus.PresentPowerLevel16 = Generic_LevelStatus.Present_Level16 +
                                                      32768;
    (GenericAppli_cb.PowerLevel_Set_cb)(&Generic_PowerLevelStatus, 0);
  }
  else if(bindingFlag == 1)
  {
    Generic_LevelStatus.Present_Level16 = Generic_PowerLevelStatus.PresentPowerLevel16 - 
                                             32768; 
    (GenericAppli_cb.Level_Set_cb)(&Generic_LevelStatus, 0);
  }
  else
  {
  }
}
#endif

/*
* @Brief  GenericOnOff_LightActualBinding: Data binding b/w Generic On Off and 
*         light lightness Actual. this function will set the actual light lightness
*         value at the time of  generic on off set. 
* @param onOff_param Pointer to the data which needs to be checked.
* return void.
*/
void GenericOnOff_LightActualBinding(Generic_OnOffParam_t* onOff_param)
{
  /*
   6.1.2.2.3 - Binding of actual light lightness with Generic on off.
               As generic on off state changes, the actual lightness value will
               change.
  */
  MOBLEUINT8 Generic_GetBuff[4]; 
  
  Light_LightnessStatus_t bLight_ActualParam ;
  Light_LightnessDefaultParam_t bLight_DefaultParam;
  Light_LightnessLastParam_t bLight_LastParam;
  
   /* Get the last saved value of light lightness actual from application */
   (Appli_Light_GetStatus_cb.GetLightLightness_cb)(Generic_GetBuff);
   
    bLight_LastParam.LightnessLastStatus = Generic_GetBuff[3] << 8;
    bLight_LastParam.LightnessLastStatus |= Generic_GetBuff[2];
   
   /* Get the default value of light lightness actual */ 
   (Appli_Light_GetStatus_cb.GetLightLightnessDefault_cb)(Generic_GetBuff);
   
    bLight_DefaultParam.LightnessDefaultStatus = Generic_GetBuff[1] << 8;
    bLight_DefaultParam.LightnessDefaultStatus |= Generic_GetBuff[0];
  
  /* condition is depends on the generic on off state */  
  if(onOff_param->TargetOnOffState == 0x00)
  {
     bLight_ActualParam.PresentValue16 = 0x00;    
  }
  else if((onOff_param->TargetOnOffState == 0x01) && 
              (bLight_DefaultParam.LightnessDefaultStatus == 0x00))
  {
     bLight_ActualParam.PresentValue16 = bLight_LastParam.LightnessLastStatus;
  }
  else if((onOff_param->TargetOnOffState == 0x01) && 
              (bLight_DefaultParam.LightnessDefaultStatus != 0x000))
  {
     bLight_ActualParam.PresentValue16 = bLight_DefaultParam.LightnessDefaultStatus;
  }
  else
  {
    /* No Condition to Execute */
  }
     /* Application callback for setting the light lightness actual value in application
        level
     */
    (LightAppli_cb.Lightness_Set_cb)(&bLight_ActualParam, 0);
    
    /* implicit binding of lightness linear with generic on off set.
       generic on off set -> actual lightness -> linear lightness set.
    */   
    Light_Linear_ActualImplicitBinding(BINDING_LIGHT_LIGHTNESS_ACTUAL_SET);
}

/*
* @Brief  GenericLevel_LightActualBinding: Data binding b/w Generic Level and 
*         light lightness Actual. this function will set the actual light lightness
*         value at the time of  generic Level set. 
* @param gLevel_param Pointer to the data which needs to be checked.
* return void.
*/
void GenericLevel_LightActualBinding(Generic_LevelParam_t* gLevel_param)
{
  /*
    6.1.2.2.2 - Binding of actual light lightness with generic level
                As generic Level changes, the actual lightness value will
                change.
  */
  Light_LightnessStatus_t bLight_ActualParam ; 
  
  bLight_ActualParam.PresentValue16 = gLevel_param->TargetLevel + 32768;  
   
 (LightAppli_cb.Lightness_Set_cb)(&bLight_ActualParam, 0);
 
  /* application callback for the actual lightness to get the value.
    Actual lightness is directly bounded with generic on off and generic level
    which implicitly changed the value of linear lightness with generic on    
    off state and generic level changes.
 */     
  Light_Actual_LinearBinding();
 
}

/*
* @brief GenericLevel_CtlTempBinding: Data binding b/w Generic level and Ctl
*        Temperature set.
* @param bLevelParam: pointer to the structure, which should be set.
* return void.
*/
void GenericLevel_CtlTempBinding(Generic_LevelParam_t * bLevelParam)
{ 
   Light_CtlStatus_t bCtlTempstatus;
   MOBLEUINT32 productValue;
  
     /* 6.1.3.1.1 Binding with the Generic Level state.
       Light CTL Temperature = T_MIN + (Generic Level + 32768) * (T_MAX - T_MIN) / 65535
       T_MIN = minimum range of ctl temperature
       T_MAX = maximum range of ctl temperature
     */
      
      productValue = (bLevelParam->TargetLevel + 32768) * (0x4E20 - 0x0320) ;
      bCtlTempstatus.PresentCtlTemperature16 = 0x0320 + ((productValue) /65535);
      /* Application callback */
     (LightAppli_cb.Light_CtlTemperature_Set_cb)(&bCtlTempstatus, 0);
  
}
/**
* @}
*/

/**
* @}
*/

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

