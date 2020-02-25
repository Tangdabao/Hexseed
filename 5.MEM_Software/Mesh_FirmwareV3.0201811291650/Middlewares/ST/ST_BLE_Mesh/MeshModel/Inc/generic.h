/**
******************************************************************************
* @file    generic.h
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   Header file for the user application file 
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
#ifndef __GENERIC_H
#define __GENERIC_H

/* Includes ------------------------------------------------------------------*/
#include "types.h"
#include "light.h"
#include "bluenrg_mesh.h"
#include "mesh_cfg.h"


/* Exported macro ------------------------------------------------------------*/

/******************************************************************************/
/********** Following Section defines the Opcodes for the Messages ************/
/******************************************************************************/

/* 7.1 Messages summary Page 298 */
/* Generic OnOff Server Model Opcode */
#define GENERIC_ON_OFF_GET       0x8201
#define GENERIC_ON_OFF_SET_ACK   0x8202
#define GENERIC_ON_OFF_SET_UNACK 0x8203
#define GENERIC_ON_OFF_STATUS    0x8204

/* Generic Level Server Model Opcode */
#define GENERIC_LEVEL_GET                   0x8205
#define GENERIC_LEVEL_SET_ACK               0x8206
#define GENERIC_LEVEL_SET_UNACK             0x8207
#define GENERIC_LEVEL_STATUS                0x8208
#define GENERIC_LEVEL_DELTA_SET             0x8209
#define GENERIC_LEVEL_DELTA_SET_UNACK       0x820A
#define GENERIC_LEVEL_DELTA_MOVE_SET        0x820B
#define GENERIC_LEVEL_DELTA_MOVE_SET_UNACK  0x820C
#define GENERIC_LEVEL_DELTA_MOVE_SET_UNACK  0x820C

/* Generic Default Transition Time Server Model Opcode */
#define GENERIC_DEFAULT_TRANSITION_TIME_GET                     0x820D
#define GENERIC_DEFAULT_TRANSITION_TIME_SET                     0x820E
#define GENERIC_DEFAULT_TRANSITION_TIME_SET_UNACK      0x820F
#define GENERIC_DEFAULT_TRANSITION_TIME_STATUS                  0x8210

/* Generic Power OnOff Server Model Opcode */
#define GENERIC_ONPOWERUP_GET    0x8211
#define GENERIC_ONPOWERUP_STATUS 0x8212

/* Generic Power OnOff Setup Server Model Opcode */
#define GENERIC_ONPOWERUP_SET  0x8213
#define GENERIC_ONPOWERUP_SET_UNACK  0x8214

/* Generic Power Level Server Model Opcode */
#define GENERIC_POWER_LEVEL_GET                 0X8215
#define GENERIC_POWER_LEVEL_SET                 0X8216
#define GENERIC_POWER_LEVEL_SET_UNACK  0X8217
#define GENERIC_POWER_LEVEL_STATUS              0X8218
#define GENERIC_POWER_LAST_GET                  0X8219
#define GENERIC_POWER_LAST_STATUS               0X821A
#define GENERIC_POWER_DEFAULT_GET               0X821B
#define GENERIC_POWER_DEFAULT_STATUS            0X821C
#define GENERIC_POWER_RANGE_GET                 0X821D
#define GENERIC_POWER_RANGE_STATUS              0X821E


/* Generic Power Level Setup Server Model Opcode */
#define GENERIC_POWER_DEFAULT_SET                0X821F
#define GENERIC_POWER_DEFAULT_SET_UNACK 0X8220
#define GENERIC_POWER_RANGE_SET                  0X8221
#define GENERIC_POWER_RANGE_SET_UNACK   0X8222


/* Generic Battery Server Model Opcode */
#define GENERIC_BATTERY_GET    0X8223
#define GENERIC_BATTERY_STATUS 0X8224

/* Generic Location Server Model Opcode */
#define GENERIC_LOCATION_GLOBAL_GET    0X8225
#define GENERIC_LOCATION_GLOBAL_STATUS   0X40
#define GENERIC_LOCATION_LOCAL_GET     0X8226
#define GENERIC_LOCATION_LOCAL_STATUS  0X8227

