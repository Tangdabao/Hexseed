/**
 ******************************************************************************
 * @file    STMeshProvisioner.h
 * @author  BlueNRG-Mesh Team
 * @version V1.03.000
 * @date    19-Nov-2017
 * @brief   Provisioner API header file
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

#import <Foundation/Foundation.h>
#import "STMeshTypes.h"
#import "STMeshBasicTypes.h"
@protocol STMeshProvisionerDelegate;
@interface STMeshProvisioner : NSObject
@property(nonatomic, weak)id<STMeshProvisionerDelegate> delegate;

/**
 * @brief  This method starts scanning for unprovisioned devices.
 * @discussion Scan for unprovisioned devices in the vicinity is started, "didDeviceAppearedWithUUID" is called whenever such a device is found.
 * @param1  timeOut parameter determines for how long the scanning for unprovisioned devices continues. In current release, this parameter has no effect.
 * @return Result of the method execution.
 */
- (STMeshStatus) startDeviceScan:(uint32_t)timeOut;


/**
 * @brief  This method stops scanning for unprovisioned devices .
 * @discussion Stop scan for unprovisioned devices in the vicinity.
 * @return Result of the method execution.
 */
- (STMeshStatus) stopDeviceScan;


//REVIEW {RC 1.03.000}: deviceAddress parameter does not seem to be used, can be removed.
/**
 * @brief  Method is called for provisionining an unprovisioned device in the vicinity.
 * @discussion This Method is used for provisioned a unprovisioned Device to your mesh Networks
 * @param1  node STMeshNode Object corresponding to the device to be provisioned. UUID field of the node object should be filled.
 * @param2  address  unicast address to be assigned to the device during provisioning.
 * @param3 duration time for which unprovisioned device would identify itself (e.g. by blinking LED).
 * @return Result of the method execution.
 */
- (STMeshStatus) provisionDevice:(STMeshNode *)node  deviceAddress:(uint16_t)address
              identificationTime:(uint32_t)duration;
@end

@protocol STMeshProvisionerDelegate <NSObject>


@optional
/**
 * @brief  Called during the provisioning process, to update the status.
 * @discussion Percentage 100% means configuration stage is completed.
 * @param1  provisioner Reference of the provisioner object calling this method.
 * @param2  percentage  Provisioning progress in percent.
 * @param3 message String related to the current provisioning stage.
 * @param4 error Flag to notify if provisioning process encounters error.
 */
- (void) provisioner:(STMeshProvisioner *)provisioner didProvisionStageChanged:(int32_t)percentage
       updateMessage:(NSString *)message hasError:(BOOL)error;

@optional
/**
 * @brief  Called during the provisioning process, to notify the device capabilities.
 * @discussion Method is called as soon as device capabilites message is received from the device under provisioning.
 * @param1  provisioner Reference of the provisioner object calling this method.
 * @param2  elementCount  as reported by the device in the capabilities message.
 */
- (void)provisioner:(STMeshProvisioner *)provisioner didReceiveCapabilitesElementCount:(uint8_t)elementCount;


@optional
/**
 * @brief  Called during unprovisioned device scan.
 * @discussion This callback is invoked when advertisement packet from unprovisioned device is received. This is used for updating the unprovisioned device scan UI, rssi values can be updated in real time using this callback.
 * @param1  provisioner Reference of the provisioner object calling this method.
 * @param2  uuid  UUID of the unprovisioned device found during the scan.
 * @param3 rssi value of the advertisement message received from the unprovisioned device.
 */
- (void) provisioner:(STMeshProvisioner *)provisioner didDeviceAppearedWithUUID:(NSString*)uuid
                RSSI:(int32_t)rssi;

@end
