

#ifndef _GATT_DB_H_
#define _GATT_DB_H_

typedef struct
{
    uint8_t BTCmdBuff[128];	//����Buff
    uint8_t BTCmdLenth;//���ݳ���
	  uint8_t BTCmdCount;//��ʱ��ʱ��
		uint8_t BTFinalFlag;//һ���������
} CmdFromBt;

extern CmdFromBt  CmdFromBt_st;
extern uint16_t ServHandle, TXCharHandle, RXCharHandle;
extern uint16_t BattServHandle, BattTXCharHandle,LowStatusTXCharHandle,LightRXCharHandle;	
tBleStatus Add_Throughput_Service(void);
tBleStatus Add_Battery_Service(void);
void Attribute_Modified_CB(uint16_t handle, uint8_t data_length, uint8_t *att_data);
void phoneDatatoBle(uint8_t *data, uint8_t data_length);
extern uint16_t ServHandle, TXCharHandle, RXCharHandle;

#endif /* _GATT_DB_H_ */
