/**
******************************************************************************
* @file    pal_nvm.c
* @author  BLE Mesh Team
* @version V1.08.000
* @date    10-July-2018
* @brief   Flash management for the Controller
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
* Initial BlueNRG-Mesh is built over Motorola�s Mesh over Bluetooth Low Energy 
* (MoBLE) technology. The present solution is developed and maintained for both 
* Mesh library and Applications solely by STMicroelectronics.
*
******************************************************************************
*/

/* Includes ------------------------------------------------------------------*/
#include "types.h"
#include "pal_nvm.h"
#include "bluenrg1_stack.h"
#include "pal_if.h"
#include <string.h>
#include "BlueNRG1_flash.h"

extern const void* mobleNvmBase;

/* Private define ------------------------------------------------------------*/
#define PAGE_SIZE 2048
#define RESET_MANAGER_FLASH_BASE_ADDRESS        (0x10040000)
#define NVM_BASE ((unsigned int)mobleNvmBase)
#define NVM_SIZE 0x00000800
#define NVM_BACKUP_BASE (NVM_BASE + PAGE_SIZE)
#define NVM_BACKUP_SIZE NVM_SIZE
#define MAX_NVM_PENDING_WRITE_REQS 1

/* Private variables ---------------------------------------------------------*/
typedef struct
{
    MOBLEUINT16 offset;
    MOBLEUINT16 size;
    void const *buff;
} BNRGM_NVM_WRITE;

typedef struct
{
    MOBLEUINT8 no_of_pages_to_be_erased;
    MOBLEUINT8 no_of_write_reqs;
    MOBLEBOOL backup_req;
    BNRGM_NVM_WRITE write_req[MAX_NVM_PENDING_WRITE_REQS];
} BNRGM_NVM_REQS;

BNRGM_NVM_REQS BnrgmNvmReqs = {0};

/* Private functions ---------------------------------------------------------*/
/**
* @brief  returns NVM write protect status
* @param  None
* @retval TRUE if flash is write protected
*/
MOBLEBOOL MoblePalNvmIsWriteProtected(void)
{
    /* All flash is writable */
    return MOBLE_FALSE;
}

/**
* @brief  Read NVM
* @param  offset: offset wrt start address of nvm
* @param  buf: copy of read content
* @param  size: size of memory to be read
* @param  backup: If read from backup memory
* @retval Result of read operation
*/
MOBLE_RESULT MoblePalNvmRead(MOBLEUINT32 offset, void *buf, MOBLEUINT32 size, MOBLEBOOL backup)
{
    MOBLE_RESULT result = MOBLE_RESULT_SUCCESS;

    if (offset > NVM_SIZE)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (size == 0)
    {
        result = MOBLE_RESULT_FALSE;
    }
    else if (offset + size > NVM_SIZE)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else
    {
        memcpy(buf, 
               backup == MOBLE_FALSE ? (void *)(NVM_BASE + offset) : (void *)(NVM_BACKUP_BASE + offset), 
               size);
    }

    return result;
}

/**
* @brief  Compare with NVM
* @param  offset: offset wrt start address of nvm
* @param  buf: copy of content
* @param  size: size of memory to be compared
* @param  comparison: outcome of comparison
* @retval Result
*/
MOBLE_RESULT MoblePalNvmCompare(MOBLEUINT32 offset, void const *buf, MOBLEUINT32 size, MOBLE_NVM_COMPARE* comparison)
{
    MOBLE_RESULT result = MOBLE_RESULT_SUCCESS;

    if ((comparison == NULL) || (buf == NULL))
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (offset > NVM_SIZE)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (size == 0)
    {
        result = MOBLE_RESULT_FALSE;
    }
    else if (offset + size > NVM_SIZE)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (offset & 3)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (size & 3)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else
    {
        *comparison = MOBLE_NVM_COMPARE_EQUAL;
        size >>= 2;
      
        MOBLEUINT32* src = (MOBLEUINT32*)buf;
        MOBLEUINT32* dst = (MOBLEUINT32*)(NVM_BASE + offset);

        for (MOBLEUINT32 i=0; i<size; ++i)
        {
            if ((src[i] != dst[i]) && (*comparison == MOBLE_NVM_COMPARE_EQUAL))
            {
                *comparison = MOBLE_NVM_COMPARE_NOT_EQUAL_ERASE;
            }
        }
    }

    return result;
}

