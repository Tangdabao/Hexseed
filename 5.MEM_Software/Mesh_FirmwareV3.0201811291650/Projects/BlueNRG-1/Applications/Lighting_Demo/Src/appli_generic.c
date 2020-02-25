/**
******************************************************************************
* @file    appli_generic.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
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
* Initial BlueNRG-Mesh is built over Motorola抯 Mesh over Bluetooth Low Energy 
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

/* user setting for status message for battery Level */

Appli_BatteryUserflag_param_t AppliBatteryUserflag = {                                 
                                       BATTERY_PRESENT_REMOVABLE,  
                                       BATTERY_GOOD_LEVEL,
                                       BATTERY_REQUIRE_NO_SERVICE      
                                     };  
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

/* Battery Level Parameter */
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
#pragma pack(1)
typedef struct
{
  MOBLEUINT8 Battery_Level ; 
  MOBLEUINT32 Time_To_Discharge32;
  MOBLEUINT32 Time_To_Charge32;
  MOBLEUINT8 Flag_Value;
}Appli_Generic_BatteryLevelSet;

Appli_Generic_BatteryLevelSet AppliBatteryLevelSet;
#endif

#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 Present_Power16;
  MOBLEUINT16 Default_Power16;  
  MOBLEUINT16 RangeMin16;     
  MOBLEUINT16 RangeMax16;
}Appli_Generic_PowerLevelSet;

Appli_Generic_PowerLevelSet AppliPowerLevelSet;
#endif
/* Default transition time message */
#pragma pack(1)
typedef struct
{
   MOBLEUINT8 TransitionTime;     
}Appli_Generic_transitionTimeSet;

Appli_Generic_transitionTimeSet transitionTimeSet;

/* Power on message */
#pragma pack(1)
typedef struct
{
   MOBLEUINT8 OnPwerUp_State ;  
}Appli_Generic_OnPowerUpSet;

Appli_Generic_OnPowerUpSet OnPowerUpSet = {0x00};

/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

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
   #if  0
	  if(AppliOnOffSet.Present_OnOff)
    {
        MFT_Cmd(MFT2, ENABLE);
    }
    else
    {
        MFT_Cmd(MFT2, DISABLE);

    }
		#endif
    //通用模型，开关的回调函数
    printf("Appli_Generic_OnOff_Set:%d\r\n", AppliOnOffSet.Present_OnOff);
    return MOBLE_RESULT_SUCCESS;
}

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
    AppliLevelSet.Present_Level16 = plevelParam->Present_Level16;

    /* For demo, if Level is more than 100, switch ON the LED */

    /* increment of 20 percent at each level */
    duty = PwmValueMapping(AppliLevelSet.Present_Level16 , 0x7FFF , 0);
    //modify
    printf("duty:%d\r\n", duty);
    Modify_PWM(1, duty);   /* 1 is for GPIO_3. Software PWM */

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

/**
* @brief  Appli_Generic_TransitonDefaultTime_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  TransitionTimeParam: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/          
MOBLE_RESULT Appli_Generic_TransitionDefaultTime_Set(Generic_TransitionTimeParam_t *TransitionTimeParam, 
                                                       MOBLEUINT32 plength) 
                                        
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_TransitionDefaultTime_Set callback received \r\n");
#endif   
  
  transitionTimeSet.TransitionTime = TransitionTimeParam->DefalutTransitionTime;
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Appli_Generic_OnPowerUp_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  onPowerUp_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/                                      
MOBLE_RESULT Appli_Generic_OnPowerUp_Set(Generic_OnPowerUpParam_t *onPowerUp_param , 
                                                             MOBLEUINT32 plength)  
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_OnPowerUp callback received \r\n");
#endif  
   
   return MOBLE_RESULT_SUCCESS;
}

#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
/**
* @brief  Appli_Generic_PowerLevel_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  pLevel_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      
MOBLE_RESULT Appli_Generic_ActualPowerLevel_Set(Generic_PowerLevelStatus_t *pLevel_param ,
                                                               MOBLEUINT8 OptionalValid)  
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_ActualPowerLevel_Set callback received \r\n");
#endif  
      
  return MOBLE_RESULT_SUCCESS;  
}

/**
* @brief  Appli_Generic_DefaultPower_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  pLevel_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      
MOBLE_RESULT Appli_Generic_DefaultPower_Set(Generic_PowerLevelParam_t *pLevel_param ,
                                                                MOBLEUINT32 plength)  
{ 
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_DefaultPower_Set callback received \r\n");
#endif  
  
  return MOBLE_RESULT_SUCCESS;
  
}

/**
* @brief  Appli_Generic_DefaultPower_Status: This function is callback for Application
           when Generic Level status message is to be provided
* @param  plevelparam_status: Pointer to the status message
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/   
MOBLE_RESULT Appli_Generic_DefaultPower_Status(MOBLEUINT8 *plevelparam_status , 
                                                              MOBLEUINT32 *plength) 
{ 
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_DefaultPower_Status callback received \r\n");
#endif  
  
   return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Appli_Generic_PowerRange_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  pRange_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      
MOBLE_RESULT Appli_Generic_PowerRange_Set(Generic_PowerRange_t *pRange_param ,
                                                                MOBLEUINT32 plength)  
{ 
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_PowerRange_Set callback received \r\n");
#endif  
 
  return MOBLE_RESULT_SUCCESS; 
}  
#endif

/**
* @brief  Appli_Generic_LocationGlobal_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  plocation_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      
MOBLE_RESULT Appli_Generic_GlobalLocation_Set(Generic_GlobalLocationParam_t *plocation_param ,
                                                              MOBLEUINT32 plength)  
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_GlobalLocation_Set callback received \r\n");
#endif  
 
  return MOBLE_RESULT_SUCCESS;
  
}
   
/**
* @brief  Appli_Generic_LocalLocation_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  locallocation_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      

MOBLE_RESULT Appli_Generic_LocalLocation_Set(Generic_LocalLocationParam_t *locallocation_param ,
                                                               MOBLEUINT32 plength)  
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_LocationLocal_Set callback received \r\n");
#endif  
 
  return MOBLE_RESULT_SUCCESS;  
} 
   
/**
* @brief  Appli_Generic_UserProperty_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  userProperty_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      

MOBLE_RESULT Appli_Generic_UserProperty_Set(Generic_UserPropertyParam_t *userProperty_param ,
                                                               MOBLEUINT32 plength)  
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_UserProperty_Set callback received \r\n");
#endif  
  
  return MOBLE_RESULT_SUCCESS; 
} 

/**
* @brief  Appli_Generic_ManufacturerProperty_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  manufacturerProperty_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      
MOBLE_RESULT Appli_Generic_ManufacturerProperty_Set(Generic_ManufacturerPropertyParam_t 
                                                      *manufacturerProperty_param ,
                                                               MOBLEUINT32 plength)  
{
#if !defined(DISABLE_TRACES)
  printf("Appli_Generic_AdminProperty_Set callback received \r\n");
#endif  
  
  return MOBLE_RESULT_SUCCESS;  
} 
                    
/**
* @brief  Appli_Generic_AdminProperty_Set: This function is callback for Application
           when Generic on power up message is to be provided
* @param  adminProperty_param: Pointer to the data to be set
* @param  plength: Pointer to the length variable, that needs to be updated 
* @retval MOBLE_RESULT
*/      
MOBLE_RESULT Appli_Generic_AdminProperty_Set(Generic_AdminPropertyParam_t *adminProperty_param ,
                                                               MOBLEUINT32 plength)  
{
 
  return MOBLE_RESULT_SUCCESS;  
} 

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
* @brief  Appli_Generic_GetLevelState: This function is callback for Application
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
* @brief  Appli_Generic_GetTransitionTime: This function is callback for Application
           when Generic transition time status message is to be provided
