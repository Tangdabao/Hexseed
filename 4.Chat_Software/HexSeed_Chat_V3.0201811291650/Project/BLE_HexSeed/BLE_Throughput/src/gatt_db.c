
#include <stdio.h>
#include <string.h>
#include "ble_const.h"
#include "bluenrg1_stack.h"
#include "osal.h"
#include "app_state.h"
#include "SDK_EVAL_Config.h"
#include "clock.h"
#include "throughput.h"
#include "gatt_db.h"
#define COPY_UUID_128(uuid_struct, uuid_15, uuid_14, uuid_13, uuid_12, uuid_11, uuid_10, uuid_9, uuid_8, uuid_7, uuid_6, uuid_5, uuid_4, uuid_3, uuid_2, uuid_1, uuid_0) \
  do {\
  	uuid_struct.uuid128[0] = uuid_0; uuid_struct.uuid128[1] = uuid_1; uuid_struct.uuid128[2] = uuid_2; uuid_struct.uuid128[3] = uuid_3; \
	uuid_struct.uuid128[4] = uuid_4; uuid_struct.uuid128[5] = uuid_5; uuid_struct.uuid128[6] = uuid_6; uuid_struct.uuid128[7] = uuid_7; \
	uuid_struct.uuid128[8] = uuid_8; uuid_struct.uuid128[9] = uuid_9; uuid_struct.uuid128[10] = uuid_10; uuid_struct.uuid128[11] = uuid_11; \
	uuid_struct.uuid128[12] = uuid_12; uuid_struct.uuid128[13] = uuid_13; uuid_struct.uuid128[14] = uuid_14; uuid_struct.uuid128[15] = uuid_15; \
	}while(0)

uint16_t ServHandle, TXCharHandle, RXCharHandle;

uint16_t BattServHandle, BattTXCharHandle,LowStatusTXCharHandle,LightRXCharHandle;
// buff temp
CmdFromBt  CmdFromBt_st;
/* UUIDs */
Service_UUID_t service_uuid;
Char_UUID_t char_uuid;

