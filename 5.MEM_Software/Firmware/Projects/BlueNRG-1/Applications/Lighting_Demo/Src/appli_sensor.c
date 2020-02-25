/**
******************************************************************************
* @file    appli_sensor.c
* @author  BLE Mesh Team
* @version V1.09.000
* @date    15-Oct-2018
* @brief   Application interface for Sensor Mesh Models 
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
#include "sensors.h"
#include "appli_light.h"
#include "appli_generic.h"
#include "appli_sensor.h"
#include "common.h"
#include "mesh_cfg.h"
#include "PWM_handlers.h"
#include "PWM_config.h"
#include "LPS25HB.h"
#include "string.h"

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
   
/* Sensor Cadence set */

typedef struct
{
  MOBLEUINT16 Prop_ID;
  MOBLEUINT16 PositiveTolenrance;
  MOBLEUINT16 NegativeTolenrance;
  MOBLEUINT8 SamplingFunction;
  MOBLEUINT8 MeasurementPeriod;
  MOBLEUINT8 UpdateInterval; 
}Appli_Sensor_DescriptorStatus_t;

/* Temperature and Pressure init structure*/
PRESSURE_DrvTypeDef* xLPS25HBDrv = &LPS25HBDrv; 

/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

#ifdef ENABLE_SENSOR_MODEL_SERVER
/**
* @brief  Appli_Sensor_Data_Status: This function is callback for Application
           when sensor get message is received
* @param  sensor_Data: Pointer to the parameters to be send in message
* @param  pLength: Length of the parameters to be sent in response
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Sensor_Data_Status(MOBLEUINT8* sensor_Data , MOBLEUINT32* pLength, MOBLEUINT16 prop_ID)
{
                                     
   MOBLEUINT32 temperatureData ;
   MOBLEUINT32 pressureData ;
   MOBLEUINT8 data_Length = 0x03;
      
      LPS25HB_GetTemperature((float*)&temperatureData);
      
      LPS25HB_GetPressure((float*)&pressureData); 
      
   if(prop_ID == TEMPERATURE_PID)
   {
      /*(prop_Id_Temp & 0x07) << 5) | (Len <<1) Format A 
        Property calculation is done like above line
      */
      *(sensor_Data) = ((TEMPERATURE_PID & 0x07) << 5) | (data_Length <<1) ; 
      *(sensor_Data+1) = (TEMPERATURE_PID >> 3) & 0xFF; 
      
      memcpy(&sensor_Data[2],(void*)&temperatureData,4);
      
      *pLength  =6;    
   } 
   else if(prop_ID == PRESSURE_PID)
   {
      /* Format B for Pressure sensor */
      *(sensor_Data+0) = ((data_Length <<1) | 0x01); 
      *(sensor_Data+1) = (MOBLEUINT8)PRESSURE_PID ;
      *(sensor_Data+2) = (MOBLEUINT8)(PRESSURE_PID >> 8);
      
      memcpy(&sensor_Data[3],(void*)&pressureData,4);
      
      *pLength  =7;    
   }
   else
   {
      /*(prop_Id_Temp & 0x07) << 5) | (Len <<1) Format A 
        Property calculation is done like above line
      */
      *(sensor_Data) = ((TEMPERATURE_PID & 0x07) << 5) | (data_Length <<1) ; 
      *(sensor_Data+1) = (TEMPERATURE_PID >> 3) & 0xFF; 
      
       memcpy(&sensor_Data[2],(void*)&temperatureData,4);
     
      /* Format B for Pressure sensor */
      *(sensor_Data+6) = ((data_Length <<1) | 0x01); 
      *(sensor_Data+7) = (MOBLEUINT8)PRESSURE_PID ;
      *(sensor_Data+8) = (MOBLEUINT8)(PRESSURE_PID >> 8);

      memcpy(&sensor_Data[9],(void*)&pressureData,4);
      
      *pLength  =13;    
   }     
      
#if !defined(DISABLE_TRACES)      
      printf("the temperature reading from sender in hex 0x%08x \n\r ", temperatureData);
      printf("the pressure reading from sender in hex 0x%08x \n\r", pressureData );
#endif      
      
  return MOBLE_RESULT_SUCCESS;
}

                                    
/**
* @brief  Appli_Sensor_Descriptor_Status: This function is callback for Application
           when sensor get message is received
* @param  sensor_Descriptor: Pointer to the parameters to be send in message
* @param  pLength: Length of the parameters to be sent in response
* @retval MOBLE_RESULT
*/ 
MOBLE_RESULT Appli_Sensor_Descriptor_Status(MOBLEUINT8* sensor_Descriptor , MOBLEUINT32* pLength)
{
   Appli_Sensor_DescriptorStatus_t Appli_Sensor_DescriptorStatus1 = {TEMPERATURE_PID,0x00,0x00,0x00,0x00,0x00};
  
    *(sensor_Descriptor) = Appli_Sensor_DescriptorStatus1.Prop_ID;
    *(sensor_Descriptor+1) = Appli_Sensor_DescriptorStatus1.Prop_ID >> 8;
    *(sensor_Descriptor+2) = Appli_Sensor_DescriptorStatus1.PositiveTolenrance;
    *(sensor_Descriptor+3) = Appli_Sensor_DescriptorStatus1.PositiveTolenrance >> 8;
    *(sensor_Descriptor+4) = Appli_Sensor_DescriptorStatus1.NegativeTolenrance;
    *(sensor_Descriptor+5) = Appli_Sensor_DescriptorStatus1.NegativeTolenrance >> 8;
    *(sensor_Descriptor+7) = Appli_Sensor_DescriptorStatus1.SamplingFunction;
    *(sensor_Descriptor+8) = Appli_Sensor_DescriptorStatus1.MeasurementPeriod;
    *(sensor_Descriptor+9) = Appli_Sensor_DescriptorStatus1.UpdateInterval;
   
    *pLength = 8;
   
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

