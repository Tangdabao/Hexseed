/**
 ******************************************************************************
 * @file    CommonTypes.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    06-Sep-2017
 * @brief   Class defines the common types used by App
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

import Foundation
import UIKit

/* Contants Key */

let KConstantHelpMessageKey = "Helper Message for a Element"
let KConstantHelpElementKey = "Helper Element Key"

let KConstantHelpScreenToShowForProxyViewController = "Help Screen To Show to User For Proxy screen "
let KConstantHelpScreenToShowForProxyViewControllerOnAtleastOneNode = "Help Screen To Show to User For Proxy screen when one node is added"

let KConstantHelpScreenToShowForSettingViewController = "Help Screen To Show to User For Setting screen "
let KConstantHelpScreenToShowForModelListViewController = "Help Screen To Show to User For Model List screen "
let KConstantHelpScreenToShowForVendorModelListViewController = "Help Screen To Show to User For Vendor Model List screen "
let KConstantHelpScreenToShowForGenricModelListViewController = "Help Screen To Show to User For Generic Model List screen "
let KConstantHelpScreenToShowForLightingModelListViewController = "Help Screen To Show to User For Lighting Model List screen "

let KConstantReliableModeKey = "Reliable Mode Key"
let KConstantProxyConnectionNodeIdentityModeKey = "Proxy Connection Node Identity Key"
let KConstantSIGTestData = "SIG Test Data Key"
let KConstantModeKey = "Use vendor Model"
let KConstantAfterEveryThirdTime = "Occur every third time"



let KConstantSelectedModelScreen = "SelectedModels"

let STMesh_NetworkSettings_Key = "networkSettings"
let STMesh_IVIndex_Key = "IVindex"
let STMesh_NetKey_Key = "netKeys"
let STMesh_AppKey_Key = "appKeys"
let STMesh_MeshUUID_Key = "meshUUID"
let STMesh_MeshName_Key = "meshName"

let STMesh_AppKey_Index_Key = "index"
let STMesh_AppKey_BoundNetKey_Key = "boundNetKey"
let STMesh_key = "key"

let STMesh_NodeCollection_Key = "nodes"
let STMesh_GroupCollection_Key = "groups"
let STMesh_ProvisionerDataCollection_Key = "provisioners"

let STMesh_ElementCollection_Key = "elements"
let STMesh_Element_Index_key = "index"
let STMesh_ElemementUnicastAddress_Key = "unicastAddress"
let STMesh_ElementName_Key = "name"

let STMesh_ModelsCollection_Key = "models"
let STMesh_ModelId_Key  = "modelId"
let STMesh_Model_Publish_Key = "publish"
let STMesh_Publish_Address_key = "address"
let STMesh_SubscribeCollection_Key = "subscribe"

let STMesh_NodeName_Key = "Name"
let STMesh_NodeUUID_Key = "UUID"

let STMesh_NodeCid_Key = "cid"
let STMesh_NodePid_Key = "pid"
let STMesh_NodeVid_Key = "vid"
let STMesh_NodeCrpl_Key = "crpl"

let STMesh_NodeFeatures_key = "features"
let STMesh_NodeFeaturesRelay_key = "relay"
let STMesh_NodeFeaturesProxy_key = "proxy"
let STMesh_NodeFeaturesFriend_key = "friend"
let STMesh_NodeFeaturesLowPower_key = "lowPower"

let STMesh_DeviceKey_Key = "deviceKey"
let STMesh_Blacklisted_Key = "blacklisted"
let STMesh_ConfigComplete_Key = "configComplete"

let STMesh_ProvisionerName_Key = "provisionerName"
let STMesh_ProvisionerUUID_Key = "UUID"
let STMesh_ProvisionerUnicastAddressRange_Key = "allocatedUnicastRange"
let STMesh_ProvisionerGroupAdressRange_Key = "allocatedGroupRange"


let STMesh_Groups_Key = "group"
let STMesh_GroupName_Key = "name"
let STMesh_GroupAddress_Key = "address"

let STMesh_PublisherCollection_Key = "PublisherCollection"
let STMesh_PublisherTarget_Key = "PublisherTarget"

let STMesh_PublisherTargetName_Key = "PublisherTargetName"
let STMesh_ModelPublish_Key = "address"
let STMesh_PublisherTargetType_Key = "PublisherTargetType"

let STMesh_PublishAddress_Key = "publishAddress"

let STMesh_PublishDetails_Key = "publish"
let STMesh_PublishDetails_ModelId_Key = "modelId"
let STMesh_PublishDetails_Address_Key = "address"
let STMesh_PublishDetails_AppKeyIndex_Key = "appKeyIndex"
let STMesh_PublishDetails_Ttl_Key = "ttl"

let STMesh_Elements_Key = "elements"


let STMesh_UserDefaultValues_CurrentProvisionerUUID = "provisioner UUID value in userDefaults"


let AppTitle = "BlueNRG-Mesh"

let AppliGroupDeviceInfo:UInt32 = 2
let AppliGroupDeviceInfoCmdICType:UInt32 = 1
let AppliGroupDeviceInfoCmdLibVersion:UInt32 = 2
let AppliGroupDeviceInfoCmdLibSubVersion:UInt32 = 3
let AppliGroupDeviceInfoCmdAppVersion:UInt32 = 4

let AppliGroupLEDControl:UInt32 = 3
let AppliGroupLEDControlCmdOn:UInt32 = 1
let AppliGroupLEDControlCmdOff:UInt32 = 2
let AppliGroupLEDControlCmdToggle:UInt32 = 3
let AppliGroupLEDControlCmdBigBulbToggle:UInt32 = 5
let AppliGroupLEDControlCmdIntensityToggle:UInt32 = 6


let AppliGroupDeviceTypeCmd:UInt32 = 4

/* Group Addition threshold Values */
let MaximumSubscribersOfNode = 9 // for production it needs to be 9

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let screenHeight = UIScreen.main.bounds.size.height
let screenWidth = UIScreen.main.bounds.size.width
let userDefault : UserDefaults = UserDefaults.standard

/* Class which stores data of Unprovisioned Nodes */
class UnprovisionedNode {
    var nodeName = String ()
    var nodeUUID = String()
    var rssiValue:Int32 =  -55
    var group = STMeshGroup()
    
}

enum BLEOperationModes {
    case Disabled
    case DummyMode
    case RadioMode
}

public typealias btnActionClosure = () -> Void
let blankClosure = {() -> Void in }
