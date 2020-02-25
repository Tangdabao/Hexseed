/**
******************************************************************************
* @file    mesh cfg.h
* @author  BLE Mesh Team
* @version V1.09.000
* @date    15-Oct-2018
* @brief   Header file for mesh_usr_cfg.c 
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
#ifndef __MESH_CFG_H
#define __MESH_CFG_H

/* Includes ------------------------------------------------------------------*/
#include "bluenrg_mesh.h"

/* Exported macro ------------------------------------------------------------*/


/*******************************************************************************
*** Following section helps to configure the Application of Mesh     ***********
*******************************************************************************/

#define APPLICATION_NUMBER_OF_ELEMENTS 1

/* Contains a 16-bit company identifier assigned by the Bluetooth SIG
(the list is available @ https://www.bluetooth.com/specifications/assigned-numbers/company-identifiers )
For STMicroelectronics : it is 0x0030 */
#define COMPANY_ID 0x0030

/* Contains a 16-bit vendor-assigned product identifier */
#define PRODUCT_ID 0x0001

/* Contains a 16-bit vendor-assigned product version ID */
#define PRODUCT_VERSION_ID 0x0001

#define MAX_APPLICATION_PACKET_SIZE 160

/*******************************************************************************
********** MAC Address Configuration *******************************************
*******************************************************************************/

/*
*  Define to enable external MAC handling, 
*  DONT change the Values 0x01, 0x02, 0x03 
*  SELECT ONLY One of the Option 
*/
//#define GENERATE_STATIC_RANDOM_MAC  0x01   
//#define EXTERNAL_MAC_ADDR_MGMT      0x02
#define INTERNAL_UNIQUE_NUMBER_MAC    0x03

/* Declare this value as 0x01 if the External Address is PUBLIC Address */
/* For example like this: #define EXTERNAL_MAC_IS_PUBLIC_ADDR 0x1       */
/* Else, by default, the external address will be treated as RANDOM     */
#define EXTERNAL_MAC_IS_PUBLIC_ADDR 0x0


#ifdef EXTERNAL_MAC_ADDR_MGMT
  #define EXTERNAL_MAC_TYPE (uint8_t)(EXTERNAL_MAC_IS_PUBLIC_ADDR<<7)
#else
  #define EXTERNAL_MAC_TYPE (uint8_t)0
#endif


#if  (!(GENERATE_STATIC_RANDOM_MAC)) &&  (!(EXTERNAL_MAC_ADDR_MGMT)) && (!(INTERNAL_UNIQUE_NUMBER_MAC))
#error "Please select atleast one Option"
#endif 

/******************************************************************************/

#define STATIC_OOB_SIZE                 16U
extern const MOBLEUINT8 StaticOobBuff[STATIC_OOB_SIZE];

/* Define the following Macros to change the step resolution and step count value */
#define TRANSITION_SCALER               4
#define PWM_TIME_PERIOD                 32000U

/* Define the Macro for enabling/disabling the Publishing with Generic on off
   or by Vendor Model.
@ define Macro for Vendor Publishing
@ Undefine or comment Macro for Generic On Off Publishing
*/
//#define VENDOR_MODEL_PUBLISH

/* Macros for the Property id for the sensors */
#define TEMPERATURE_PID  0X004F
#define PRESSURE_PID     0X2A6D

/*******************************************************************************
*** Following section helps to select right configuration of Models  ***********
*******************************************************************************/
/******* Define the following Macros to enable the usage of the  Models  ******/

/* Define the following Macros to enable the usage of the Server Generic Models  */
#define ENABLE_GENERIC_MODEL_SERVER_ONOFF 
#define ENABLE_GENERIC_MODEL_SERVER_LEVEL
/*
#define ENABLE_GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME
#define ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF
#define ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF_SETUP
#define ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
#define ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL_SETUP
#define ENABLE_GENERIC_MODEL_SERVER_BATTERY
#define ENABLE_GENERIC_MODEL_SERVER_LOCATION
#define ENABLE_GENERIC_MODEL_SERVER_LOCATION_SETUP
#define ENABLE_GENERIC_MODEL_SERVER_ADMIN_PROPERTY
#define ENABLE_GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY
#define ENABLE_GENERIC_MODEL_SERVER_USER_PROPERTY
#define ENABLE_GENERIC_MODEL_SERVER_CLIENT_PROPERTY
*/