/**
* @brief  Erase NVM
* @param  None
* @retval Result
*/
MOBLE_RESULT MoblePalNvmErase(void)
{  
    if (BnrgmNvmReqs.no_of_pages_to_be_erased == 0)
    {
        BnrgmNvmReqs.no_of_pages_to_be_erased = NVM_SIZE/PAGE_SIZE;
    }
    
    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  Queue write requests to NVM
* @param  offset: offset wrt start address of nvm
* @param  buf: copy of write content
* @param  size: size of memory to be written
* @retval Result
*/
MOBLE_RESULT MoblePalNvmWrite(MOBLEUINT32 offset, void const *buf, MOBLEUINT32 size)
{
    MOBLE_RESULT result = MOBLE_RESULT_SUCCESS;


    if (offset > NVM_SIZE)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (size == 0)
    {
        result = MOBLE_RESULT_FALSE;
    }
    else if (offset + size > NVM_SIZE)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (offset & 3)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else if (size & 3)
    {
        result = MOBLE_RESULT_INVALIDARG;
    }
    else
    {
        /* Check for repeated write request */
        for (MOBLEUINT8 count = 0; count < BnrgmNvmReqs.no_of_write_reqs; count++)
        {
            if ((BnrgmNvmReqs.write_req[count].offset == (MOBLEUINT16)offset) \
                && (BnrgmNvmReqs.write_req[count].size == (MOBLEUINT16)size) \
                  && (BnrgmNvmReqs.write_req[count].buff == buf))
            {
                return result;
            }
        }
        
        if (BnrgmNvmReqs.no_of_write_reqs < MAX_NVM_PENDING_WRITE_REQS)
        {
            BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs].offset = (MOBLEUINT16)offset;
            BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs].size = (MOBLEUINT16)size;        
            BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs].buff = buf;
            BnrgmNvmReqs.no_of_write_reqs++;
        }
        /* If pending write requests already full, overwrite oldest one */
        else
        {
            for (MOBLEINT8 count=0; count<MAX_NVM_PENDING_WRITE_REQS-2; count++)
            {
                BnrgmNvmReqs.write_req[count].offset \
                  = BnrgmNvmReqs.write_req[count+1].offset;
                BnrgmNvmReqs.write_req[count].size \
                  = BnrgmNvmReqs.write_req[count+1].size;
                BnrgmNvmReqs.write_req[count].buff \
                  = BnrgmNvmReqs.write_req[count+1].buff;
            }
            
            BnrgmNvmReqs.write_req[MAX_NVM_PENDING_WRITE_REQS - 1].offset = (MOBLEUINT16)offset;
            BnrgmNvmReqs.write_req[MAX_NVM_PENDING_WRITE_REQS - 1].size = (MOBLEUINT16)size;        
            BnrgmNvmReqs.write_req[MAX_NVM_PENDING_WRITE_REQS - 1].buff = buf;
        }
        
    }

    return result;
}

