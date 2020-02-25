/**
******************************************************************************
* @file    appli_mesh.c
* @author  BLE Mesh Team
* @version V1.09.000
* @date    15-Oct-2018
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
#include <string.h>
#include "hal_common.h"
#include "bluenrg_config.h"
#include "models_if.h"
#include "mesh_cfg.h"
#include "bluenrg_mesh.h"
#include "appli_mesh.h"
#include "generic.h"
#include "serial_if.h"
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

/**********************Friendship callbacks macros ****************************/
#define FN_CLEARED_REPEAT_REQUEST   1
#define FN_CLEARED_POLL_TIMEOUT     2
#define FN_CLEARED_FRIEND_CLEAR     3
#define LPN_CLEARED_NO_RESPONSE     1

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
MOBLEUINT16 IntensityValue = 0;
MOBLEUINT8 IntensityFlag = 0;
MOBLEUINT8 ProxyFlag = 0;
MOBLEUINT8 DisConnectFlag = 0;
extern uint32_t Connect_Count;
/*Number Of Elements selected per Node. Maximum Elements supported = 3*/
MOBLEUINT8 NumberOfElements = APPLICATION_NUMBER_OF_ELEMENTS;

/*Select Node as Sniffer, Means able to sniff all the packets*/
MOBLEUINT8 DisableFilter = 0;

#if LOW_POWER_FEATURE
MOBLEINT32 BluenrgMesh_sleepTime;
MOBLEUINT32 SysRefCount;
#endif


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

/* Private function prototypes -----------------------------------------------*/
static void Appli_LongButtonPress(void);
static void Appli_ShortButtonPress(void);

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
      {   if (GetButtonState() == BUTTON_PRESSED)    
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
      Appli_IntensityControlPublishing();
      
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
  status = aci_hal_set_tx_power_level(0x01, 0x06); 
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
   uuid_buff[7] = 'S' ;  /* User define value */
   uuid_buff[8] = 0xA1;  /* 0xA1 => A : Conforming to the current Spec */
   uuid_buff[9] = 'T' ;  /* User define value */  

   memcpy(uuid_prefix_data,uuid_buff,sizeof(uuid_buff));
   memcpy(&uuid_prefix_data[10],bdaddr,6);  /* Copy bdaddr to last 6 bytes of UUID */
   
   return MOBLE_RESULT_SUCCESS;
}


