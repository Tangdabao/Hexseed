/**
******************************************************************************
* @file    mesh cfg.h
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
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
//此处修改最大包长
#define MAX_APPLICATION_PACKET_SIZE 380

/* 
*  Define to enable external MAC handling, 
*  DONT change the Values 0x01, 0x02, 0x03 
*  SELECT ONLY One of the Option 
*/
//#define GENERATE_STATIC_RANDOM_MAC  0x01   
//#define EXTERNAL_MAC_ADDR_MGMT      0x02
#define INTERNAL_UNIQUE_NUMBER_MAC    0x03


#if  (!(GENERATE_STATIC_RANDOM_MAC)) &&  (!(EXTERNAL_MAC_ADDR_MGMT)) && (!(INTERNAL_UNIQUE_NUMBER_MAC))
#error "Please select atleast one Option"
#endif 

/* Define the following Macros to enable the usage of the Generic Models  */
#define ENABLE_GENERIC_MODEL_SERVER_ONOFF 
#define ENABLE_GENERIC_MODEL_SERVER_LEVEL
//#define ENABLE_GENERIC_MODEL_SERVER_DEFAULT_TRANSITION_TIME
//#define ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF
//#define ENABLE_GENERIC_MODEL_SERVER_POWER_ONOFF_SETUP
//#define ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL
//#define ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL_SETUP
//#define ENABLE_GENERIC_MODEL_SERVER_BATTERY
//#define ENABLE_GENERIC_MODEL_SERVER_LOCATION
//#define ENABLE_GENERIC_MODEL_SERVER_LOCATION_SETUP
//#define ENABLE_GENERIC_MODEL_SERVER_ADMIN_PROPERTY
//#define ENABLE_GENERIC_MODEL_SERVER_MANUFACTURER_PROPERTY
//#define ENABLE_GENERIC_MODEL_SERVER_USER_PROPERTY
//#define ENABLE_GENERIC_MODEL_SERVER_CLIENT_PROPERTY

/* Define the following Macros to enable the usage of the Light Models  */

#define ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS
#define ENABLE_LIGHT_MODEL_SERVER_LIGHTNESS_SETUP 
#define ENABLE_LIGHT_MODEL_SERVER_CTL
#define ENABLE_LIGHT_MODEL_SERVER_CTL_SETUP 
#define ENABLE_LIGHT_MODEL_SERVER_CTL_TEMPERATURE
//#define ENABLE_LIGHT_MODEL_SERVER_HSL 
//#define ENABLE_LIGHT_MODEL_SERVER_HSL_SETUP  
//#define ENABLE_LIGHT_MODEL_SERVER_HSL_HUE 
//#define ENABLE_LIGHT_MODEL_SERVER_HSL_SATURATION 
//#define ENABLE_LIGHT_MODEL_SERVER_XYL 
//#define ENABLE_LIGHT_MODEL_SERVER_XYL_SETUP 
//#define ENABLE_LIGHT_MODEL_SERVER_LC 
//#define ENABLE_LIGHT_MODEL_SERVER_LC_SETUP 


#define ENABLE_RELAY_FEATURE
#define ENABLE_PROXY_FEATURE
//#define ENABLE_FRIEND_FEATURE
//#define ENABLE_LOW_POWER_FEATURE

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

#if (RELAY_FEATURE && LOW_POWER_FEATURE)
#error "Low power node can't be relay node"
#elif (PROXY_FEATURE && FRIEND_FEATURE)
#error "Proxy node can't be friend node"
#elif (PROXY_FEATURE && LOW_POWER_FEATURE)
#error "Proxy node can't be low power node"
#elif (FRIEND_FEATURE && LOW_POWER_FEATURE)
#error "Friend node can't be low power node"
#endif

#define MESH_FEATURES (RELAY_FEATURE << 0 | PROXY_FEATURE << 1 | FRIEND_FEATURE << 2 | LOW_POWER_FEATURE << 3)

#define FN_NO_OF_LPNS                    2
#define FRIEND_NODE_PARAMS               \
{                                        \
    FN_NO_OF_LPNS,                       \
}
#define FN_MAX_NO_OF_LPNS                2

#define LPN_RSSI_FACTOR_LEVEL            1      /* varies from 0 to 3 */
#define LPN_RECIVE_WINDOW_FACTOR_LEVEL   1      /* varies from 0 to 3 */
#define LPN_MINIMUM_QUEUE_SIZE_LOG       2      /* varies from 1 to 7 */
#define LPN_RECEIVE_DELAY                150    /* varies from 0x0A to 0xFF */
#define LPN_POLL_TIMEOUT                 2000   /* varies from 0x00000A to 0x34BBFF */
#define LPN_FRIENDSHIP_EST_FREQUENCY     25     /* varies from 0 to 255 */
#define LPN_POLL_FREQUENCY               25     /* should be less than poll timeout */
#define LPN_RECEIVE_WINDOW_SIZE          255    /* varies from 10 to 255 */
#define LPN_SUBSCR_LIST_SIZE             2      /* varies from 1 to 5 */
#define LPN_MINIMUM_RSSI                 -100   /* should be less than equal to -60 */
#define LPN_NO_OF_RETRIES                10     /* varies from 2 to 10 */
#define LOW_POWER_NODE_PARAMS            \
{                                        \
  LPN_RSSI_FACTOR_LEVEL,                 \
  LPN_RECIVE_WINDOW_FACTOR_LEVEL,        \
  LPN_MINIMUM_QUEUE_SIZE_LOG,            \
  LPN_RECEIVE_DELAY,                     \
  LPN_POLL_TIMEOUT,                      \
  LPN_FRIENDSHIP_EST_FREQUENCY,          \
  LPN_POLL_FREQUENCY,                    \
  LPN_RECEIVE_WINDOW_SIZE,               \
  LPN_SUBSCR_LIST_SIZE,                  \
  LPN_MINIMUM_RSSI,                      \
  LPN_NO_OF_RETRIES                      \
}

#if FRIEND_FEATURE
#define FRIEND_BUFF_DYNAMIC_MEMORY_SIZE    (FN_MAX_NO_OF_LPNS*816+4)
#elif LOW_POWER_FEATURE
#define FRIEND_BUFF_DYNAMIC_MEMORY_SIZE    (108)
#else
#define FRIEND_BUFF_DYNAMIC_MEMORY_SIZE    (1)
#endif

#ifdef STM32
#define DYNAMIC_MEMORY_SIZE (3024)
#else
#define DYNAMIC_MEMORY_SIZE (2024)
#endif


/* Exported variables  ------------------------------------------------------- */

extern const DynBufferParam_t DynBufferParam;
extern const lpn_params_t LpnParams;
extern const fn_params_t FnParams;

/* Exported Functions Prototypes ---------------------------------------------*/

#endif /* __MESH_CFG_H */