/* Generic Location Setup Server Model Opcode */
#define GENERIC_LOCATION_GLOBAL_SET                  0X41
#define GENERIC_LOCATION_GLOBAL_SET_UNACK   0X42
#define GENERIC_LOCATION_LOCAL_SET                 0X8228
#define GENERIC_LOCATION_LOCAL_SET_UNACK  0X8229

/* Generic Manufacturer Property Server Model Opcode */
#define GENERIC_MANUFACTURER_PROPERTIES_GET            0X822A
#define GENERIC_MANUFACTURER_PROPERTIES_STATUS           0X43
#define GENERIC_MANUFACTURER_PROPERTY_GET              0X822B
#define GENERIC_MANUFACTURER_PROPERTY_SET                0X44
#define GENERIC_MANUFACTURER_PROPERTY_SET_UNACK 0X45
#define GENERIC_MANUFACTURER_PROPERTY_STATUS             0X46


/* Generic Admin Property Server Model Opcode */
#define GENERIC_ADMIN_PROPERTIES_GET             0X822C
#define GENERIC_ADMIN_PROPERTIES_STATUS            0X47
#define GENERIC_ADMIN_PROPERTY_GET               0X822D
#define GENERIC_ADMIN_PROPERTY_SET                 0X48
#define GENERIC_ADMIN_PROPERTY_SET_UNACK  0X49
#define GENERIC_ADMIN_PROPERTY_STATUS              0X4A

/* Generic User Property Server Model Opcode */
#define GENERIC_USER_PROPERTIES_GET              0X822E
#define GENERIC_USER_PROPERTIES_STATUS             0X4B
#define GENERIC_USER_PROPERTY_GET                0X822F
#define GENERIC_USER_PROPERTY_SET                  0X4C
#define GENERIC_USER_PROPERTY_SET_UNACK   0X4D
#define GENERIC_USER_PROPERTY_STATUS               0X4E

/******************************************************************************/
/********** Following Section defines the SIG MODEL IDs            ************/
/******************************************************************************/

#define GENERIC_MODEL_SERVER_ONOFF_MODEL_ID   0x1000
#define GENERIC_MODEL_SERVER_LEVEL_MODEL_ID   0x1002
#define GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME_MODEL_ID   0x1004
#define GENERIC_MODEL_SERVER_POWER_ONOFF_MODEL_ID   0x1006
#define GENERIC_MODEL_SERVER_POWER_ONOFF_SETUP_MODEL_ID   0x1007
#define GENERIC_MODEL_SERVER_POWER_LEVEL_MODEL_ID   0x1009
#define GENERIC_MODEL_SERVER_POWER_LEVEL_SETUP_MODEL_ID   0x100A
#define GENERIC_MODEL_SERVER_BATTERY_MODEL_ID   0x100C
#define GENERIC_MODEL_SERVER_LOCATION_MODEL_ID   0x100E
#define GENERIC_MODEL_SERVER_LOCATION_SETUP_MODEL_ID   0x100F
#define GENERIC_MODEL_SERVER_ADMIN_PROPERTY_MODEL_ID   0x1011
#define GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY_MODEL_ID   0x1012
#define GENERIC_MODEL_SERVER_USER_PROPERTY_MODEL_ID   0x1013
#define GENERIC_MODEL_SERVER_CLIENT_PROPERTY_MODEL_ID   0x1014

/******************************************************************************/
/********** SIG MODEL IDs ends                                     ************/
/******************************************************************************/


#define MAXSTEPVALUE   0X3E
#define MINSTEPVALUE   0X00

#define STEP_RESOLUTION_0     100
#define STEP_RESOLUTION_1     1000
#define STEP_RESOLUTION_2     10000
#define STEP_RESOLUTION_3     600000

#define STEP_HEX_VALUE_0       0X00
#define STEP_HEX_VALUE_1       0X01
#define STEP_HEX_VALUE_2       0X02
#define STEP_HEX_VALUE_3       0X03

#define MAX_BATTERY_LEVEL      0X64
#define PROHIBITED_MIN_BATTERY_LEVEL      0X65
#define PROHIBITED_MAX_BATTERY_LEVEL      0XFE
#define UNKNOWN_BATTERY_LEVEL             0XFF

#define BATTERY_VALID_CHARGE_TIME      0XFFFE
#define BATTERY_UNKLNOWN_CHARGE_TIME   0XFFFF