* @param  pTransition_Status: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_GetTransitionTime(MOBLEUINT8* pTransition_Status) 
                                        
{ 
   *pTransition_Status = transitionTimeSet.TransitionTime;
  
  return MOBLE_RESULT_SUCCESS; 
}

#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
/**
* @brief  Appli_Generic_GetPowerLevelState: This function is callback for Application
           when Generic Power Level status message is to be provided
* @param  pPowerLevel_Status: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_GetPowerLevelStatus(MOBLEUINT8* pPowerLevel_Status) 
                                        
{ 
   *pPowerLevel_Status = AppliPowerLevelSet.Present_Power16;
   *(pPowerLevel_Status+1) = AppliPowerLevelSet.Present_Power16 >> 8;
 
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Appli_Generic_GetDefaultPowerStatus: This function is callback for Application
           when Generic Power Level status message is to be provided
* @param  pPowerLevel_Status: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_GetDefaultPowerStatus(MOBLEUINT8* pPowerLevel_Status) 
                                        
{ 
   *pPowerLevel_Status = AppliPowerLevelSet.Default_Power16;
   *(pPowerLevel_Status+1) = AppliPowerLevelSet.Default_Power16 >> 8;
 
  return MOBLE_RESULT_SUCCESS; 
}

/**
* @brief  Appli_Generic_GetPowerRangeStatus: This function is callback for Application
           when Generic Power Level status message is to be provided
* @param  pPowerRange_Status: Pointer to the status message
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Generic_GetPowerRangeStatus(MOBLEUINT8* pPowerRange_Status)                                         
{ 
   *pPowerRange_Status = AppliPowerLevelSet.RangeMin16 ;
   *(pPowerRange_Status+1) = AppliPowerLevelSet.RangeMin16  >> 8;
   *(pPowerRange_Status+2) = AppliPowerLevelSet.RangeMin16 ;
   *(pPowerRange_Status+3) = AppliPowerLevelSet.RangeMin16 >> 8;
   
  return MOBLE_RESULT_SUCCESS; 
}
#endif

#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
/**
* @brief  Appli_Generic_GetBatteryLevelState: This function is callback for Application
           to get Generic Battery Level status message is to be provided
* @param  pBattery_status: Pointer to the status message
* @retval MOBLE_RESULT
*/
MOBLE_RESULT Appli_Generic_GetBatteryLevelStatus(MOBLEUINT8* pBattery_status) 
                                        
{
    *pBattery_status = AppliBatteryLevelSet.Battery_Level;
    *(pBattery_status+1) = AppliBatteryLevelSet.Time_To_Charge32 << 24;
    *(pBattery_status+2) = AppliBatteryLevelSet.Time_To_Charge32 << 16;
    *(pBattery_status+3) = AppliBatteryLevelSet.Time_To_Charge32 << 8;
    *(pBattery_status+4) = AppliBatteryLevelSet.Time_To_Discharge32 << 24;
    *(pBattery_status+5) = AppliBatteryLevelSet.Time_To_Discharge32 << 16;
    *(pBattery_status+6) = AppliBatteryLevelSet.Time_To_Discharge32 << 8;
    *(pBattery_status+7) = AppliBatteryLevelSet.Flag_Value;
      
  return MOBLE_RESULT_SUCCESS; 
}

#endif                                        

/**
 * @}
 */

/**
 * @}
 */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

