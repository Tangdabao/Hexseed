/**
******************************************************************************
* @file    appli_generic.h
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
* Initial BlueNRG-Mesh is built over Motorola’s Mesh over Bluetooth Low Energy 
* (MoBLE) technology. The present solution is developed and maintained for both 
* Mesh library and Applications solely by STMicroelectronics.
*
******************************************************************************
*/

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __GENERIC_APPLI_H
#define __GENERIC_APPLI_H

/* Includes ------------------------------------------------------------------*/
#include "types.h"
#include "mesh_cfg.h"


/* Exported macro ------------------------------------------------------------*/
/* user configuration for Battery status */
#define BATTERY_ABSENT                 0X00
#define BATTERY_PRESENT_REMOVABLE      0X01
#define BATTERY_PRESENT_NON_REMOVABLE  0X02
#define BATTERY_UNKNOWN                0X03
#define BATTERY_CRITICAL_LOW_LEVEL     0X00
#define BATTERY_LOW_LEVEL              0X01
#define BATTERY_GOOD_LEVEL             0X02
#define BATTERY_LEVEL_UNKNOWN         0X03
#define BATTERY_NOT_CHARGEABLE         0X00
#define BATTERY_NOT_CHARGING           0X01
#define BATTERY_IS_CHARGING            0X02
#define BATTERY_CHARGING_UNKNOWN       0X03
#define BATTERY_SERVICE_RFU            0X00
#define BATTERY_REQUIRE_NO_SERVICE      0X01
#define BATTERY_REQUIRE_SERVICE        0X02
#define BATTERY_SERVICE_UNKNOWN        0X03   
/* Exported variables  ------------------------------------------------------- */
/* Application Variable-------------------------------------------------------*/
typedef struct 
{
  MOBLEUINT8 Is_BatteryPresent;
  MOBLEUINT8 Is_Chargeable;
  MOBLEUINT8 Is_Serviceable;
}Appli_BatteryUserflag_param_t;

/* Exported Functions Prototypes ---------------------------------------------*/

MOBLE_RESULT Appli_Generic_OnOff_Set(Generic_OnOffStatus_t*, MOBLEUINT8);

MOBLE_RESULT Appli_Generic_Level_Set(Generic_LevelStatus_t*, MOBLEUINT8);
MOBLE_RESULT Appli_Generic_LevelDelta_Set(Generic_LevelStatus_t*, MOBLEUINT8 );
MOBLE_RESULT Appli_Generic_LevelMove_Set(Generic_LevelStatus_t* pdeltaMoveParam, 
                                              MOBLEUINT8 OptionalValid);
MOBLE_RESULT Appli_Generic_Level_Status(MOBLEUINT8* level_status, 
                                                MOBLEUINT32 *plength);

MOBLE_RESULT Appli_Generic_TransitionDefaultTime_Set(Generic_TransitionTimeParam_t *TransitionTimeParam, 
                                                       MOBLEUINT32 plength);                   
MOBLE_RESULT Appli_Generic_TransitionDefaultTime_Status(MOBLEUINT8 *transition_timeStatusValue, 
                                                MOBLEUINT32 *plength);                 

MOBLE_RESULT Appli_Generic_OnPowerUp_Set(Generic_OnPowerUpParam_t *onPowerUp_param , 
                                                             MOBLEUINT32 plength);  
 
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
MOBLE_RESULT Appli_Generic_ActualPowerLevel_Set(Generic_PowerLevelStatus_t *pLevel_param ,
                                                 MOBLEUINT8 OptionalValid);  

MOBLE_RESULT Appli_Generic_DefaultPower_Set(Generic_PowerLevelParam_t *pLevel_param ,
                                                MOBLEUINT32 plength); 
MOBLE_RESULT Appli_Generic_DefaultPower_Status(MOBLEUINT8 *plevelparam_status , 
                                                MOBLEUINT32 *plength); 

MOBLE_RESULT Appli_Generic_PowerRange_Set(Generic_PowerRange_t *pRange_param ,
                                                 MOBLEUINT32 plength);
MOBLE_RESULT Appli_Generic_PowerRange_Status(MOBLEUINT8 *pRangeparam_status , 
                                                 MOBLEUINT32 *plength);
#endif

MOBLE_RESULT Appli_Generic_GlobalLocation_Set(Generic_GlobalLocationParam_t *plocation_param ,
                                                MOBLEUINT32 plength);

MOBLE_RESULT Appli_Generic_LocalLocation_Set(Generic_LocalLocationParam_t *locallocation_param ,
                                                 MOBLEUINT32 plength); 

MOBLE_RESULT Appli_Generic_UserProperty_Set(Generic_UserPropertyParam_t *userProperty_param ,
                                                               MOBLEUINT32 plength); 
MOBLE_RESULT Appli_Generic_AdminProperty_Set(Generic_AdminPropertyParam_t *adminProperty_param ,
                                                               MOBLEUINT32 plength);

MOBLE_RESULT Appli_Generic_ManufacturerProperty_Set(Generic_ManufacturerPropertyParam_t 
                                                      *manufacturerProperty_param ,
                                                               MOBLEUINT32 plength);

MOBLE_RESULT Appli_Generic_GetOnOffStatus(MOBLEUINT8* pOnOff_Status);

MOBLE_RESULT Appli_Generic_GetLevelStatus(MOBLEUINT8* pLevel_Status);

MOBLE_RESULT Appli_Generic_GetTransitionTime(MOBLEUINT8* pTransition_Status) ;
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
MOBLE_RESULT Appli_Generic_GetPowerLevelStatus(MOBLEUINT8* pPowerLevel_Status); 

MOBLE_RESULT Appli_Generic_GetDefaultPowerStatus(MOBLEUINT8* pPowerLevel_Status) ;

MOBLE_RESULT Appli_Generic_GetPowerRangeStatus(MOBLEUINT8* pPowerRange_Status);
#endif
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY
MOBLE_RESULT Appli_Generic_GetBatteryLevelStatus(MOBLEUINT8* pBattery_status);
#endif

#endif /* __GENERIC_APPLI_H */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

