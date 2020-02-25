/**
******************************************************************************
* @file    appli_mesh.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    31-July-2018
* @brief   User Application file
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
#include "bluenrg_mesh.h"
#include <bluenrg1_config.h>
#include <string.h>
#include "models_if.h"
#include "mesh_cfg.h"
typedef  void (*pFunction)(void);
extern volatile uint32_t ota_sw_activation;
/** @addtogroup BlueNRG_Mesh
*  @{
*/

/** @addtogroup Application_Callbacks_BlueNRG2
*  @{
*/

/* Private define ------------------------------------------------------------*/

/*********** Macros to be modified according to the requirement *************/
#define BOUNCE_THRESHOLD                20U
#define LONG_PRESS_THRESHOLD            1000U
#define MANUAL_UNPROVISION_TIMER        5000U
#define FLASH_ERASE_TIME                100U

#define DEFAULT_DELAY_PACKET_FROM         500U
#define DEFAULT_DELAY_PACKET_RANDOM_TIME  500U

/* Private macro -------------------------------------------------------------*/
#define MAX_APPLI_BUFF_SIZE             8
#define MAX_PENDING_PACKETS_QUE_SIZE    2
#define DATA_BUFFER_LENGTH              8
#define MAX_NUMB_ELEMENTS               3

/* Private variables ---------------------------------------------------------*/

enum ButtonState
{
    BS_OFF,
    BS_DEBOUNCE,
    BS_SHORT_PRESS,
    BS_LONG_PRESS
};

enum ButtonState buttonState = BS_OFF;
tClockTime tBounce = 0;
MOBLEUINT8 Appli_LedState = 0;
MOBLEUINT8 ProxyFlag = 0;
MOBLEUINT8 DisConnectFlag = 0;
extern uint32_t Connect_Count;
/*Number Of Elements selected per Node. Maximum Elements supported = 3*/
MOBLEUINT8 NumberOfElements = 1;

/********************* Application configuration **************************/
#if defined(__GNUC__) || defined(__IAR_SYSTEMS_ICC__) || defined(__CC_ARM)
MOBLEUINT8 bdaddr[8];
extern const MOBLEUINT8 _bdaddr[];

#ifdef INTERNAL_UNIQUE_NUMBER_MAC
static void Appli_GetMACfromUniqueNumber(void);
#endif

extern const char _mobleNvmBase_data[];
const void *mobleNvmBase = _mobleNvmBase_data;
#else
#error "Unknown compiler"
#endif /* __GNUC__ || defined(__IAR_SYSTEMS_ICC__) || defined(__CC_ARM) */

/* RAM reserved to manage all the data stack according the number of links,
* number of services, number of attributes and attribute value length
*/
uint32_t dyn_alloc_a[TOTAL_BUFFER_SIZE(NUM_LINKS,NUM_GATT_ATTRIBUTES,\
                                       NUM_GATT_SERVICES,ATT_VALUE_ARRAY_SIZE)>>2] = {0};

/* FLASH reserved to store all the security database information and
* and the server database information
*/
ALIGN(4)
SECTION(".nvm.stacklib_flash_data")
NOLOAD(const uint32_t stacklib_flash_data[TOTAL_FLASH_BUFFER_SIZE(FLASH_SEC_DB_SIZE,
        FLASH_SERVER_DB_SIZE)>>2]);
/* FLASH reserved to store: security root keys, static random address, public address */
ALIGN(4)
SECTION(".nvm.stacklib_stored_device_id_data")
NOLOAD(const uint8_t stacklib_stored_device_id_data[56]);

/* Private function prototypes -----------------------------------------------*/
static void Appli_LongButtonPress(void);
static void Appli_ShortButtonPress(void);


