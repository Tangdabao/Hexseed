
#ifndef _THROUGHPUT_H_
#define _THROUGHPUT_H_

#define NUM_PACKETS 500 
typedef struct
{
  uint8_t Com_Flag;    //一帧数据接收完毕Flag
	uint8_t Adc_Updata_Flag;
	uint8_t Low_Battery_Flag;
	uint8_t Connect_Status;
}Sys_flag;

extern Sys_flag   System_flag;
uint8_t THROUGHPUT_DeviceInit(void);
void BleDatatophone(uint8_t *data,uint8_t data_length);
void APP_Tick(void);
void TempDatatophone(uint8_t *data, uint8_t data_length);
void BattDatatophone(uint8_t *data, uint8_t data_length);
#endif // _THROUGHPUT_H_
