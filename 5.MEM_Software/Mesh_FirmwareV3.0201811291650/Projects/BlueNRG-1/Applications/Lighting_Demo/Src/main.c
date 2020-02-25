/**
******************************************************************************
* @file    main.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
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
#include "bluenrg_mesh.h"
#include "appli_mesh.h"
#include "models_if.h"
#include "mesh_cfg.h"
#include "PWM_config.h"
#include "PWM_handlers.h"
#include "bluenrg1_config.h"

/** @addtogroup BlueNRG_Mesh
 *  @{
 */

/** @addtogroup main_BlueNRG2
*  @{
*/
/* Private typedef -----------------------------------------------------------*/

/* Private define ------------------------------------------------------------*/

const MOBLE_USER_BLE_CB_MAP user_ble_cb =
{
    Appli_BleStackInitCb,
    Appli_BleSetTxPowerCb,
    Appli_BleGattConnectionCompleteCb,
    Appli_BleGattDisconnectionCompleteCb,
    Appli_BleUnprovisionedIdentifyCb,
    Appli_BleSetUUIDCb,
    Appli_BleSetNumberOfElementsCb
};

/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/

/* This structure contains Mesh library Initialisation info data */
const Mesh_Initialization_t BLEMeshlib_Init_params =
{
    bdaddr,
    &FnParams,
    &LpnParams,
    MESH_FEATURES,
    &DynBufferParam
};

#if LOW_POWER_FEATURE
MOBLEINT32 SleepTime;
MOBLEUINT32 RefCount;
#endif
/* Private function prototypes -----------------------------------------------*/
extern uint16_t buffer_adc[ADC_DMA_BUFFER_LEN];
extern ADC_InitType xADC_InitType;
extern uint32_t Count_ms;
float vlotage = 0;
uint8_t Low_Battery_Flag = 0;


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
	
    printf("This is Test for MESH\r\n");
    printf("POWER BY LSD\r\n");


    /* Check for valid Board Address */
    if (!Appli_CheckBdMacAddr())
    {

        printf("Bad BD_MAC ADDR!\r\n");

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

        printf("Could not initialize BlueNRG-Mesh library!\r\n");

        /* LED continuously blinks if library fails to initialize */
        while (1)
        {
            Appli_LedBlink();
        }
    }

    /* Checks if the node is already provisioned or not */
    if (BluenrgMesh_IsUnprovisioned() == MOBLE_TRUE)
    {
        BluenrgMesh_InitUnprovisionedNode(); /* Initalizes Unprovisioned node */
    }
    else
    {
        BluenrgMesh_InitProvisionedNode();  /* Initalizes Provisioned node */
        printf("Node is already provisioned \r\n");
    }


    /* Prints the MAC Address of the board */
    printf("BlueNRG-Mesh Lighting Demo v%s\n\r", BLUENRG_MESH_APPLICATION_VERSION);
    printf("BlueNRG-Mesh Library v%s\n\r", BluenrgMesh_GetLibraryVersion());
    printf("BD_MAC Address = [%02x]:[%02x]:[%02x]:[%02x]:[%02x]:[%02x] \n\r",
           bdaddr[5], bdaddr[4], bdaddr[3], bdaddr[2], bdaddr[1], bdaddr[0] );


    BluenrgMesh_ModelsInit();

    for(uint8_t i = 0; i < 20; i++)
    {
        //ADC_GetConvertedData(xADC_InitType.ADC_Input, xADC_InitType.ADC_ReferenceVoltage);
    }
    /* Main infinite loop */

    Appli_CheckForUnprovision();
		
		MFT_Cmd(MFT2, ENABLE);
		Modify_PWM(1, 1);
		
    SetLed(1);
    SdkEvalLedOn(LED2_G_PIN);
    Clock_Wait(500);
    SetLed(0);
    Clock_Wait(500);

    Clock_Wait(500);
    SdkEvalLedOff(LED2_G_PIN);
    Clock_Wait(500);
#if 0
#if !defined(ENABLE_USART)
    SdkEvalLedOn(LED1_R_PIN);
    Clock_Wait(500);
    SdkEvalLedOff(LED1_R_PIN);
    Clock_Wait(500);
    SdkEvalLedOn(LED1_G_PIN);
    Clock_Wait(500);
    SdkEvalLedOff(LED1_G_PIN);
    Clock_Wait(500);
#endif
#endif
    while(1)
    {
        BluenrgMesh_Process();
        BluenrgMesh_ModelsProcess();
        Appli_Process();
			
        if (Count_ms == 5000)
        {
            Count_ms = 0;
            if( ADC_GetFlagStatus(ADC_FLAG_EOC))
            {
                vlotage = ADC_GetConvertedData(xADC_InitType.ADC_Input, xADC_InitType.ADC_ReferenceVoltage);
                if(vlotage < 0)
                    vlotage = 0;
                printf("ADC value: %.2f V\r\n", vlotage);
                if(vlotage < (float)2.5)
                {
                    printf("ADC POWER OFF\r\n");
                    SdkEvalLedOff(EN_PWR_PIN);

                }
                else if(vlotage < (float)3.0)
                {
                    printf("ADC POWER LOW\r\n");
                    Low_Battery_Flag = 1;
									
									  SdkEvalLedInit(LED1_G_PIN);
										SdkEvalLedOn(LED1_G_PIN);								
#if !defined(ENABLE_USART)
                    //SdkEvalLedOn(LED1_G_PIN);
                    //Clock_Wait(200);
                    //SdkEvalLedOff(LED1_G_PIN);
                    //Clock_Wait(200);
#endif
                }
                else
                {
										SdkEvalLedOff(LED1_G_PIN);
                    //SdkEvalLedOff(LED2_R_PIN);
                }
            }

					}
#if LOW_POWER_FEATURE
        SleepTime = BluenrgMesh_GetSleepInterval();
        if (SleepTime != 0)
        {
            /* save virtual timer current count */
            RefCount = HAL_VTimerGetCurrentTime_sysT32();
            /* wakeup either from io or timer */
            BlueNRG_Sleep(SLEEPMODE_WAKETIMER, WAKEUP_IO13, WAKEUP_IO_LOW, SleepTime);
            /* update systick count based on updated virtual timer count */
            Set_Clock_Time(Clock_Time() +
                           HAL_VTimerDiff_ms_sysT32(HAL_VTimerGetCurrentTime_sysT32(), RefCount));
        }
#endif
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
void assert_failed(uint8_t *file, uint32_t line)
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