/* This structure contains memory and low level hardware configuration data */
const BlueNRG_Stack_Initialization_t BlueNRG_Stack_Init_params =
{
    (uint8_t*)stacklib_flash_data,
    FLASH_SEC_DB_SIZE,
    FLASH_SERVER_DB_SIZE,
    (uint8_t*)stacklib_stored_device_id_data,
    (uint8_t*)dyn_alloc_a,
    NUM_GATT_ATTRIBUTES,
    NUM_GATT_SERVICES,
    ATT_VALUE_ARRAY_SIZE,
    NUM_LINKS,
    CONFIG_TABLE
};


/* Private functions ---------------------------------------------------------*/

/************************* Button Control functions ********************/
/**
* @brief  Function calls when a button is pressed for short duration
* @param  void
* @retval void
*/
static void Appli_ShortButtonPress(void)
{
    BluenrgMesh_ModelsCommand();
}

/**
* @brief  Function calls when a button is pressed for Long duration
* @param  void
* @retval void
*/
static void Appli_LongButtonPress(void)
{
    /*Edited for OTA, Macro is available in preprocessor*/
#ifdef ST_USE_OTA_SERVICE_MANAGER_APPLICATION
    if(GetButton2State() == BUTTON_PRESSED)
        OTA_Jump_To_Service_Manager_Application();
#endif
}
void SdkEvalLedFlicker(void)
{
    SdkEvalLedOff(LED2_G_PIN);
    for(uint8_t i=0; i<5; i++)
    {
        SdkEvalLedOn(LED2_R_PIN);
        //GPIO_WriteBit(Get_LedGpioPin(xLed),LED_ON );
        Clock_Wait(100);
        SdkEvalLedOff(LED2_R_PIN);
        //GPIO_WriteBit(Get_LedGpioPin(xLed),LED_OFF );
        Clock_Wait(100);
    }
}
/**
* @brief  Updates the button status
* @param  int isPressed
* @retval void
*/
static void Appli_UpdateButtonState(int isPressed)
{
    /* Check for button state */
    switch (buttonState)
    {
    /* Case for Button State off */
    case BS_OFF:
        /* if button is pressed */
        if (isPressed)
        {
            buttonState = BS_DEBOUNCE;
            tBounce = Clock_Time();
        }
        break;

    /* Case for Button Debouncing */
    case BS_DEBOUNCE:
        if (isPressed)
        {
            /* Debouncing Delay check */
            if (Clock_Time() - tBounce > BOUNCE_THRESHOLD)
            {
                if (GetButtonState() == BUTTON_PRESSED)
                    buttonState = BS_SHORT_PRESS;
            }
            else
            {
                break;
            }
        }
        else
        {
            buttonState = BS_OFF;
            break;
        }
    /* Case if Button is pressed for small duration */
    case BS_SHORT_PRESS:
        if (isPressed && ((Clock_Time() - tBounce) > LONG_PRESS_THRESHOLD))
        {
            buttonState = BS_LONG_PRESS;
        }
        else
        {
            if (!isPressed)
            {
                Appli_ShortButtonPress();
            }
            break;
        }
    /* Case if Button is pressed for long duration */
    case BS_LONG_PRESS:
        /* Second Button handling in BlueNRG-1*/
        /*
        		if (GetButton2State() == BUTTON_PRESSED)
        {
            //SdkEvalLedOn(LED1);
            Appli_LongButtonPress();
        }*/
        printf("BS_LONG_PRESS\r\n");
        SdkEvalLedFlicker();
        SdkEvalLedOff(EN_PWR_PIN);//°´¼üÊ±¼ä´óÓÚ1S£¬¹Ø±ÕÉè±¸
        break;
    /* Default case */
    default:
        buttonState = BS_OFF;
        break;
    }
    if (!isPressed)
    {
        buttonState = BS_OFF;
    }
}
/************************* LED Control functions ********************/
/**
* @brief  Controls the state of on board LED
* @param  void
* @retval void
*/
void Appli_LedCtrl(void)
{
    SetLed(Appli_LedState);
}


/************* BlueNRG-Mesh library callback functions ***************/

