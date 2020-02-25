/**
******************************************************************************
* @file    models_if.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   Mesh Modes interface file of the application
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
#include "models_if.h"
#include "appli_mesh.h"
#include "mesh_cfg.h" 
#include "generic.h"
#include "vendor.h"
#include "light.h"
#include "appli_generic.h"
#include "appli_vendor.h"
#include "appli_light.h"
#include <bluenrg1_config.h>


/** @addtogroup BlueNRG_Mesh
 *  @{
 */

/** @addtogroup models_BlueNRG1
 *  @{
 */

/* Private typedef -----------------------------------------------------------*/
typedef struct
{
  MOBLE_ADDRESS peer;
  MOBLEUINT8 command;
  MOBLEUINT8 data[DATA_BUFFER_LENGTH]; /* 8-Bytes response packet */
  MOBLEUINT32 length;
} APPLI_SEND_RESPONSE_MODULE;


typedef struct
{
  MOBLEUINT8 packet_count;
  MOBLEUINT32 send_time;
  APPLI_SEND_RESPONSE_MODULE* head;
  MOBLEUINT8 head_index;
  APPLI_SEND_RESPONSE_MODULE packet[MAX_PENDING_PACKETS_QUE_SIZE];
} APPLI_PENDING_PACKETS;
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
   

/* Private variables ---------------------------------------------------------*/
APPLI_PENDING_PACKETS Appli_PendingPackets = {0};
const MOBLE_VENDOR_CB_MAP vendor_cb = 
{
  Vendor_WriteLocalDataCb,
  Vendor_ReadLocalDataCb,
  Vendor_OnResponseDataCb
};


const Appli_Vendor_cb_t VendorAppli_cb = 
{
  /*Vendor Commads*/
  Appli_Vendor_LEDControl,
  Appli_Vendor_DeviceInfo,
  Appli_Vendor_Test,
  Appli_LedCtrl
};

   
const Appli_Generic_cb_t GenericAppli_cb = 
{
  /* Generic OnOff callbacks */
  Appli_Generic_OnOff_Set,
  
  /* Generic Level callbacks */
  Appli_Generic_Level_Set,
  Appli_Generic_LevelDelta_Set,
  Appli_Generic_LevelMove_Set,
  
  /* Transit Time callback */
  Appli_Generic_TransitionDefaultTime_Set,
  
   /* Generic On Power Up callback */
  Appli_Generic_OnPowerUp_Set,  
  
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL  
  /* Generic Power Level callback */
  Appli_Generic_ActualPowerLevel_Set,
  
  Appli_Generic_DefaultPower_Set,
  
  Appli_Generic_PowerRange_Set,
  
#endif
  
};

const Appli_Generic_State_cb_t Appli_GenericState_cb =
{
  
 /* Generic Get On Off status */
  Appli_Generic_GetOnOffStatus,
  
  /* Generic Get level status */
  Appli_Generic_GetLevelStatus,
  
  /* Generic Get TRansition Time Status */
  Appli_Generic_GetTransitionTime,
#ifdef ENABLE_GENERIC_MODEL_SERVER_POWER_LEVEL   
  /* Generic Get Power level status */
  Appli_Generic_GetPowerLevelStatus,
  
  /* Generic Get Default Power level status */
  Appli_Generic_GetDefaultPowerStatus,
  
  /* Generic Get Power level Range status */
  Appli_Generic_GetPowerRangeStatus,
  
#endif  
  
#ifdef ENABLE_GENERIC_MODEL_SERVER_BATTERY   
  /* Generic Get Battery Level Parameter */
  Appli_Generic_GetBatteryLevelStatus
#endif    
};

const Appli_Light_GetStatus_cb_t Appli_Light_GetStatus_cb = 
{
  Appli_Light_GetLightnessStatus,
  Appli_Light_GetLightnessLinearStatus,
  Appli_Light_GetLightnessDefaultStatus,
  Appli_Light_GetLightnessRangeStatus,
  Appli_Light_GetCtlLightStatus,
  Appli_Light_GetCtlTemperatureStatus,
  Appli_Light_GetCtlTempRange,
  Appli_Light_GetCtlDefaultStatus
};

