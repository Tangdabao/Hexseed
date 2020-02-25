/**
******************************************************************************
* @file    main.c
* @author  BLE Mesh Team
* @version V1.09.000
* @date    15-Oct-2018
* @brief   main file of the application
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
#include "appli_mesh.h"
#include "appli_light.h"
#include "models_if.h"
#include "mesh_cfg.h"
#include "PWM_config.h"
#include "PWM_handlers.h"
#include "LPS25HB.h"
#include "BlueNRG_x_device.h"
#include "miscutil.h"

/** @addtogroup BlueNRG_Mesh
 *  @{
 */

/** @addtogroup main_BlueNRG1
 *  @{
 */

/* Private typedef -----------------------------------------------------------*/

/* Private define ------------------------------------------------------------*/
/**
 * @brief  PRESSURE init structure definition
 */
PRESSURE_InitTypeDef InitStructure =
{
    LPS25HB_ODR_1Hz,
    LPS25HB_BDU_READ, 
    LPS25HB_DIFF_ENABLE,  
    LPS25HB_SPI_SIM_3W,  
    LPS25HB_P_RES_AVG_32,
    LPS25HB_T_RES_AVG_16 
};

const MOBLE_USER_BLE_CB_MAP user_ble_cb =
{  
  Appli_BleStackInitCb,
  Appli_BleSetTxPowerCb,
  Appli_BleGattConnectionCompleteCb,
  Appli_BleGattDisconnectionCompleteCb,
  Appli_BleUnprovisionedIdentifyCb,
  Appli_BleSetUUIDCb,
  Appli_BleSetProductInfoCB,
  Appli_BleSetNumberOfElementsCb,
  Appli_BleDisableFilterCb
};

/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/

/* This structure contains Mesh library Initialisation info data */
const Mesh_Initialization_t BLEMeshlib_Init_params = {
  bdaddr,
  &TrParams,
  &FnParams,
  &LpnParams,
  MESH_FEATURES,
  &DynBufferParam
};

/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
* @brief This function is the Main routine.
* @param  None
* @retval None
*/
int main(void)
{
  /* Device Initialization */
  InitDevice();
    
  PWM_Init();
  
  /* Initialization of PWM value to 0 */
  Appli_PWM_init(); 
  
  LPS25HB_Init(& InitStructure);
  
  Get_CrashHandlerInfo();
   
  /* Check for valid Board Address */
  if (!Appli_CheckBdMacAddr())
  {
#if !defined(DISABLE_TRACES)    
    printf("Bad BD_MAC ADDR!\r\n");
#endif
    /* LED Blinks if BDAddr is not appropriate */
    while (1)
    {
      Appli_LedBlink();
    }
  }
  
  /* Set BLE configuration function callbacks */
  BluenrgMesh_BleHardwareInitCallBack(&user_ble_cb);  
  
  /* Initializes BlueNRG-Mesh Library */
  if (MOBLE_FAILED (BluenrgMesh_Init(&BLEMeshlib_Init_params) ))
  {
#if !defined(DISABLE_TRACES)    
    printf("Could not initialize BlueNRG-Mesh library!\r\n");
#endif    
    /* LED continuously blinks if library fails to initialize */
    while (1)
    {
      Appli_LedBlink();
    }
  }

  /* Checks if the node is already provisioned or not */
  if (BluenrgMesh_IsUnprovisioned() == MOBLE_TRUE)
  {
      BluenrgMesh_UnprovisionedNodeInfo(&UnprovNodeInfoParams);
      BluenrgMesh_InitUnprovisionedNode(); /* Initalizes Unprovisioned node */
  }
  else
  {
      BluenrgMesh_InitProvisionedNode();  /* Initalizes Provisioned node */
#if !defined(DISABLE_TRACES)      
      printf("Node is already provisioned \r\n");
#endif      
  }

  /* Models intialization */  
  BluenrgMesh_ModelsInit();

  /* Set attention timer callback */
  BluenrgMesh_SetAttentionTimerCallback(Appli_BleAttentionTimerCb);

  /* Prints the MAC Address of the board */
#if !defined(DISABLE_TRACES)  
  printf("BlueNRG-Mesh Lighting Demo v%s\n\r", BLUENRG_MESH_APPLICATION_VERSION); 
  printf("BlueNRG-Mesh Library v%s\n\r", BluenrgMesh_GetLibraryVersion()); 
  printf("BD_MAC Address = [%02x]:[%02x]:[%02x]:[%02x]:[%02x]:[%02x] \n\r",
         bdaddr[5],bdaddr[4],bdaddr[3],bdaddr[2],bdaddr[1],bdaddr[0] );
#endif

  /* Check to manually unprovision the board */
  Appli_CheckForUnprovision();
  
/* Set Yellow LED to full intensity */
#if LOW_POWER_FEATURE
  Modify_PWM(PWM2, PWM_TIME_PERIOD);
#endif
  
  /* Main infinite loop */
  while(1)
  {
    BluenrgMesh_Process();
    BluenrgMesh_ModelsProcess(); /* Models Processing */
    Appli_Process();
  }
}

#ifdef USE_FULL_ASSERT /* USE_FULL_ASSERT */
/**
* @brief This function is the assert_failed function.
* @param file
* @param line
* @note  Reports the name of the source file and the source line number
*        where the assert_param error has occurred.
* @retval None
*/
void assert_failed(uint8_t* file, uint32_t line)
{
  while (1)
  {
    SetLed(1);
    Clock_Wait(100);
    SetLed(0);
    Clock_Wait(100);
  }
}
#endif /* USE_FULL_ASSERT */
/**
 * @}
 */

/**
 * @}
 */

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/