/* Define the following Macros to enable the usage of the Client Generic Models  */

/*
#define ENABLE_GENERIC_MODEL_CLIENT_ONOFF 
#define ENABLE_GENERIC_MODEL_CLIENT_LEVEL
*/

/* Define the following Macros to enable the usage of the Light Models  */

#define ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS
#define ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS_SETUP 
#define ENABLE_LIGHT_MODEL_SERVER_CTL
#define ENABLE_LIGHT_MODEL_SERVER_CTL_SETUP 
#define ENABLE_LIGHT_MODEL_SERVER_CTL_TEMPERATURE
#define ENABLE_LIGHT_MODEL_SERVER_HSL 
#define ENABLE_LIGHT_MODEL_SERVER_HSL_SETUP  
#define ENABLE_LIGHT_MODEL_SERVER_HSL_HUE 
#define ENABLE_LIGHT_MODEL_SERVER_HSL_SATURATION 

/*
#define ENABLE_LIGHT_MODEL_SERVER_XYL 
#define ENABLE_LIGHT_MODEL_SERVER_XYL_SETUP 
#define ENABLE_LIGHT_MODEL_SERVER_LC 
#define ENABLE_LIGHT_MODEL_SERVER_LC_SETUP 
*/

/* Define the following Macros to enable the usage of the Sensor Models  */
#define ENABLE_SENSOR_MODEL_SERVER
#define ENABLE_SENSOR_MODEL_SERVER_SETUP


/*******************************************************************************
****** Following section helps to select right configuration of node ***********
*******************************************************************************/
/*
*  Different features supported by BlueNRG-Mesh. Uncomment according to application.
*      Low power feature enabled node do not support other features. 
*      Do not define any other feature if Low Power feature is defined
*/

#define ENABLE_RELAY_FEATURE
#define ENABLE_PROXY_FEATURE
#define ENABLE_FRIEND_FEATURE

/* #define ENABLE_LOW_POWER_FEATURE */

#ifdef ENABLE_RELAY_FEATURE
#define RELAY_FEATURE 1
#else
#define RELAY_FEATURE 0
#endif

#ifdef ENABLE_PROXY_FEATURE
#define PROXY_FEATURE 1
#else
#define PROXY_FEATURE 0
#endif

#ifdef ENABLE_FRIEND_FEATURE
#define FRIEND_FEATURE 1
#else
#define FRIEND_FEATURE 0
#endif

#ifdef ENABLE_LOW_POWER_FEATURE
#define LOW_POWER_FEATURE 1
#else
#define LOW_POWER_FEATURE 0
#endif

#if (LOW_POWER_FEATURE && RELAY_FEATURE)
#error "Low power node can't be relay node"
#elif (LOW_POWER_FEATURE && PROXY_FEATURE)
#error "Low power node can't be proxy node"
#elif (LOW_POWER_FEATURE && FRIEND_FEATURE)
#error "Low power node can't be friend node"
#endif

#define MESH_FEATURES (RELAY_FEATURE << 0 | PROXY_FEATURE << 1 | FRIEND_FEATURE << 2 | LOW_POWER_FEATURE << 3)

/* 
*  Minimum gap between successive transmissions
*  varies from 10 to 65535 
*/
#define TR_GAP_BETWEEN_TRANSMISSION      50U
#define TRANSMIT_RECEIVE_PARAMS          \
{                                        \
    TR_GAP_BETWEEN_TRANSMISSION          \
}

/* 
* Friend node receive window size is fixed at 50 ms
*/

/* 
* Friend node subscription list size is fixed at 4
*/

/* 
* Friend node maximum number of messages is fixed at 16
*/

/* 
*  Number of Low power nodes that can be associated with Friend node
*  varies from 1 to 10
*/
#define FN_NO_OF_LPNS                    2U
#define FRIEND_NODE_PARAMS               \
{                                        \
    FN_NO_OF_LPNS                        \
}