#define BATTERY_VALID_DISCHARGE_TIME      0XFFFE
#define BATTERY_UNKLNOWN_DISCHARGE_TIME   0XFFFF

/* Generic Client Property Server Model Opcode */
#define GENERIC_CLIENT_PROPERTIES_GET    0X4F
#define GENERIC_CLIENT_PROPERTIES_STATUS 0X50

#define PACKET_CACHE_SIZE  2
/* Exported variables  ------------------------------------------------------- */

/* Temporary  message to store the application vaiables*/
#pragma pack(1)
typedef struct
{
  MOBLEUINT8  RemainingTime;
  MOBLEINT16 PresentValue16;
  MOBLEINT16 TargetValue16;
} Generic_TemporaryStatus_t;
/*****************************************************/
/* Transition time variables */
#pragma pack(1)
typedef struct
{
  MOBLEINT8   StepValue ;
  MOBLEUINT8  ResBitValue;
  MOBLEUINT32 Res_Value;
}Generic_TimeParam_t;
/*****************************************************/
/* Transition Flag variables */
#pragma pack(1)
typedef struct
{
  MOBLEUINT8 GenericTransitionFlag;
  MOBLEUINT8 GenericOptionalParam;
}Generic_ModelFlag_t;
/*****************************************************/

#pragma pack(1)
typedef struct
{
    MOBLE_ADDRESS peer_addrs;
    MOBLEUINT32 dst_addrs;
    MOBLEUINT8 data[];
}Moble_PowerLevelPacket_t;

/* Generic On Off state Messages */
#pragma pack(1)
typedef struct
{
  MOBLEUINT8 TargetOnOffState;
  MOBLEUINT8 Generic_TID;
  MOBLEUINT8 Transition_Time;
  MOBLEUINT8 Delay_Time;
} Generic_OnOffParam_t;

#pragma pack(1)
typedef struct
{
  MOBLEUINT8 Present_OnOff;
  MOBLEUINT8 Target_OnOff;
  MOBLEUINT8 RemainingTime;
}Generic_OnOffStatus_t;

/* Generic Level state Messages */
#pragma pack(1)
typedef struct
{
  MOBLEINT16 TargetLevel;
  MOBLEUINT8  Generic_TID;
  MOBLEUINT8  Transition_Time;
  MOBLEUINT8  Delay_Time;
} Generic_LevelParam_t;

#pragma pack(1)
typedef struct
{
  MOBLEINT16 Present_Level16;
  MOBLEINT16 Target_Level16;
  MOBLEUINT8 RemainingTime;
  MOBLEUINT8 Last_Level_TID;
  MOBLEINT16 Last_Present_Level16;  
}Generic_LevelStatus_t;

#pragma pack(1)
typedef struct
{
  MOBLEINT32 TargetDeltaLevel32;
  MOBLEUINT8  Generic_TID;
  MOBLEUINT8  Transition_Time;
  MOBLEUINT8  Delay_Time;
} Generic_DeltaLevelParam_t;

#pragma pack(1)
typedef struct
{
  MOBLEUINT16 TargetMoveLevel16;
  MOBLEUINT8  Generic_TID;
  MOBLEUINT8  Transition_Time;
  MOBLEUINT8  Delay_Time;
} Generic_LevelMoveParam_t;
/*****************************************************/
/* Generic Default Transition Time */ 
#pragma pack(1)
typedef struct
{
  MOBLEUINT8 DefalutTransitionTime;
} Generic_TransitionTimeParam_t;
/*****************************************************/
/* Generic On Power Up */ 
#pragma pack(1)
typedef struct
{
  MOBLEUINT8 OnPowerUp;
} Generic_OnPowerUpParam_t;
/*****************************************************/
/* Generic Power Level Messages */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 ActualPowerLevel16;
  MOBLEUINT16 DefaultPowerLevel16;
  MOBLEUINT16 LastPowerLevel16;
  MOBLEUINT8  Generic_TID;
  MOBLEUINT8  Transition_Time;
  MOBLEUINT8  Delay_Time;  
} Generic_PowerLevelParam_t;

