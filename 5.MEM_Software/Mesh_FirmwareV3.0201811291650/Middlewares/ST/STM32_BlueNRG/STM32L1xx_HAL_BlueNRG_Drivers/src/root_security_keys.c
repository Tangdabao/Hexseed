/******************** (C) COPYRIGHT 2012 STMicroelectronics ********************
* File Name          : root_security_keys.c (STM32L Cube version)
* Author             : AMS - VMA RF application
* Version            : V1.0.0
* Date               : 14-September-2015
* Description        : Implementation of root security keys x BlueNRG-MS stack up to FW 7.1.a
* Note               : This file provides an utility API allowing to generate, store and set the IR and ER root keys, 
*                      ONLY on a BlueNRG-MS device, FW stack 7.1 and 7.1.a.
*                      Starting from BlueNRG-MS FW stack 7.1.b, the IR and ER root keys are randomly generated and 
*                      permanently stored in internal Flash at first initialization of the device (ACI_GATT_INIT).
*                      Refer to BlueNRG-MS solved issue ID 1177. 
********************************************************************************
* THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
* WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE TIME.
* AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY DIRECT,
* INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING FROM THE
* CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE CODING
* INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
*******************************************************************************/

/******************************************************************************
 * Includes
 *****************************************************************************/

#if BLUENRG_MS

#include "stm32l1xx.h"
#include "string.h"
#include "hal_types.h"
#include "stm32l1xx_hal_flash.h"
#include "hci.h"
#include "bluenrg_aci.h"
#include "hci_const.h"
#include "SDK_EVAL_SPI_Driver.h"

typedef struct security_key_s {
  uint32_t DIV;
  uint32_t ER[4];
  uint32_t IR[4];
}security_key_t;

const security_key_t security_keys = {0}; 

static void enableFlash(void)
{
    /* Unlock the Program memory */
  HAL_FLASH_Unlock();
  
  /* Clear all FLASH flags */
  __HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_WRPERR | FLASH_FLAG_PGAERR
                         | FLASH_FLAG_SIZERR | FLASH_FLAG_OPTVERR | FLASH_FLAG_OPTVERRUSR);
}

static void disableFlash(void)
{
  HAL_FLASH_Lock();
}


/* Function used to generate the security roots keys: DIV, ER and IR and set on BlueNRG-MS.
   THis function works only on BlueNRG-MS context, since hci_le_rand() is available only on BlueNRG-MS FW stack.
*/
uint8_t generate_security_root_keys(void)
{
  uint8_t rand_buf[16];
  uint32_t value; 
  
  const uint8_t reference_array[16] = {0};
  uint8_t ret;
  
  if (memcmp((void *) security_keys.ER, reference_array, 16) == 0)
  {
    /* set security keys: DIV */  
    hci_le_rand(rand_buf); 
    
    memcpy(&value, rand_buf, 4);
    
    enableFlash();
    
    ret = HAL_FLASHEx_DATAEEPROM_Program(FLASH_TYPEPROGRAMDATA_FASTWORD, (uint32_t) &security_keys.DIV, value);    
    
    if (ret != HAL_OK)
    {
      disableFlash();
      return ret;
    }
    
    /* set security keys: ER*/  
    hci_le_rand(rand_buf); 
    hci_le_rand(rand_buf +8);
    
    for (uint8_t i = 0; i<16; i+=4)
    {
      memcpy(&value, rand_buf +i, 4);
      ret = HAL_FLASHEx_DATAEEPROM_Program(FLASH_TYPEPROGRAMDATA_FASTWORD, (uint32_t)security_keys.ER + i, value);    
      if (ret != HAL_OK)
      {
        disableFlash();
        return ret;
      }
    }
    
    /* set security keys: IR*/  
    hci_le_rand(rand_buf); 
    hci_le_rand(rand_buf +8);
    
    for (uint8_t i = 0; i<16; i+=4)
    {
      memcpy(&value, rand_buf +i, 4);
      ret = HAL_FLASHEx_DATAEEPROM_Program(FLASH_TYPEPROGRAMDATA_FASTWORD, (uint32_t)security_keys.IR + i, value);  
      if (ret != HAL_OK)
      {
        disableFlash();
        return ret;
      }
    }
    disableFlash();
    
    BlueNRG_RST();
  }
  
  /* configure root keyes on BlueNRG-MS: DIV, ER, IR */
  ret = aci_hal_write_config_data(CONFIG_DATA_DIV_OFFSET, CONFIG_DATA_DIV_LEN,
                                  (uint8_t *) &security_keys.DIV);
  if (ret)
  {
    return ret;
  }
  
  ret = aci_hal_write_config_data(CONFIG_DATA_ER_OFFSET, CONFIG_DATA_ER_LEN,
                                  (uint8_t *) security_keys.ER);
  if (ret)
  {
    return ret;
  }
  ret = aci_hal_write_config_data(CONFIG_DATA_IR_OFFSET, CONFIG_DATA_IR_LEN,
                                  (uint8_t *) security_keys.IR);
  return ret;
}

#endif 