const MODEL_Generic_cb_t Model_Generic_cb = 
{
  GenericModelServer_GetOpcodeTableCb,
  GenericModelServer_GetStatusRequestCb,
  GenericModelServer_ProcessMessageCb
};

const Appli_Light_cb_t LightAppli_cb = 
{
  /* Light Lightness callbacks */
  Appli_Light_Lightness_Set,
  Appli_Light_Lightness_Linear_Set,
  Appli_Light_Lightness_Default_Set,
  Appli_Light_Lightness_Range_Set,
  Appli_Light_Ctl_Set,
  Appli_Light_CtlTemperature_Set,
  Appli_Light_CtlTemperature_Range_Set,
  Appli_Light_CtlDefault_Set
};

const MODEL_Light_cb_t Model_Light_cb = 
{
  LightModelServer_GetLightOpcodeTableCb,
  LightModelServer_GetStatusRequestCb,
  LightModelServer_ProcessMessageCb
};


/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/


/**
* @brief  Initialization Commands for Models
* @param  void
* @retval void
*/    
void BluenrgMesh_ModelsInit(void)
{
    /* Callbacks used by BlueNRG-Mesh library */
  BluenrgMesh_SetVendorCbMap(&vendor_cb);
  
  /* Callbacks used by BlueNRG-Mesh Generic Models */
  BluenrgMesh_SetModelGenericCbMap(&Model_Generic_cb);
  
  BluenrgMesh_AddGenericModels();
  
   /* Callbacks used by BlueNRG-Mesh Generic Models */
  BluenrgMesh_SetModelLightCbMap(&Model_Light_cb);
  
  BluenrgMesh_AddLightingModels();
  
  /* Configuration of all the added models */
  BluenrgMesh_Models_Config();

}

/**
* @brief  Process Commands for Models
* @param  void
* @retval void
*/    
void BluenrgMesh_ModelsProcess(void)
{
Generic_Process();
Lighting_Process();
Vendor_Process();
}

/**
* @brief  Publish Command for Models
* @param  void
* @retval void
*/    
void BluenrgMesh_ModelsCommand(void)
{
Generic_Publish();
Vendor_Publish();
}

/**
* @brief  Get the Element Number for selected Model 
* @param  dst_peer : Destination Address received
* @retval MOBLEUINT8 : elementIndex
*/ 
MOBLEUINT8 BluenrgMesh_ModelsGetElementNumber(MOBLE_ADDRESS dst_peer)
{
  
  MOBLE_ADDRESS nodeAddress;
  MOBLEUINT8 elementNumber;
  
  nodeAddress = BluenrgMesh_GetAddress();
  elementNumber = ((dst_peer - nodeAddress)+1);
  
  return elementNumber;
}

/**
* @brief  Check Subscription of Elements for Group Address for selected Model 
* @param  dst_peer : Destination Address received
* @param  elementNumber : Number of element to check Subscription
* @retval MOBLE_RESULT status of result
*/ 
MOBLE_RESULT BluenrgMesh_ModelsCheckSubscription(MOBLE_ADDRESS dst_peer, \
                                                        MOBLEUINT8 elementNumber)
{
  MOBLE_RESULT status = MOBLE_RESULT_FAIL;
  MOBLE_ADDRESS subscriptionList[10] = {0};
  MOBLEUINT8 length;
  
  BluenrgMesh_GetSubscriptionAddress(subscriptionList,&length,elementNumber);
  
  
  for(uint8_t list=0; list<length; list++)
  {
      if(dst_peer == subscriptionList[list])
      {
      status = MOBLE_RESULT_SUCCESS;    
      break;
      }
  }
  
  return status;
}