/**
* @brief  SET CID , PID and VID values 
* @param  company_product_info : vendor fill product information in this buffer
* @retval MOBLE_RESULT status of result
*/
MOBLE_RESULT Appli_BleSetProductInfoCB(MOBLEUINT8 *company_product_info)
{
  /* CID : provide 16-bit company identifier assigned by the Bluetooth SIG */
  uint16_t company_id                   = COMPANY_ID;
  
  /* PID : Provide 16-bit vendor-assigned product identifier */
  uint16_t product_id                   = PRODUCT_ID;
  
  /* VID : Provide 16-bit vendor-assigned product version identifier*/
  uint16_t product_version_id           = PRODUCT_VERSION_ID;
  
  memcpy(company_product_info + 0,(void *)&company_id,sizeof(company_id));
  memcpy(company_product_info + 2 ,(void *)&product_id,sizeof(product_id));
  memcpy(company_product_info + 4 ,(void *)&product_version_id,sizeof(product_version_id));
  
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
* @brief  Sets the Attention Timer Callback function
* @param  none
* @retval MOBLE_RESULT status of result
*/ 
MOBLE_RESULT Appli_BleAttentionTimerCb(void)
{
  #if !defined(DISABLE_TRACES)
  printf("Attention timer callback received \r\n");
  #endif
  
  return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Enable Node as Sniffer to Capture all the packets
* @param  none
* @retval Sending the value to BLE Mesh Library
*/
MOBLEUINT8 Appli_BleDisableFilterCb(void)
{
    return DisableFilter;
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
  Appli_UpdateButtonState(GetButtonState() == BUTTON_PRESSED );

#if LOW_POWER_FEATURE
    BluenrgMesh_sleepTime = (MOBLEINT32)BluenrgMesh_GetSleepDuration();
    
    if (BluenrgMesh_sleepTime > 0)
    {
      /* Timer 0 used for low power */
      HAL_VTimerStart_ms(0, BluenrgMesh_sleepTime);
      
      /* To start virtual timer */
      BTLE_StackTick();

      /* save virtual timer current count */
      SysRefCount = HAL_VTimerGetCurrentTime_sysT32();
      
      /* wakeup either from io or virtual timer */
      BlueNRG_Sleep(SLEEPMODE_WAKETIMER, WAKEUP_IO13, WAKEUP_IOx_LOW);
      
      /* update systick count based on updated virtual timer count */
      Set_Clock_Time(Clock_Time() + 
                     HAL_VTimerDiff_ms_sysT32(HAL_VTimerGetCurrentTime_sysT32(), SysRefCount));
      
      /* Stop Timer 0 */
      HAL_VTimer_Stop(0);
    }
#endif /* LOW_POWER_FEATURE */

#ifdef ENABLE_SERIAL_CONTROL
      Serial_InterfaceProcess();
#endif
      
  /* Get Acceleration data */
#ifdef LSM6DS3_ENABLE
      static uint32_t delayCounter = 0;
      IMU_6AXES_StatusTypeDef readStatus;
      delayCounter++;
      if (delayCounter > 50000)
      {  
          
          readStatus = GetAccAxesRaw(&x_axes, &g_axes);
          if (readStatus == IMU_6AXES_OK) 
          {
         /* Acc_Update(&x_axes, &g_axes); */
#if !defined(DISABLE_TRACES)            
            printf("Acc X axis %d // Acc Y axis %d // Acc Z axis %d\n\r",x_axes.AXIS_X, x_axes.AXIS_Y, x_axes.AXIS_Z);
            printf("Acc X axis %d // Acc Y axis %d // Acc Z axis %d\n\r",g_axes.AXIS_X, g_axes.AXIS_Y, g_axes.AXIS_Z);
#endif            
          }  
          else
          {
            printf("Read Error : %d",readStatus);
          }
          delayCounter = 0;
      }
#endif
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
  memcpy(bdaddr, (const MOBLEUINT8 *)_bdaddr , 7);
  bdaddr[7] = (EXTERNAL_MAC_ADDR_MGMT | EXTERNAL_MAC_TYPE);
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

#if defined(EXTERNAL_MAC_ADDR_MGMT) && defined(EXTERNAL_MAC_IS_PUBLIC_ADDR)
   /* Do nothing for modification of 2 MSb */
#else
  bdaddr[5] |= 0xC0;    /* 2 Msb bits shall be 11b for Static Random Address */
#endif
  
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
  { /* Read only 6 Bytes for MAC Address */
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


/**
* @brief  provides the information of the power saving mode
* @param  sleepMode curently unused, to be used in future 
* @retval SleepModes returns the mode of the controller
*/
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
void BluenrgMesh_UnprovisionCallback(MOBLEUINT8 reason)
{
#if !defined(DISABLE_TRACES)  
  printf("Device is unprovisioned by provisioner \n\r");
#endif  
}

/**
* @brief  callback for provision the node by provisioner.
* @param  void
* @retval void
*/
void BluenrgMesh_ProvisionCallback(void)
{
#if !defined(DISABLE_TRACES) 
  printf("Device is provisioned by provisioner \r\n");
#endif  
}

/**
* @brief  callback for friendship established by friend node
* @param  address of corresponding low power node
* @param  receive delay of low power node (unit ms)
* @param  poll timeout of low power node (unit 100ms)
* @param  number of elements of low power node
* @param  previous friend address of low power node (can be invalid address)
* @retval void
*/
void BluenrgMesh_FnFriendshipEstablishedCallback(MOBLE_ADDRESS lpnAddress,
                                                 MOBLEUINT8 lpnReceiveDelay,
                                                 MOBLEUINT32 lpnPollTimeout,
                                                 MOBLEUINT8 lpnNumElements,
                                                 MOBLE_ADDRESS lpnPrevFriendAddress)
{
#if !defined(DISABLE_TRACES) 
  printf("Friendship established. Low power node address 0x%.4X \r\n", lpnAddress);
  printf("Low power node receive delay %dms \r\n", lpnReceiveDelay);
  printf("Low power node poll timeout %dms \r\n", lpnPollTimeout*100);
  printf("Low power node number of elements %d \r\n", lpnNumElements);
  if (lpnPrevFriendAddress != MOBLE_ADDRESS_UNASSIGNED)
  {
    printf("Low power node previous friend address 0x%.4X \r\n", lpnPrevFriendAddress);
  }
#endif  
}

/**
* @brief  callback for friendship clear by friend node
* @param  reason of friendship clear
*         0: reserved,
*         1: friend request received from existing low power node (friend)
*         2: low power node poll timeout occurred
*         3: friend clear received
* @param  previous friend address of low power node (can be invalid address)
* @retval void
*/
void BluenrgMesh_FnFriendshipClearedCallback(MOBLEUINT8 reason, MOBLE_ADDRESS lpnAddress)
{
#if !defined(DISABLE_TRACES) 
  printf("Friendship cleared. Low power node address 0x%.4X \r\n", lpnAddress);
  
  switch(reason)
  {
  case FN_CLEARED_REPEAT_REQUEST: 
    printf("Reason: New friend request received from existing low power node \r\n");
    break;
  case FN_CLEARED_POLL_TIMEOUT:
    printf("Reason: Low power node poll timeout occurred \r\n");
    break;
  case FN_CLEARED_FRIEND_CLEAR:
    printf("Reason: Friend clear received \r\n");
    break;
  default:
    printf("Reason: Invalid \r\n");
    break;
  }
#endif
}

/**
* @brief  callback for friendship established by low power node
* @param  address of corresponding friend node
* @retval void
*/
void BluenrgMesh_LpnFriendshipEstablishedCallback(MOBLE_ADDRESS fnAddress)
{
  /* Friendship established */
}

/**
* @brief  callback for friendship cleare by low power node
* @param  reason of friendship clear.
*         0: reserved
*         1: No response received from friend node
* @retval void
*/
void BluenrgMesh_LpnFriendshipClearedCallback(MOBLEUINT8 reason, MOBLE_ADDRESS fnAddress)
{
#if !defined(DISABLE_TRACES) 
  printf("Friendship cleared. Friend node address 0x%.4x \r\n", fnAddress);
  
  if (reason == LPN_CLEARED_NO_RESPONSE)
  {
    printf("Reason: Friend node not responding \r\n");
  }
  else
  {
    printf("Reason: Invalid \r\n");
  }
#endif  
}

/**
* @brief  Appli_IntensityControl:Function to increase the intensity of led by
*          Publishing the value.
* @param  void
*/
void Appli_IntensityControlPublishing(void)
{
   MOBLEUINT8 generic_Level_Buff[3];
   MOBLE_ADDRESS publishAddress;
   MOBLEUINT8 elementNumber;
   MOBLEUINT8 elementIndex;
        
  /*Select the Element Number for which publication address is required*/
  
  if (NumberOfElements == 1)
  {
    elementNumber = 0x01; 
  }
  
  else if(NumberOfElements == 2)
  { 
    elementNumber = 0x02; /*Element 2 is configured as switch*/
  }
  
  else if(NumberOfElements == 3)
  {
    elementNumber = 0x03; /*Element 3 is configured as switch*/
  }
  
  else
  {
    elementNumber = 0x01;
  }
  
  publishAddress = BluenrgMesh_GetPublishAddress(elementNumber);
  elementIndex = elementNumber-1;
  
  if(IntensityFlag == 0)
  {
      
    IntensityValue = IntensityValue + (PWM_LEVEL_FULL/5);
    generic_Level_Buff[0] = (MOBLEUINT8)IntensityValue;
    generic_Level_Buff[1] = (MOBLEUINT8)(IntensityValue >> 8) ;
    
    BluenrgMesh_SetRemoteData(publishAddress, elementIndex, GENERIC_LEVEL_SET_UNACK , 
                              generic_Level_Buff,3, MOBLE_FALSE, MOBLE_FALSE);
    
    if(IntensityValue >= PWM_LEVEL_FULL)
     {
        IntensityFlag = 1;
     }
     
  }
  else
  {
     
    IntensityValue = IntensityValue - (PWM_LEVEL_FULL/5);
    generic_Level_Buff[0] = (MOBLEUINT8)IntensityValue;
    generic_Level_Buff[1] = (MOBLEUINT8)(IntensityValue >> 8) ;
    
    BluenrgMesh_SetRemoteData(publishAddress, elementIndex, GENERIC_LEVEL_SET_UNACK, 
                              generic_Level_Buff, 3, MOBLE_FALSE, MOBLE_FALSE); 
    
    if(IntensityValue <= PWM_LEVEL_OFF)
     {
        IntensityFlag = 0;
     }
  
  }
}

/**
* @}
*/

/**
* @}
*/
/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/