/* 
*  For prioritizing friendship offer with good RSSI link
*  varies from 0 to 3
*  Ref @Mesh_v1.0
*/
#define LPN_RSSI_FACTOR_LEVEL            1U

/* 
*  For prioritizing friendship offer with good receive window factor
*  varies from 0 to 3
*  Ref @Mesh_v1.0
*/
#define LPN_RECIVE_WINDOW_FACTOR_LEVEL   1U

/* 
*  Minimum packets queue size required
*  varies from 1 to 7
*  Ref @Mesh_v1.0
*/
#define LPN_MINIMUM_QUEUE_SIZE_LOG       2U

/* 
*  (unit ms)
*  varies from 0x0A to 0xFF
*  Ref @Mesh_v1.0
*/
#define LPN_RECEIVE_DELAY                150U

/* 
*  Poll timeout value after which friendship cease to exist (unit 100ms)
*  varies from 0x00000A to 0x34BBFF
*  Ref @Mesh_v1.0
*/
#define LPN_POLL_TIMEOUT                 2000U

/* 
*  Maximum receive window size acceptable to low power node (unit ms)
*  varies from 10 to 255
*  Ref @Mesh_v1.0
*/
#define LPN_RECEIVE_WINDOW_SIZE          55U

/* 
*  Minimum friend's subscription list size capability required by lpn
*  varies from 1 to 5
*  Ref @Mesh_v1.0
*/
#define LPN_SUBSCR_LIST_SIZE             2U

/* 
*  Frequency at which low power node would send friend request (unit 100ms)
*  varies from 0 to 255
*/
#define LPN_FRIEND_REQUEST_FREQUENCY     50U

/* 
*  Frequency at which low power node would poll friend node (unit 100ms)
*  should be less than poll timeout
*/
#define LPN_FRIEND_POLL_FREQUENCY        25U

/* 
*  Minimum RSSI required by low power node
*  should be less than equal to -60
*/
#define LPN_MINIMUM_RSSI                 -100

/* 
*  Retries to be made by lpn before termination of friendship
*  varies from 2 to 10
*/
#define LPN_NO_OF_RETRIES                10U

#define LOW_POWER_NODE_PARAMS            \
{                                        \
  LPN_RSSI_FACTOR_LEVEL,                 \
  LPN_RECIVE_WINDOW_FACTOR_LEVEL,        \
  LPN_MINIMUM_QUEUE_SIZE_LOG,            \
  LPN_RECEIVE_DELAY,                     \
  LPN_POLL_TIMEOUT,                      \
  LPN_FRIEND_REQUEST_FREQUENCY,          \
  LPN_FRIEND_POLL_FREQUENCY,             \
  LPN_RECEIVE_WINDOW_SIZE,               \
  LPN_SUBSCR_LIST_SIZE,                  \
  LPN_MINIMUM_RSSI,                      \
  LPN_NO_OF_RETRIES                      \
}

#define UNPROV_NODE_INFO_PARAMS          \
{                                        \
    STATIC_OOB_SIZE,                     \
    StaticOobBuff                        \
}

#if FRIEND_FEATURE
#define FRIEND_BUFF_DYNAMIC_MEMORY_SIZE    FN_NO_OF_LPNS*816+4
#elif LOW_POWER_FEATURE
#define FRIEND_BUFF_DYNAMIC_MEMORY_SIZE    112U
#else
#define FRIEND_BUFF_DYNAMIC_MEMORY_SIZE    1U
#endif

#define DYNAMIC_MEMORY_SIZE                4096U

#define SEGMENTATION_COUNT             (MAX_APPLICATION_PACKET_SIZE / 12) + 2 
#define SAR_BUFFER_SIZE                ((uint8_t)SEGMENTATION_COUNT) * 40 

#define SdkEvalComIOUartIrqHandler         UART_Handler  /* Added Interrupt handler for Uart */

/* Exported variables  ------------------------------------------------------- */

extern const DynBufferParam_t DynBufferParam;
extern const tr_params_t TrParams;
extern const lpn_params_t LpnParams;
extern const fn_params_t FnParams;
extern const unprov_node_info_params_t UnprovNodeInfoParams;

/* Exported Functions Prototypes ---------------------------------------------*/

#endif /* __MESH_CFG_H */
