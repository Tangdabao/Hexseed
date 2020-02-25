/**
 ******************************************************************************
 * @file    LEDControlManager.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    23-Apr-2018
 * @brief   Helper class for Vendor model functions.
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) 2018 STMicroelectronics</center></h2>
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
 ******************************************************************************
 */


import UIKit

class LEDControlManager: NSObject {
    
    /* Called to set vendor model ON / OFF */
    class func setLEDState(controller:UIViewController, manager:STMeshManager, addr:UInt16, cmd:Bool)
    {
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 2)
        var sendData :Data = Data(count:1)
        sendData[0] = (UInt8)(cmd ? AppliGroupLEDControlCmdOn :AppliGroupLEDControlCmdOff)
        sendData.append(data as Data)
        var success: STMeshStatus!
        if !UserDefaults.standard.bool(forKey: KConstantModeKey){
            success = manager.getGenericModel().setGenericOnOff(addr, isOn:cmd, isUnacknowledged:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
        }
        else{
            success = manager.getVendorModel().setRemoteData(addr, usingOpcode: AppliGroupLEDControl, send: sendData , isResponseNeeded:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
        }
        if(success != STMeshStatus_Success){
            CommonUtils.showAlertWith(title:"", message: "Couldn't connect!", presentedOnViewController:controller)
        }
    }
    
    /* Called to set vendor model intensity */
    class func setLEDIntensityWithVendor(address:UInt16, sender:UISlider, manager:STMeshManager)
    {
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 3)
        var sendData :Data = Data(count:3)
        sendData[0] = (UInt8)(AppliGroupLEDControlCmdIntensityToggle)
        let intensityValue = UInt16((Float(String(format:"%.0f",sender.value)))! * ((Float(INT16_MAX))/100))
        sendData[1] = UInt8(truncatingIfNeeded: intensityValue)
        sendData[2] = UInt8(truncatingIfNeeded: intensityValue >> 8)
        
        sendData.append(data as Data)
        _ = manager.getVendorModel().setRemoteData(address, usingOpcode: AppliGroupLEDControl, send: sendData , isResponseNeeded:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
    }
}