#pragma pack(1)
typedef struct
{
  MOBLEUINT16 PresentPowerLevel16;
  MOBLEUINT16 TargetPowerLevel16;
  MOBLEUINT8  RemainingTime;
  MOBLEUINT8  LastPower_TID;
  MOBLEUINT16 LastPresentLevel16;  
}Generic_PowerLevelStatus_t;

#pragma pack(1)
typedef struct
{
  MOBLEUINT16 RangeMin16;
  MOBLEUINT16 RangeMax16;
} Generic_PowerRange_t;

#pragma pack(1)
typedef struct
{
  MOBLEUINT8  StatusCode;
  MOBLEUINT16 RangeMin16;
  MOBLEUINT16 RangeMax16;
} Generic_PowerRangeStatus_t;

/********************************************/

/* Generic Battery Level Messages*/
#pragma pack(1)
/* Battery Level Parameter */
typedef struct
{
  MOBLEUINT8 BatteryLevel ; 
  MOBLEUINT32 TimeToDischarge32;
  MOBLEUINT32 TimeToCharge32;
  MOBLEUINT8 FlagValue;
  MOBLEUINT8 IsBatteryPresent;
  MOBLEUINT8 IsChargeable;
  MOBLEUINT8 IsServiceable;
}Generic_BatteryLevelStatus_t;

/* User battery configuration variables*/
#pragma pack(1)
typedef struct 
{
  MOBLEUINT8 Is_BatteryPresent;
  MOBLEUINT8 Is_chargeable;
  MOBLEUINT8 Is_serviceable;
}Battery_flag_param_t;

/*********************************************/

/* Generic Global Location Messages*/
#pragma pack(1)
typedef struct
{
  MOBLEINT32 GlobalLatitude32;
  MOBLEINT32 GlobalLongitude32;
  MOBLEINT16 GlobalAltitude16;
} Generic_GlobalLocationParam_t;

/********************************************/

/* Generic Local Location Messages*/
#pragma pack(1)
typedef struct
{
  MOBLEINT16 LocalNorth16;
  MOBLEINT16 LocalEast16;
  MOBLEINT16 LocalAltitude16;
  MOBLEINT8  FloorNumber;
  MOBLEUINT16 Uncertainity;
} Generic_LocalLocationParam_t;

/********************************************/
/* Generic User property set messages */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 UserProperty_ID16;
  MOBLEUINT8  UserAccess;
  MOBLEUINT32 UserPropertyValue;
}Generic_UserPropertyParam_t;


/* Generic Admin property set messages */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 AdminProperty_ID16;
  MOBLEUINT8  Admin_Access;
  MOBLEUINT32 AdminPropertyValue;
}Generic_AdminPropertyParam_t;

/* Generic Manufacturer property set messages */
#pragma pack(1)
typedef struct
{
  MOBLEUINT16 ManufacturerProperty_ID16;
  MOBLEUINT8 Manufacturer_Access;
}Generic_ManufacturerPropertyParam_t;
  
/** \brief Callback map to application layer 
*  these call backs are for set and status messages
*/
typedef struct
{
  MOBLE_RESULT (*OnOff_Set_cb)(Generic_OnOffStatus_t*, uint8_t);  
  
  MOBLE_RESULT (*Level_Set_cb)(Generic_LevelStatus_t*, MOBLEUINT8);
  MOBLE_RESULT (*LevelDelta_Set_cb)(Generic_LevelStatus_t*, MOBLEUINT8);
  MOBLE_RESULT (*LevelDeltaMove_Set_cb)(Generic_LevelStatus_t*, MOBLEUINT8);

  MOBLE_RESULT (*Transit_time_set)(Generic_TransitionTimeParam_t* , MOBLEUINT32);
  
  MOBLE_RESULT (*OnPowerUp_Set_cb)(Generic_OnPowerUpParam_t* , MOBLEUINT32);
 
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL     
  MOBLE_RESULT (*PowerLevel_Set_cb)(Generic_PowerLevelStatus_t* , MOBLEUINT8);
  
  MOBLE_RESULT (*PowerDefault_Set_cb)(Generic_PowerLevelParam_t* , MOBLEUINT32);
  
  MOBLE_RESULT (*PowerRange_Set_cb)(Generic_PowerRange_t* , MOBLEUINT32);
#endif
  
} Appli_Generic_cb_t;