/*******************************************************************************
* Function Name  : Add_Throughput_Service
* Description    : Add the 'Throughput' service.
* Input          : None
* Return         : Status.
*******************************************************************************/
uint8_t Add_Throughput_Service(void)
{
    uint8_t ret;

    /*
    UUIDs:
    D973F2E0-B19E-11E2-9E96-0800200C9A66
    D973F2E1-B19E-11E2-9E96-0800200C9A66
    D973F2E2-B19E-11E2-9E96-0800200C9A66
    */

    const uint8_t uuid[16] = {0x66,0x9a,0x0c,0x20,0x00,0x08,0x96,0x9e,0xe2,0x11,0x9e,0xb1,0xe0,0xf2,0x73,0xd9};
    const uint8_t charUuidTX[16] = {0x66,0x9a,0x0c,0x20,0x00,0x08,0x96,0x9e,0xe2,0x11,0x9e,0xb1,0xe1,0xf2,0x73,0xd9};
    const uint8_t charUuidRX[16] = {0x66,0x9a,0x0c,0x20,0x00,0x08,0x96,0x9e,0xe2,0x11,0x9e,0xb1,0xe2,0xf2,0x73,0xd9};

    Osal_MemCpy(&service_uuid.Service_UUID_128, uuid, 16);
    ret = aci_gatt_add_service(UUID_TYPE_128, &service_uuid, PRIMARY_SERVICE, 6, &ServHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;

    Osal_MemCpy(&char_uuid.Char_UUID_128, charUuidTX, 16);
    ret =  aci_gatt_add_char(ServHandle, UUID_TYPE_128, &char_uuid, 20, CHAR_PROP_NOTIFY, ATTR_PERMISSION_NONE, 0,
                             16, 1, &TXCharHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;

    Osal_MemCpy(&char_uuid.Char_UUID_128, charUuidRX, 16);
    ret =  aci_gatt_add_char(ServHandle, UUID_TYPE_128, &char_uuid, 20, CHAR_PROP_WRITE|CHAR_PROP_WRITE_WITHOUT_RESP, ATTR_PERMISSION_NONE, GATT_NOTIFY_ATTRIBUTE_WRITE,
                             16, 1, &RXCharHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;

    printf("Chat Service added.\nTX Char Handle %04X, RX Char Handle %04X\n", TXCharHandle, RXCharHandle);
    return BLE_STATUS_SUCCESS;

fail:
    printf("Error while adding Chat service.\n");
    return BLE_STATUS_ERROR ;
}


/*******************************************************************************
* Function Name  : Add_Battery_Service
* Description    : Add the 'Battery' service.
* Input          : None
* Return         : Status.
*******************************************************************************/
uint8_t Add_Battery_Service(void)
{
    uint8_t ret;

    /*
    UUIDs:
    D973180F-B19E-11E2-9E96-0800200C9A66
    D9732A19-B19E-11E2-9E96-0800200C9A66
      D973F2E7-B19E-11E2-9E96-0800200C9A66
    */

    const uint8_t uuid[16] = {0x66, 0x9a, 0x0c, 0x20, 0x00, 0x08, 0x96, 0x9e, 0xe2, 0x11, 0x9e, 0xb1, 0x0F, 0x18, 0x73, 0xd9};
    const uint8_t BattcharUuidTX[16] =  {0x66, 0x9a, 0x0c, 0x20, 0x00, 0x08, 0x96, 0x9e, 0xe2, 0x11, 0x9e, 0xb1, 0x19, 0x2a, 0x73, 0xd9};
    const uint8_t LowStatusUuidTX[16] = {0x66, 0x9a, 0x0c, 0x20, 0x00, 0x08, 0x96, 0x9e, 0xe2, 0x11, 0x9e, 0xb1, 0xe8, 0xf2, 0x73, 0xd9};
		const uint8_t LightcharUuidRX[16] = {0x66, 0x9a, 0x0c, 0x20, 0x00, 0x08, 0x96, 0x9e, 0xe2, 0x11, 0x9e, 0xb1, 0xe7, 0xf2, 0x73, 0xd9};

    Osal_MemCpy(&service_uuid.Service_UUID_128, uuid, 16);
    ret = aci_gatt_add_service(UUID_TYPE_128, &service_uuid, PRIMARY_SERVICE,9, &BattServHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;

    Osal_MemCpy(&char_uuid.Char_UUID_128, BattcharUuidTX, 16);
    ret =  aci_gatt_add_char(BattServHandle, UUID_TYPE_128, &char_uuid,  20, CHAR_PROP_NOTIFY, ATTR_PERMISSION_NONE, 0,
                             16, 1, &BattTXCharHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;

		Osal_MemCpy(&char_uuid.Char_UUID_128, LowStatusUuidTX, 16);
    ret =  aci_gatt_add_char(BattServHandle, UUID_TYPE_128, &char_uuid,  20, CHAR_PROP_NOTIFY, ATTR_PERMISSION_NONE, 0,
                             16, 1, &LowStatusTXCharHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;
		

    Osal_MemCpy(&char_uuid.Char_UUID_128, LightcharUuidRX, 16);
    ret =  aci_gatt_add_char(BattServHandle, UUID_TYPE_128, &char_uuid, 20,  CHAR_PROP_WRITE|CHAR_PROP_WRITE_WITHOUT_RESP, ATTR_PERMISSION_NONE, GATT_NOTIFY_ATTRIBUTE_WRITE,
                             16, 1, &LightRXCharHandle);
    if (ret != BLE_STATUS_SUCCESS) goto fail;

    printf("Battery Service added.\nBatt Char Handle %04X, light Char Handle %04X ,low Status Handle %04X\n", 
						BattTXCharHandle,LightRXCharHandle,LowStatusTXCharHandle);
    return BLE_STATUS_SUCCESS;

fail:
    printf("Error while adding Battery service.\n");
    return BLE_STATUS_ERROR ;
}


/*******************************************************************************
* Function Name  : Attribute_Modified_CB
* Description    : Callback when RX/TX attribute handle is modified.
* Input          : Handle of the characteristic modified. Handle of the attribute
*                  modified and data written
* Return         : None.
*******************************************************************************/
void Attribute_Modified_CB(uint16_t handle, uint8_t data_length, uint8_t *att_data)
{
    uint16_t Pwm_Temp;
    if(handle == RXCharHandle + 1)
    {
#if 0
        for(int i = 0; i < data_length; i++)
            printf("%c", att_data[i]);
#else
        //**第一次数据接收**//
        if(CmdFromBt_st.BTCmdLenth == 0)
        {
            Osal_MemSet(CmdFromBt_st.BTCmdBuff, 0, 128);//清除Buff缓存
            Osal_MemCpy(CmdFromBt_st.BTCmdBuff, att_data, data_length);//数据放到缓存中
            CmdFromBt_st.BTCmdLenth = data_length;//记录数据长度
            SdkEvalTimer_Enable(ENABLE);//开启Timer，测量收集数据长度
        }
        else
        {
            CmdFromBt_st.BTCmdCount = 0;//如果有数据，清除计数缓存
            Osal_MemCpy(&CmdFromBt_st.BTCmdBuff[CmdFromBt_st.BTCmdLenth], att_data, data_length);
            CmdFromBt_st.BTCmdLenth += data_length;

            if (CmdFromBt_st.BTCmdLenth > 127)//如果大于127个数据的话，做清除此次数据处理
            {
                Osal_MemSet(CmdFromBt_st.BTCmdBuff, 0, 128);
                CmdFromBt_st.BTCmdLenth = 0;
            }
        }

#endif
    }
    else if(handle == TXCharHandle + 2)
    {
        if(att_data[0] == 0x01)
            APP_FLAG_SET(NOTIFICATIONS_ENABLED);
    }
    else if((handle == BattTXCharHandle + 2)||(handle == LowStatusTXCharHandle + 2))
    {
        if(att_data[0] == 0x01)
            APP_FLAG_SET(NOTIFICATIONS_BAT_ENABLED);//MODIFY 20181113  need New flag,dou't fin
    }
    else if (handle ==LightRXCharHandle + 1)
    {
        //MODIFY fOR LIGHT
        //ADD CODE
#if 0
        printf("this is light data :\r\n");
        for(int i = 0; i < data_length; i++)
            printf("%c", att_data[i]);
#else
        Pwm_Temp =(att_data[1]<<8)|att_data[0];
			
			  if(Pwm_Temp>100)
				{
				  Pwm_Temp =(Pwm_Temp-100) * 40;
				}
				
        Modify_PWM(0,Pwm_Temp);
#endif

    }
    else
    {
        printf("Unexpected handle: 0x%04d.\n", handle);
    }
}


void phoneDatatoBle(uint8_t *data, uint8_t data_length)
{
    for(uint8_t i=0; i<data_length; i++)
    {
        SdkEvalComIOSendData(data[data_length]);
    }
}