/**
* @brief  Backup process
* @param  None
* @retval Result
*/
static MOBLE_RESULT MoblePalNvmBackupProcess(void)
{
    MOBLEUINT32 buff[4*N_BYTES_WORD];
    static MOBLEUINT8 backup_pages_to_be_erased = 0;    
    
    if (backup_pages_to_be_erased == 0)
    {
        backup_pages_to_be_erased = NVM_BACKUP_SIZE/PAGE_SIZE;
    }
    
      
    while((backup_pages_to_be_erased != 0) \
           && (MoblePalGetIsFlashEraseOk() 
           || (MoblePalIsBtDisconnected() == 1)))
      
    {
        MoblePalBluetoothModeOff();
        FLASH_ErasePage((uint16_t)((NVM_BACKUP_BASE - RESET_MANAGER_FLASH_BASE_ADDRESS) / PAGE_SIZE \
                                   + NVM_BACKUP_SIZE/PAGE_SIZE - backup_pages_to_be_erased));
     
        if (FLASH_GetFlagStatus(Flash_CMDERR) == SET)
        {
            return MOBLE_RESULT_FAIL;
        }           
    
        backup_pages_to_be_erased--;
    }
    
    if (backup_pages_to_be_erased == 0)
    {
        for (size_t i = 0; i < NVM_BACKUP_SIZE && FLASH_GetFlagStatus(Flash_CMDERR) == RESET; )
        {
            memcpy((MOBLEUINT8*)buff, (void *)(NVM_BASE + i), 4*N_BYTES_WORD);
            FLASH_ProgramWordBurst(NVM_BACKUP_BASE + i, (uint32_t*)buff);
            i += 4*N_BYTES_WORD;
        }
      
        if (FLASH_GetFlagStatus(Flash_CMDERR) == SET)
        {
            return MOBLE_RESULT_FAIL;
        }
        
        BnrgmNvmReqs.backup_req = MOBLE_FALSE;
    }
    
    return MOBLE_RESULT_SUCCESS;
}

/**
* @brief  NVM process
* @param  None
* @retval Result
*/
MOBLE_RESULT MoblePalNvmProcess(void)
{
    MOBLEUINT32* src;
    /* Keep erasing until nothing needs to erased */
    while((BnrgmNvmReqs.no_of_pages_to_be_erased != 0) \
           && (MoblePalGetIsFlashEraseOk() \
               || (MoblePalIsBtDisconnected() == 1)))
    {
        MoblePalBluetoothModeOff(); 
        FLASH_ErasePage((uint16_t)((NVM_BASE - RESET_MANAGER_FLASH_BASE_ADDRESS) / PAGE_SIZE \
                                   + NVM_SIZE/PAGE_SIZE - BnrgmNvmReqs.no_of_pages_to_be_erased));
     
        if (FLASH_GetFlagStatus(Flash_CMDERR) == SET)
        {
            return MOBLE_RESULT_FAIL;
        }           
        
        BnrgmNvmReqs.no_of_pages_to_be_erased--;
    }
    
    /* If pending write requests */
    if (BnrgmNvmReqs.no_of_pages_to_be_erased == 0)
    {
        while(BnrgmNvmReqs.no_of_write_reqs != 0)
        {
            src = (MOBLEUINT32*)(BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs - 1].buff);
            
            for (size_t i = 0; i < BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs - 1].size && FLASH_GetFlagStatus(Flash_CMDERR) == RESET; )
            {
                if (BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs - 1].size - i >= 4 * N_BYTES_WORD)
                {
                    FLASH_ProgramWordBurst(NVM_BASE + BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs - 1].offset + i, (uint32_t*)&src[i >> 2]);
                    i+=4 * N_BYTES_WORD;
                }
                else
                {
                    FLASH_ProgramWord(NVM_BASE + BnrgmNvmReqs.write_req[BnrgmNvmReqs.no_of_write_reqs - 1].offset + i, src[i >> 2]);
                    i+=N_BYTES_WORD;
                }
            }

            if (FLASH_GetFlagStatus(Flash_CMDERR) == SET)
            {
                return MOBLE_RESULT_FAIL;
            }

            BnrgmNvmReqs.no_of_write_reqs--;
            BnrgmNvmReqs.backup_req = MOBLE_TRUE;
        }
    }
        
    /* operation on backup memory */
    if ((BnrgmNvmReqs.backup_req == MOBLE_TRUE) && (BnrgmNvmReqs.no_of_pages_to_be_erased == 0))
    {
        MoblePalNvmBackupProcess();
    }
    
    return MOBLE_RESULT_SUCCESS;
}

/******************* (C) COPYRIGHT 2017 STMicroelectronics *****END OF FILE****/


