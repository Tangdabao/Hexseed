/******************************************************************************
* @file    appli_vendor.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   Application interface for Vendor Mesh Models 
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
#include "vendor.h"
#include "appli_vendor.h"
#include "models_if.h"
#include "common.h"
#include "PWM_handlers.h"
#include "PWM_config.h"
#include "mesh_cfg.h"
#include <string.h>


/** @addtogroup MODEL_VENDOR
*  @{
*/

/** @addtogroup Vendor_Model_Callbacks
*  @{
*/

/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
MOBLEUINT8 ResponseBuffer[8];
MOBLEUINT8 BuffLength;
extern MOBLEUINT8 Appli_LedState;
extern MOBLEUINT8 ProxyFlag;
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
* @brief  Process the Vendor Device Info Command
* @param  data: Pointer to the data received from peer_addr
* @param  length: Length of the data
* @retval MOBLE_RESULT status of result
*/          
MOBLE_RESULT Appli_Vendor_DeviceInfo(MOBLEUINT8 const *data, MOBLEUINT32 length)
{
        MOBLEUINT8 tempBuffer[10];
        MOBLE_RESULT status = MOBLE_RESULT_SUCCESS;  
        
        MOBLEUINT8 subCmd = data[0];
        char *libVersion;
        char *subLibVersion;
        MOBLEUINT8 inc = 0;
        /*First Byte is sending the Sub Command*/      
        ResponseBuffer[0] = subCmd;
        
        switch(subCmd)
        {
        case IC_TYPE:
          {
            #ifdef BLUENRG1           
            ResponseBuffer[1] = BLUENRG1_BRD;              
            #endif
            
            #ifdef BLUENRG2              
            ResponseBuffer[1] = BLUENRG2_BRD;              
            #endif
            
            #ifdef BLUENRG_MS              
            ResponseBuffer[1] = BLUENRG_MS_BRD;               
            #endif
            
            BuffLength = 2;
            
            break;
          }
        case LIB_VER:
          {
            libVersion = BluenrgMesh_GetLibraryVersion();
            while(*libVersion != '\0')
            {
              tempBuffer[inc] = *libVersion;
              libVersion++;  
              #if !defined(DISABLE_TRACES)
              printf("Lib version is %x\n\r" ,(unsigned char)tempBuffer[inc]); 
              #endif
              inc++;
            }             
            ResponseBuffer[1]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[0]);
            ResponseBuffer[2]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[1]);
            ResponseBuffer[3]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[3]);
            ResponseBuffer[4]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[4]);
            ResponseBuffer[5]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[6]);
            ResponseBuffer[6]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[7]);
            ResponseBuffer[7]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[8]);
            BuffLength = 8;      
            break;
          }
        case LIB_SUB_VER:
          {
            subLibVersion = BluenrgMesh_GetLibrarySubVersion();
            while(*subLibVersion != '\0')
            {
              tempBuffer[inc] = * subLibVersion;
              subLibVersion++;  
              #if !defined(DISABLE_TRACES)
              printf(" Lib Sub Version is %x\n\r" ,(unsigned char)tempBuffer[inc]); 
              #endif
              inc++;
            }           
            ResponseBuffer[1]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[0]);
            ResponseBuffer[2]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[1]);
            ResponseBuffer[3]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[3]);
            ResponseBuffer[4]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[5]);
            ResponseBuffer[5]= BluenrgMesh_ModelsASCII_To_Char(tempBuffer[7]);
            ResponseBuffer[6]= tempBuffer[9];
            
            BuffLength = 7;
            
            break;
          }
        case APPLICATION_VER:
          {
            /*Insert Command to check Application Version*/
            break;
          }
          
        default:
          {
            status = MOBLE_RESULT_FALSE;
            break;
          }
          
        }
        
        return status;
}

/**
* @brief  Process the Vendor Test Command 
* @param  data: Pointer to the data received from peer_addr
* @param  length: Length of the data
* @retval MOBLE_RESULT status of result
*/          
MOBLE_RESULT Appli_Vendor_Test(MOBLEUINT8 const *data, MOBLEUINT32 length)
{
       MOBLE_RESULT status = MOBLE_RESULT_SUCCESS;  
       MOBLEUINT8 subCmd = data[0];
       /*First Byte is sending the Sub Command*/      
       ResponseBuffer[0]=subCmd;

       switch(subCmd)
       {             
           case APPLI_TEST_ECHO: 
             {               
               memcpy ((ResponseBuffer+1),data,length);
               BuffLength = length+1;
               break;
             }
           case APPLI_TEST_RANDOMIZATION_RANGE:  
             {
               /*Insert Test related Commands here*/
               break;
             }
           case APPLI_TEST_COUNTER:
             {
               /*Insert Test related Commands here*/
               break;
             }
           case APPLI_TEST_INC_COUNTER: 
             {
               /*Insert Test related Commands here*/
               break;
             }
           default:
             {
                status = MOBLE_RESULT_FALSE;
                break;
             }
        }
       return status;
}

