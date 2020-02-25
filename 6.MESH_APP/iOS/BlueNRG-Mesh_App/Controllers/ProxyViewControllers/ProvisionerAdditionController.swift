/**
 ******************************************************************************
 * @file    ProvisionerAdditionController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    17-May-2018
 * @brief   ViewController for "Node Information" View.
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
let KConstantIsProvisionerAdded = "IS Provsioner Added"

class ProvisionerAdditionController: NSObject {
    
    let currentNetworkMangager = NetworkConfigDataManager.sharedInstance
    static let sharedInstance: ProvisionerAdditionController = {
        let instance = ProvisionerAdditionController()
        //Setup code
        return instance
    }()
    var isProvisionerAddedLocally : Bool = false
    public func createProvisionerDataFieldValues () -> Void{
        let provisonerUUID = UIDevice.current.identifierForVendor?.uuidString.lowercased()
        print("Provisoner UUID ",provisonerUUID!)
        
        let provisionerName = UIDevice.current.name
        print("Provisoner Name ",provisionerName )
        
        //let provisionerGroupAddressRange : UInt16 = 0x00C8  //  = 100 decimals
        let provisionerUnicastAddressRange : UInt16 = 100  //  = 100 decimals
        let provisionerUnicastLowRange  = self.getProvisionerUnicastLowAddress()
        let provisionerUnicastHighRange = provisionerUnicastLowRange + provisionerUnicastAddressRange
        let provisionerGroupLowRange  = self.getProvisionerGroupLowAddress()
        let provisionerGroupHighRange = provisionerGroupLowRange + provisionerUnicastAddressRange
        let objSTMeshProvisioner = STMeshProvisionerData()
        objSTMeshProvisioner.provisionerName = provisionerName
        objSTMeshProvisioner.provisionerUUID = provisonerUUID
        
        let provisionerUnicastLowAddress = String(provisionerUnicastLowRange)
        let provisionerUnicastHighddress = String(provisionerUnicastHighRange)
        
        let provisionerGroupLowAddress = String(provisionerGroupLowRange)
        let provisionerGroupHighAddress = String(provisionerGroupHighRange)
        
        let objUnicastInnerObjects = ProvisioningRangeObjects.init(rangeObjectsWithMinValue: provisionerUnicastLowAddress, maxValue: provisionerUnicastHighddress) as ProvisioningRangeObjects
        let objGroupInnerObjects = ProvisioningRangeObjects.init(rangeObjectsWithMinValue: provisionerGroupLowAddress, maxValue: provisionerGroupHighAddress) as ProvisioningRangeObjects
        
        objSTMeshProvisioner.marrProvisionerAllocatedUnicastRange.add(objUnicastInnerObjects)
        objSTMeshProvisioner.marrProvisionerAllocatedGroupRange.add(objGroupInnerObjects)
        
        userDefault.set(provisonerUUID, forKey: STMesh_UserDefaultValues_CurrentProvisionerUUID)
        currentNetworkMangager.currentNetworkData.provisionerDataArray.add(objSTMeshProvisioner)
        
        /* Adding provisioner as node in node list */
        let provisionerNode = STMeshNode()
        provisionerNode.nodeName = UIDevice.current.name
        provisionerNode.blacklisted = false
        provisionerNode.nodeUUID = provisonerUUID
        provisionerNode.deviceKey = ""
        provisionerNode.publishAddress = 0
        provisionerNode.configComplete = false
        
        
        let provisionerElement = STMeshElement()
        provisionerElement.unicastAddress = provisionerUnicastLowRange
        provisionerElement.index = 0
        provisionerElement.elementName = "provisioner Element"
        
        let provisionerModel = STMeshModel()
        provisionerModel.modelId = 0
        provisionerModel.subscribeList = NSMutableArray()
        provisionerModel.publish = nil
        
        provisionerElement.modelList.add(provisionerModel)
        provisionerNode.elementList.add(provisionerElement)
        currentNetworkMangager.currentNetworkData.onlyProvisionerArray.add(provisionerNode)
        currentNetworkMangager.saveNetworkConfigToStorage()
        UserDefaults.standard.set(true, forKey: KConstantIsProvisionerAdded)
        isProvisionerAddedLocally = true
        
    }
    
    func checkIfProvisionerExist() -> Bool{
        
        for objProvData in (currentNetworkMangager.currentNetworkData.provisionerDataArray)! {
            let objectCurrentProvisioner  = objProvData as! STMeshProvisionerData
            let alreadyAddedProvisioner = objectCurrentProvisioner.provisionerUUID as String
            let provUUID = UIDevice.current.identifierForVendor!.uuidString as String
            print("already added provisioner UUID in array ", alreadyAddedProvisioner)
            print("Device UUID ",provUUID)
            if ((alreadyAddedProvisioner .caseInsensitiveCompare(provUUID) == .orderedSame)){
                return true
            }
        }
        return false
    }
    
    func getProvisionerUnicastLowAddress() -> UInt16 {
        let provisionerDataList = currentNetworkMangager.currentNetworkData.provisionerDataArray
        var lowerBoundValue : UInt16 = 2
        for obj in provisionerDataList!{
            let objProvisioner = obj as! STMeshProvisionerData
            
            let allocatedUnicastRange = objProvisioner.marrProvisionerAllocatedUnicastRange[0] as! NSMutableDictionary
            _ = allocatedUnicastRange.value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! String
            let unicastHighRange = allocatedUnicastRange.value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
            if let unicastHighAddressIntValue = UInt16(unicastHighRange, radix: 16){
                
                if (lowerBoundValue < unicastHighAddressIntValue){
                    lowerBoundValue = unicastHighAddressIntValue
                }
            }
        }
        return lowerBoundValue
    }
    
    
    func getProvisionerGroupLowAddress() -> UInt16 {
        
        let provisionerDataList = currentNetworkMangager.currentNetworkData.provisionerDataArray
        var lowerBoundValue : UInt16 = 49153
        for obj in provisionerDataList!{
            let objProvisioner = obj as! STMeshProvisionerData
            let allocatedGroupRange = objProvisioner.marrProvisionerAllocatedGroupRange[0] as! NSMutableDictionary
            //            _ = allocatedGroupRange.value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! String
            let groupHighRange = allocatedGroupRange.value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
            print("Group high Range",groupHighRange)
            
            if let groupHighAddressIntValue = UInt16(groupHighRange, radix: 16){
                print("Group high Address Range",groupHighAddressIntValue)
                
                if (lowerBoundValue < groupHighAddressIntValue){
                    lowerBoundValue = groupHighAddressIntValue
                }
            }
            
        }
        return lowerBoundValue
    }
    
    
    public func AlreadyAddedProvisionerDataFieldValues () -> Void{
        
        print("Values before addition ", currentNetworkMangager.currentNetworkData.provisionerDataArray)
        for objProvData in (currentNetworkMangager.currentNetworkData.provisionerDataArray)! {
            let objectCurrentProvisioner  = objProvData as! STMeshProvisionerData
            let alreadyAddedProvisioner = objectCurrentProvisioner.provisionerUUID as String
            let provUUID = UIDevice.current.identifierForVendor!.uuidString as String
            print("already added provisioner UUID in array ", alreadyAddedProvisioner)
            print("Device UUID ",provUUID)
            if ((alreadyAddedProvisioner .caseInsensitiveCompare(provUUID) == .orderedSame)){
                currentNetworkMangager.currentNetworkData.provisionerDataArray.remove(objectCurrentProvisioner)
            }
            
            
        }
        print("Values After Deletion ", currentNetworkMangager.currentNetworkData.provisionerDataArray)
        
        let provisonerUUID = UIDevice.current.identifierForVendor?.uuidString.lowercased()
        print("Provisoner UUID ",provisonerUUID!)
        
        let provisionerName = UIDevice.current.name
        print("Provisoner Name ",provisionerName )
        
        let provisionerDataList = currentNetworkMangager.currentNetworkData.provisionerDataArray 
        let provCount = provisionerDataList?.count
        
        let provisionerUnicastAddressRange : UInt16 = 100  //  = 100 decimals
        let provisionerUnicastLowRange  = 3 + provCount! * 100 + 10
        let provisionerUnicastHighRange = UInt16(provisionerUnicastLowRange) + provisionerUnicastAddressRange
        let provisionerGroupLowRange  = 49153 + provCount! * 100 + 10
        let provisionerGroupHighRange = UInt16(provisionerGroupLowRange) + provisionerUnicastAddressRange
        let objSTMeshProvisioner = STMeshProvisionerData()
        objSTMeshProvisioner.provisionerName = provisionerName
        objSTMeshProvisioner.provisionerUUID = provisonerUUID
        
        let provisionerUnicastLowAddress = String(provisionerUnicastLowRange)
        let provisionerUnicastHighddress = String(provisionerUnicastHighRange)
        
        let provisionerGroupLowAddress = String(provisionerGroupLowRange)
        let provisionerGroupHighAddress = String(provisionerGroupHighRange)
        
        let objUnicastInnerObjects = ProvisioningRangeObjects.init(rangeObjectsWithMinValue: provisionerUnicastLowAddress, maxValue: provisionerUnicastHighddress) as ProvisioningRangeObjects
        let objGroupInnerObjects = ProvisioningRangeObjects.init(rangeObjectsWithMinValue: provisionerGroupLowAddress, maxValue: provisionerGroupHighAddress) as ProvisioningRangeObjects
        
        objSTMeshProvisioner.marrProvisionerAllocatedUnicastRange.add(objUnicastInnerObjects)
        objSTMeshProvisioner.marrProvisionerAllocatedGroupRange.add(objGroupInnerObjects)
        
        userDefault.set(provisonerUUID, forKey: STMesh_UserDefaultValues_CurrentProvisionerUUID)
        currentNetworkMangager.currentNetworkData.provisionerDataArray.add(objSTMeshProvisioner)
        
        /* Adding provisioner as node in node list */
        let provisionerNode = STMeshNode()
        provisionerNode.nodeName = UIDevice.current.name
        provisionerNode.blacklisted = false
        provisionerNode.nodeUUID = provisonerUUID
        provisionerNode.deviceKey = ""
        provisionerNode.publishAddress = 0
        provisionerNode.configComplete = false
        
        
        let provisionerElement = STMeshElement()
        provisionerElement.unicastAddress = UInt16(provisionerUnicastLowRange)
        provisionerElement.index = 0
        provisionerElement.elementName = "provisioner Element"
        
        let provisionerModel = STMeshModel()
        provisionerModel.modelId = 0
        provisionerModel.subscribeList = NSMutableArray()
        provisionerModel.publish = nil
        
        provisionerElement.modelList.add(provisionerModel)
        provisionerNode.elementList.add(provisionerElement)
        
        currentNetworkMangager.currentNetworkData.onlyProvisionerArray.add(provisionerNode)
        currentNetworkMangager.saveNetworkConfigToStorage()
        
        isProvisionerAddedLocally = true
        UserDefaults.standard.set(true, forKey: KConstantIsProvisionerAdded)
        
        
    }
}
