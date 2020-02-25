/******************************************************************************
*
*  File Description 
*  ---------------------
*  Header file for root security keys generation example (DIV, ER, IR)
*  Note               : This file provides an utility API allowing to generate, store and set the IR and ER root keys, 
*                       ONLY on a BlueNRG-MS device, FW stack 7.1 and 7.1.a.
*                       Starting from BlueNRG-MS FW stack 7.1.b, the IR and ER root keys are randomly generated and 
*                       permanently stored in internal Flash at first initialization of the device (ACI_GATT_INIT).
*                       Refer to BlueNRG-MS solved issue ID 1177. 
*******************************************************************************/
#ifndef _ROOT_SECURITY_KEYS_H
#define _ROOT_SECURITY_KEYS_H

#if BLUENRG_MS
uint8_t generate_security_root_keys(void); 
#endif 

#endif /* _ROOT_SECURITY_KEYS_H */