/**
* @brief  Process the Vendor LED Control Command
* @param  data: Pointer to the data received from peer_addr
* @param  length: Length of the data
* @param  elementNumber : element selected for a node        
* @retval MOBLE_RESULT status of result
*/ 
MOBLE_RESULT Appli_Vendor_LEDControl( MOBLEUINT8 const *data, MOBLEUINT32 length,
                                       MOBLEUINT8 elementNumber , MOBLE_ADDRESS dst_peer)
{
      MOBLE_RESULT status = MOBLE_RESULT_SUCCESS;
      MOBLEUINT8 subCommand; 
      subCommand = data[0];
      MOBLEUINT16 duty;
      MOBLEUINT16 intensityValue;
      tClockTime delay_t = Clock_Time();
      
      switch(subCommand)
      {
       /* 
       Meesage Received     B0     B1    B2      B3    B4    B5    B6     B7 
                   B0 - Sub-Cmd LED
                   B1-B7 - Data Bytes       
       */
      case APPLI_CMD_LED_BULB:
        {
          if(elementNumber == FIRST_ELEMENT)
          {
            Appli_LedState = *(data+1); /* Toggle the state of the Blue LED */
          }
          else if(elementNumber == SECOND_ELEMENT)
          {           
            Modify_PWM(1, 3990); /* Set the intensity value */
          }
          break;
        }
        
        /* Toggle Command */  
      case APPLI_CMD_TOGGLE:
        {
          if(elementNumber == FIRST_ELEMENT)
          {
             /*
             when device is working as proxy and is a part of node
             delay will be included in the toggelinf of led.
            */
            if((ProxyFlag == 1) && (ADDRESS_IS_GROUP(dst_peer)))
            {
              while((Clock_Time() - delay_t) < 100);
            }
            Appli_LedState = !Appli_LedState; /* Toggle the state of the Blue LED */
          }
          else if(elementNumber == SECOND_ELEMENT)
          {
            Modify_PWM(1, 3990); /* Set the intensity value */
          }
          break;
        }
        /* On Command */  
      case APPLI_CMD_ON:
        {
          if(elementNumber == FIRST_ELEMENT)
          {
             /*
             when device is working as proxy and is a part of node
             delay will be included in the toggelinf of led.
            */
            if((ProxyFlag == 1) && (ADDRESS_IS_GROUP(dst_peer)))
            {
               while ((Clock_Time() - delay_t) < 100);
            }
              Appli_LedState = 1; /* Switch On the Blue LED */
          }
          else if(elementNumber == SECOND_ELEMENT)
          {
            Modify_PWM(1, 3990); /* Set the intensity value */
          }
          break;
        }
        /* Off Command */  
      case APPLI_CMD_OFF:
        {
          if(elementNumber == FIRST_ELEMENT)
          {
             /*
             when device is working as proxy and is a part of node
             delay will be included in the toggelinf of led.
            */
            if((ProxyFlag == 1) && (ADDRESS_IS_GROUP(dst_peer)))
            {
              while ((Clock_Time() - delay_t) < 100);
            }
              Appli_LedState = 0; /* Switch Off the Blue LED */
          }
          else if(elementNumber == SECOND_ELEMENT)
          {
            Modify_PWM(1, 3990); /* Set the intensity value */
          }
          
          break;
        }
        /* intensity command */
      case APPLI_CMD_LED_INTENSITY:
        {
          if(elementNumber == FIRST_ELEMENT)
          {
             intensityValue = data[2] << 8;
             intensityValue |= data[1];
             
             duty = PwmValueMapping(intensityValue , 0x7FFF ,0); 
						 printf("duty:%d",duty);
             Modify_PWM(1, duty);   /* 2 is for GPIO_6. Software PWM */ 
          }
          else if(elementNumber == SECOND_ELEMENT)
          {
            Modify_PWM(1, 3990); /* Set the intensity value */
          }
          break;
        }
        /* Default case - Not valid command */
      default:
        {
          status = MOBLE_RESULT_FALSE;
          break;
        }
      }
         /*Buffer will be sent for Reliable Response*/
         /*First Byte is Sub Command and 2nd Byte is LED Status*/
           ResponseBuffer[0] = subCommand;
         if(subCommand == APPLI_CMD_LED_INTENSITY)
         {
            ResponseBuffer[1] = intensityValue >> 8 ;
            ResponseBuffer[2] = intensityValue ;
            BuffLength = 3;
         }
         else
         {
             ResponseBuffer[1] = Appli_LedState ;
             BuffLength = 2; 
         }
      
       return status;
}

/**
 * @}
 */

/**
 * @}
 */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/