/** \brief Callback map to middle layer 
*  these call backs are for get the value from application layer to middle layer
*/
typedef struct
{ 
  MOBLE_RESULT (*GetOnOffStatus_cb)(MOBLEUINT8*);
  
  MOBLE_RESULT (*GetLevelStatus_cb)(MOBLEUINT8*);
  
  MOBLE_RESULT (*GetTransitionStatus_cb)(MOBLEUINT8*);
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL   
  MOBLE_RESULT (*GetPowerLevelStatus_cb)(MOBLEUINT8*);
  
  MOBLE_RESULT (*GetDefaultPowerStatus_cb)(MOBLEUINT8*);
  
  MOBLE_RESULT (*GetPowerRangeStatus_cb)(MOBLEUINT8*);
#endif
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY     
  MOBLE_RESULT (*GetBatteryLevelStatus_cb)(MOBLEUINT8*);
#endif  
}Appli_Generic_State_cb_t;


extern const Appli_Generic_State_cb_t Appli_GenericState_cb;
extern const Appli_Generic_cb_t GenericAppli_cb;

/* Exported Functions Prototypes ---------------------------------------------*/

void BluenrgMesh_GenericModelAppliCb (Appli_Generic_cb_t* map );


MOBLE_RESULT Generic_OnOff_Set(const MOBLEUINT8*, MOBLEUINT32);
MOBLE_RESULT Generic_OnOff_Status(MOBLEUINT8* , MOBLEUINT32*);

MOBLE_RESULT Generic_Level_Set(const MOBLEUINT8*, MOBLEUINT32);
MOBLE_RESULT Generic_LevelDelta_Set(const MOBLEUINT8*, MOBLEUINT32);
MOBLE_RESULT Generic_LevelMove_Set(const MOBLEUINT8*, MOBLEUINT32);
MOBLE_RESULT Generic_Level_Status(MOBLEUINT8* , MOBLEUINT32*);

MOBLE_RESULT Generic_TransitionDefaultTime_Set(const MOBLEUINT8 *transitionTime_param , 
                                             MOBLEUINT32 length);      
MOBLE_RESULT Generic_TransitionDefaultTime_Status(MOBLEUINT8 *transitionTime_status ,
                                             MOBLEUINT32 *plength);       
MOBLEUINT32 GetStepResolutionValue(MOBLEUINT8 time_param);

MOBLE_RESULT Generic_OnPowerUp_Set(const MOBLEUINT8 *onPowerUp_param , MOBLEUINT32 length); 
MOBLE_RESULT Generic_OnPowerUp_Status(MOBLEUINT8 *onPowerUp_status , MOBLEUINT32 *plength); 

MOBLE_RESULT Generic_ActualPowerLevel_Set(const MOBLEUINT8 *plevel_param , MOBLEUINT32 length); 
MOBLE_RESULT Generic_ActualPowerLevel_Status(MOBLEUINT8 *plevel_status , 
                                             MOBLEUINT32 *plength);
MOBLE_RESULT Generic_LastPowerLevel_Status(MOBLEUINT8 *plevel_status , 
                                             MOBLEUINT32 *plength);
MOBLE_RESULT Generic_DefaultPower_Status(MOBLEUINT8 *plevel_status , 
                                             MOBLEUINT32 *plength);
MOBLE_RESULT Generic_DefaultPower_Set(const MOBLEUINT8 *plevel_param , 
                                             MOBLEUINT32 length);
MOBLE_RESULT Generic_PowerRange_Set(const MOBLEUINT8 *pRange_param , 
                                             MOBLEUINT32 length);
MOBLE_RESULT Generic_PowerRange_Status(MOBLEUINT8 *pRange_status , 
                                             MOBLEUINT32 *plength);
MOBLE_RESULT PowerLevelPacket_Check(MOBLE_ADDRESS src_addrs ,
                                             MOBLE_ADDRESS dest_addrs,
                                             const MOBLEUINT8 *data ,
                                             MOBLEUINT32 length);

MOBLE_RESULT Generic_BatteryLevel_Status(MOBLEUINT8* b_level_status , 
                                             MOBLEUINT32 *plength);