/**
* @brief  Blinks the on board LED
* @param  none
* @retval MOBLE_RESULT status of result
*/
MOBLE_RESULT Appli_LedBlink(void)
{
    /* Switch On the LED */
    Appli_LedState = 1;
    Appli_LedCtrl();
    Clock_Wait(20);

    /* Switch Off the LED */
    Appli_LedState = 0;
    Appli_LedCtrl();
    Clock_Wait(20);

    return MOBLE_RESULT_SUCCESS;
}



MOBLE_RESULT Appli_UnprovisionLedBlink(void)
{
    /* Switch On the LED */
    SdkEvalLedOff(LED2_G_PIN);
    SdkEvalLedOn(LED2_R_PIN);
    Clock_Wait(200);

    /* Switch Off the LED */
    SdkEvalLedOff(LED2_R_PIN);
    Clock_Wait(200);

    return MOBLE_RESULT_SUCCESS;
}


MOBLE_RESULT Appli_IAPLedBlink(void)
{
    /* Switch On the LED */
    SdkEvalLedOff(LED2_R_PIN);
    SdkEvalLedOn(LED2_G_PIN);
    Clock_Wait(200);

    /* Switch Off the LED */
    SdkEvalLedOff(LED2_G_PIN);
    Clock_Wait(200);

    return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  Callback function Sets the state of the bulb
* @param  MOBLEUINT16 ctrl which sets the lighting state of LED
* @retval MOBLE_RESULT status of result
*/
MOBLE_RESULT Appli_LedStateCtrlCb(MOBLEUINT16 ctrl)
{
    /* Switch On the LED */
    if(ctrl > 0)
    {
        Appli_LedState = 1;
    }
    /* Switch Off the LED */
    else
    {
        Appli_LedState = 0;
    }

    Appli_LedCtrl();

    return MOBLE_RESULT_SUCCESS;
}
/**
* @brief  initializes BlueNRG Stack
* @param  none
* @retval MOBLE_RESULT status of result
*/
MOBLE_RESULT Appli_BleStackInitCb()
{
    tBleStatus status;

    /* BTLE Stack initialization */
    status =  BlueNRG_Stack_Initialization(&BlueNRG_Stack_Init_params);

    /* Check if command executed successfully */
    if (status)
        return MOBLE_RESULT_FAIL;
    else
        return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Sets transmission power of RF
* @param  none
* @retval MOBLE_RESULT status of result
*/
MOBLE_RESULT Appli_BleSetTxPowerCb(void)
{
    tBleStatus status;
    /* API to change the Transmission power of BlueNRG Device */
    status = aci_hal_set_tx_power_level(POWER_LEVEL_HIGH, TX_POWER_LEVEL_PLUS_2DBM);
    /* Check if command executed successfully */
    if (status)
        return MOBLE_RESULT_FAIL;
    else
        return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  SET UUID value
* @param  uuid_prefix_data : Pointer of UUID buffer data
* @retval MOBLE_RESULT status of result
*/
MOBLE_RESULT Appli_BleSetUUIDCb(MOBLEUINT8 *uuid_prefix_data)
{
    /* UUID is 128 bits (16 bytes) and can guarantee uniqueness across space and time.
       It can be “Time-based “ UUID or “truly-random or pseudo-random numbers”

       In this buffer user need to fill 10 bytes of UUID data.
       Remaining 6 bytes, library fill this data with BDaddress.

      For example :
          F81D4FAE-7DEC-XBC4-Y12F-17D1AD07A961 (16 bytes)
          <any number> |_|  |_|   <BDAddress>

        X = 1 i.e. “Time Base UUID”
        X = 4 i.e. “Random Number“
        Y = 4 i.e. Conforming to the current spec
      For UUID information refer RFC4122
    */

    /* copy UUID prefix data*/
    uint8_t uuid_buff[10] = {0xF8,0x1D,0x4F,0xAE,0x7D,0xEC};/*random value by user */

    uuid_buff[6] = 0x4B;  /* 0x4B => 4 : Random */
    uuid_buff[7] = 'A' ;  /* User define value */
    uuid_buff[8] = 0xA1;  /* 0xA1 => A : Conforming to the current Spec */
    uuid_buff[9] = 'B' ;  /* User define value */

    memcpy(uuid_prefix_data,uuid_buff,sizeof(uuid_buff));

    return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  Call back function called when GATT Connection Created
* @param  none
* @retval none
*/
void Appli_BleGattConnectionCompleteCb(void)
{
    /* Proxy Node, will be called whenever Gatt connection is established */
    /* Turn ON Red LED*/
#if LOW_POWER_FEATURE
    /* do nothing */
#else
    SdkEvalLedOn(LED2_G_PIN);
    printf("This is ConnectionCompleteCb\r\n");
#endif
    ProxyFlag = 1;
    DisConnectFlag = 0;
}

/**
* @brief  Call back function called when GATT Disconnection Complete
* @param  none
* @retval none
*/
void Appli_BleGattDisconnectionCompleteCb(void)
{
    /* Proxy Node, will be called whenever Gatt disconnected */
    /* Turn Off Red LED*/
#if LOW_POWER_FEATURE
    /* do nothing */
#else
    SdkEvalLedOff(LED2_G_PIN);
#endif
    printf("This is DisConnectionCompleteCb\r\n");
    ProxyFlag = 0;
    Connect_Count = 0;
    DisConnectFlag = 0;
}

/**
* @brief Unprovisioned Node Identification
* @param MOBLEUINT8 data
* @retval none
*/
void Appli_BleUnprovisionedIdentifyCb(MOBLEUINT8 data)
{
#if !defined(DISABLE_TRACES)
    printf("Unprovisioned Node Identifier received: %02x\n\r", data);
#endif
}

/**
* @brief  Set Number of Elements in a Node
* @param  none
* @retval Sending the value to BLE Mesh Library
*/
MOBLEUINT8 Appli_BleSetNumberOfElementsCb(void)
{
    if(NumberOfElements > MAX_NUMB_ELEMENTS)
    {
#if !defined(DISABLE_TRACES)
        printf("Currently Three Elements per node are supported!\r\n");
#endif
        return MAX_NUMB_ELEMENTS;
    }
    else
    {
        return NumberOfElements;
    }
}


/**
* @brief  Checks and do Manual Unprovision of board
* @param  void
* @retval void
*/
void Appli_CheckForUnprovision(void)
{
    pFunction Jump_To_Application;
    uint32_t JumpAddress, appAddress;
    /* Checks if the User button is pressed or not at the startup */
    if (BUTTON_PRESSED == GetButtonState())
    {

        tClockTime t = Clock_Time();
        int interrupted = 0;

        /*Wait to check if user is pressing the button persistently*/
        while ((Clock_Time() - t) < MANUAL_UNPROVISION_TIMER)
        {
            if (Clock_Time() - t > 1000)
            {
                SdkEvalLedOn(LED2_G_PIN);
								
            }							
            if (BUTTON_PRESSED != GetButtonState())
            {
                interrupted = 1;
#if 1
                ota_sw_activation = 0x00000000;
                appAddress =0x1004000;
                /* Jump to user application */
                JumpAddress = *(__IO uint32_t *) (appAddress + 4);
                Jump_To_Application = (pFunction) JumpAddress;
                /* Initialize user application's Stack Pointer */
                __set_MSP(*(__IO uint32_t *) appAddress);
                Jump_To_Application();
#endif
                break;
            }
        }
        /*Unprovision, show that unprovisioning is completed, and
        wait until user releases button*/
        if (!interrupted)
        {
            BluenrgMesh_Unprovision();
            printf("Device is unprovisioned by application \r\n");

            t = Clock_Time();
            while ((Clock_Time() - t) < FLASH_ERASE_TIME)
            {
                BluenrgMesh_Process();
            }

            while (BUTTON_PRESSED == GetButtonState())
            {
                Appli_UnprovisionLedBlink();
            }
        }
    }
}

/**
* @brief  Application processing
*         This function should be called in main loop
* @param  void
* @retval void
*/
void Appli_Process(void)
{
    Appli_UpdateButtonState(GetButtonState() == BUTTON_PRESSED);
}


/**
* @brief  Checks and updates Mac address to generate MAC Address
* @param  void
* @retval MOBLEUINT8 sum return the sum calculated mac
*/
int Appli_CheckBdMacAddr(void)
{
    MOBLEUINT8 sum = 239;
    MOBLEUINT8 result = 0;

#ifdef EXTERNAL_MAC_ADDR_MGMT
    memcpy(bdaddr, (const MOBLEUINT8 *)_bdaddr, 7);
    bdaddr[7] = EXTERNAL_MAC_ADDR_MGMT;
#endif

#ifdef INTERNAL_UNIQUE_NUMBER_MAC
    Appli_GetMACfromUniqueNumber();
    bdaddr[7] = INTERNAL_UNIQUE_NUMBER_MAC;
#endif

    for (int i = 0; i < 6; ++i)
    {
        sum = (sum << 1) + bdaddr[i];
    }

    if (sum == bdaddr[6])
    {
        result = 1;
    }

    bdaddr[5] |= 0xC0;    /* 2 Msb bits shall be 11b for Static Random Address */

#ifdef GENERATE_STATIC_RANDOM_MAC
    bdaddr[7] = GENERATE_STATIC_RANDOM_MAC;
    /* Do nothing for bdaddr, just pass the identification */
    result = 1;         /* This will overwrite the above for loop result,
                          which is redundant for this case */
#endif

    return result;
}


/**
* @brief  Reads the unique serial number of the device
* @param  void
* @retval void
*/
#ifdef INTERNAL_UNIQUE_NUMBER_MAC
static void Appli_GetMACfromUniqueNumber(void)
{
#define BNRG1_UNIQUE_NUMBER_ADDR (0x100007F4)

    /*
    The unique serial number is a six bytes value stored at address 0x100007F4:
    it is stored as two words (8 bytes) at address 0x100007F4 and 0x100007F8
    with unique serial number padded with 0xAA55.
    */
    uint8_t *pdst;
    uint8_t *psrc;
    uint8_t i;
    MOBLEUINT8 sum = 239;

    pdst = (uint8_t*) (bdaddr);
    psrc = (uint8_t*)(BNRG1_UNIQUE_NUMBER_ADDR);

    for (i=0; i<6; i++)
    {
        /* Read only 6 Bytes for MAC Address */
        *pdst = *psrc;
        pdst++;
        psrc++;
    }


    bdaddr[5] &= 0xDF;    /* To ensure all bit are not 1 0r 0*/
    bdaddr[5] |= 0xC0;    /*  Static Device Address: The two most significant
                            bits of the address shall be equal to 1*/

    for (int i = 0; i < 6; ++i)
    {
        sum = (sum << 1) + bdaddr[i];
    }
    bdaddr[6] = sum;
}
#endif

SleepModes App_SleepMode_Check(SleepModes sleepMode)
{
    if (buttonState == BS_OFF)
    {
        return SLEEPMODE_WAKETIMER;
    }
    else
    {
        return SLEEPMODE_RUNNING;
    }
}

/**
* @brief  callback for unprovision the node by provisioner.
* @param  status reserved for future
* @retval void
*/
void BluenrgMesh_UnprovisionCallback(MOBLEUINT8 status)
{
    printf("Device is unprovisioned by provisioner \n\r");
}

/**
* @brief  callback for provision the node by provisioner.
* @param  void
* @retval void
*/
void BluenrgMesh_ProvisionCallback(void)
{
    printf("Device is provisioned by provisioner \r\n");
}

/**
* @}
*/

/**
* @}
*/
/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/