/**
* @brief  Schedule a packet to be sent with randomized send timestamp  
*         If a que is empty, random timestamp is calculated
*         Subsequent packets are sent in sequence
* @param  peer:    Address of the peer
* @param  status:  Command status
* @param  data:    Data buffer.
* @param  length:  Length of data in bytes.
* @retval None
*/ 
void BluenrgMesh_ModelsDelayPacket(MOBLE_ADDRESS peer, 
                              MOBLEUINT8 command, 
                              MOBLEUINT8 const * data, 
                              MOBLEUINT32 length)
{
  MOBLEUINT8 random_time[8];
  
  if (Appli_PendingPackets.packet_count == 0)
  {
    Appli_PendingPackets.packet_count = 1;
    hci_le_rand(random_time);
    Appli_PendingPackets.send_time = Clock_Time() + 
                                     DEFAULT_DELAY_PACKET_FROM + 
                                     (random_time[0] + random_time[1]*256)\
                                         %DEFAULT_DELAY_PACKET_RANDOM_TIME;    
    Appli_PendingPackets.head = Appli_PendingPackets.packet;
    Appli_PendingPackets.head_index = 0;
#if !defined(DISABLE_TRACES)	
    printf("Randomized time: %d\n\r", Appli_PendingPackets.send_time - Clock_Time());
#endif	
  }
  else 
  {
    Appli_PendingPackets.packet_count += 1;
    Appli_PendingPackets.packet_count = (Appli_PendingPackets.packet_count)%\
                                              (MAX_PENDING_PACKETS_QUE_SIZE+1);

    if (Appli_PendingPackets.head != (Appli_PendingPackets.packet + \
                                      MAX_PENDING_PACKETS_QUE_SIZE - 1))
    {
      Appli_PendingPackets.head = Appli_PendingPackets.head +1;
      Appli_PendingPackets.head_index = Appli_PendingPackets.head_index+1;
    }
    else
    {
      Appli_PendingPackets.head = Appli_PendingPackets.packet;
      Appli_PendingPackets.head_index = 0;
    }
  }  
  
  Appli_PendingPackets.head->peer = peer;
  Appli_PendingPackets.head->command = command;
  Appli_PendingPackets.head->length = length;
  for (MOBLEUINT8 count=0; count<length; count++)
  Appli_PendingPackets.head->data[count] = data[count];
}   
         
/**
* @brief  If send timestamp is reached and que is not empty, send all packets
* @param  None
* @retval None
*/
void BluenrgMesh_ModelsSendDelayedPacket(void)
{
  APPLI_SEND_RESPONSE_MODULE* ptr;
  MOBLEUINT8 temp_index;
  
  if ((Appli_PendingPackets.packet_count != 0) && 
      (Appli_PendingPackets.send_time <= Clock_Time()))
  {
    for (MOBLEUINT8 count=Appli_PendingPackets.packet_count; count!=0; count--)
    {
#if !defined(DISABLE_TRACES)		
    printf("Sending randomized packets. Packet count: %d \n\r",\
    Appli_PendingPackets.packet_count - count + 1);
#endif      
      temp_index = ((Appli_PendingPackets.head_index+MAX_PENDING_PACKETS_QUE_SIZE+1)\
                                   -count)%MAX_PENDING_PACKETS_QUE_SIZE;
      ptr = Appli_PendingPackets.packet + temp_index;
      
      BluenrgMesh_SendResponse(ptr->peer,
                               ptr->command,
                               ptr->data,
                               ptr->length);
    }
    
    Appli_PendingPackets.packet_count = 0;
  }
}


/**
* @brief  Convert ASCII value into Character
* @param  tempValue : 8bit value for conversion
* @retval MOBLEUINT8 
*/         
MOBLEUINT8 BluenrgMesh_ModelsASCII_To_Char(MOBLEUINT8 tempValue)
{
   tempValue = tempValue - 0x30;
   return tempValue;
} 

/**
 * @}
 */

/**
 * @}
 */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/