MOBLE_RESULT Generic_GlobalLocation_Set(const MOBLEUINT8 *glocation_param , 
                                             MOBLEUINT32 length);
MOBLE_RESULT Generic_GlobalLocation_Status(MOBLEUINT8* glocation_status , 
                                             MOBLEUINT32 *plength);

MOBLE_RESULT Generic_LocationLocal_Set(const MOBLEUINT8 *l_location_param , 
                                             MOBLEUINT32 length) ;                                          
MOBLE_RESULT Generic_LocalLocation_Status(MOBLEUINT8* l_location_status , 
                                             MOBLEUINT32 *plength);

 MOBLE_RESULT Generic_UserProperty_Set(const MOBLEUINT8 *u_Property_param , 
                                             MOBLEUINT32 length);
 MOBLE_RESULT Generic_UserProperty_Status(MOBLEUINT8* u_Property_status , 
                                             MOBLEUINT32 *plength);
 
 MOBLE_RESULT Generic_AdminProperty_Set(const MOBLEUINT8 *p_aProperty_param , 
                                             MOBLEUINT32 length);
 MOBLE_RESULT Generic_AdminProperty_Status(MOBLEUINT8 *p_aProperty_status , 
                                             MOBLEUINT32 *plength);
 
 MOBLE_RESULT Generic_ManufacturerProperty_Set(const MOBLEUINT8 *m_Property_param , 
                                             MOBLEUINT32 length);
 MOBLE_RESULT Generic_ManufacturerProperty_Status(MOBLEUINT8 *m_Property_status , 
                                             MOBLEUINT32 *plength);

MOBLE_RESULT GenericModelServer_GetOpcodeTableCb(const MODEL_OpcodeTableParam_t **data, 
                                    MOBLEUINT16 *length);

MOBLE_RESULT GenericModelServer_GetStatusRequestCb(MOBLE_ADDRESS peer_addr, 
                                    MOBLE_ADDRESS dst_peer, 
                                    MOBLEUINT16 opcode, 
                                    MOBLEUINT8 *responsedata, 
                                    MOBLEUINT32 *plength, 
                                    MOBLEBOOL response);

MOBLE_RESULT GenericModelServer_ProcessMessageCb(MOBLE_ADDRESS peer_addr, 
                                    MOBLE_ADDRESS dst_peer, 
                                    MOBLEUINT16 opcode, 
                                    MOBLEUINT8 const *data, 
                                    MOBLEUINT32 length, 
                                    MOBLEBOOL response);
void Generic_Process(void);
void Generic_Publish(void);

MOBLE_RESULT Generic_BatteryLevel_Validity(MOBLEUINT8 battery_value);
MOBLE_RESULT Generic_BatteryDischargeTime_Validity(MOBLEUINT32 discharge_time);
MOBLE_RESULT Generic_BatteryChargeTime_Validity(MOBLEUINT32 charge_time);
MOBLEUINT8 Generic_Battery_CheckPresence(MOBLEUINT8 flag_param);
MOBLEUINT8 Generic_Battery_CheckIndication(MOBLEUINT8 flag_param);
MOBLEUINT8 Generic_Battery_CheckChargeable(MOBLEUINT8 flag_param);
MOBLEUINT8 Generic_Battery_CheckServiceable(MOBLEUINT8 flag_param);

MOBLE_RESULT BluenrgMesh_AddGenericModels(void);

void Generic_GetStepValue(MOBLEUINT8 stepParam);

void Generic_PowerLevelBinding(MOBLEUINT8 bindingFlag);
void GenericOnOff_LightActualBinding(Generic_OnOffParam_t* onOff_param);
void GenericLevel_LightActualBinding(Generic_LevelParam_t* gLevel_param);
void GenericLevel_CtlTempBinding(Generic_LevelParam_t * bLevelParam);

MOBLE_RESULT Generic_OnOffTransitionBehaviour(MOBLEUINT8 *GetValue);
MOBLE_RESULT Generic_LevelTransitionBehaviour(MOBLEUINT8 *GetValue);

MOBLE_RESULT GenericOnOffStateUpdate_Process(void);
MOBLE_RESULT GenericLevelStateUpdate_Process(void);
MOBLE_RESULT GenericPowerLevelStateUpdate_Process(void);


   
#endif /* __GENERIC_H */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

