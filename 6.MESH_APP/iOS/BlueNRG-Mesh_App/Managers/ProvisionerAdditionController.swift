//
//  ProvisionerAdditionController.swift
//  BlueNRG-Mesh App
//
//  Created by Slab Noida on 17/05/18.
//  Copyright © 2018 STM. All rights reserved.
//

import UIKit

class ProvisionerAdditionController: NSObject {

    let currentNetworkMangager = NetworkDataManager.sharedInstance
    static let sharedInstance: ProvisionerAdditionController = {
        let instance = ProvisionerAdditionController()
        //Setup code
        return instance
    }()
    
    public func createProvisionerDataFieldValues () -> Void{
        let provisonerUUID = UIDevice.current.identifierForVendor?.uuidString
        print("Provisoner UUID ",provisonerUUID!)
        
        let provisionerName = UIDevice.current.name
        print("Provisoner Name ",provisionerName )
        
        let provisionerAddressRange : UInt16 = 0x00C8  //  = 100 decimals
        let provisionerUnicastAddressRange : UInt16 = 100  //  = 100 decimals
        let provisionerUnicastLowRange  = self.getProvisionerUnicastLowAddress()
        let provisionerUnicastHighRange = provisionerUnicastLowRange + provisionerUnicastAddressRange
        let provisionerGroupLowRange  = self.getProvisionerGroupLowAddress()
        let provisionerGroupHighRange = provisionerGroupLowRange + provisionerAddressRange
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
        
        // adding provisioner as node in node list
        let provisionerNode = STMeshNode()
        provisionerNode.nodeName = "provisionerName"
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
        currentNetworkMangager.saveNodesToStorage()
        
    }
    func checkIfProvisionerExist() -> Bool{
        
        for objProvData in (currentNetworkMangager.currentNetworkData.provisionerDataArray)! {
            let objectCurrentProvisioner  = objProvData as! STMeshProvisionerData
            let alreadyAddedProvisioner = objectCurrentProvisioner.provisionerUUID as String
            let provUUID = UIDevice.current.identifierForVendor!.uuidString as String
            print("already added provisioner UUID in array ", alreadyAddedProvisioner)
            print("Device UUID ",provUUID)
            if ((alreadyAddedProvisioner.caseInsensitiveCompare(provUUID) == .orderedSame)){
                return true
            }
        }
        return false
    }
    func getProvisionerUnicastLowAddress() -> UInt16 {
        let provisionerDataList = currentNetworkMangager.currentNetworkData.provisionerDataArray
        var upperBoundValue : UInt16 = 0
        
        
        for obj in provisionerDataList!{
            let objProvisioner = obj as! STMeshProvisionerData
            
            let allocatedUnicastRange = objProvisioner.marrProvisionerAllocatedUnicastRange[0] as! NSMutableDictionary
            _ = allocatedUnicastRange.value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! UInt16
            let unicastHighRange = allocatedUnicastRange.value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
            let unicastHighAddressIntValue = UInt16(Int(unicastHighRange, radix: 16)!)
            
            if (upperBoundValue < unicastHighAddressIntValue){
                upperBoundValue = unicastHighAddressIntValue
            }
            
        }
        return upperBoundValue
    }
    
    
    func getProvisionerGroupLowAddress() -> UInt16 {
        
        let provisionerDataList = currentNetworkMangager.currentNetworkData.provisionerDataArray
        var upperBoundValue : UInt16 = 0xC001
        for obj in provisionerDataList!{
            let objProvisioner = obj as! STMeshProvisionerData
            let allocatedGroupRange = objProvisioner.marrProvisionerAllocatedGroupRange[0] as! NSMutableDictionary
            _ = allocatedGroupRange.value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! UInt16
            let groupHighRange = allocatedGroupRange.value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
            let groupHighAddressIntValue = UInt16(Int(groupHighRange, radix: 16)!)

            if (upperBoundValue < groupHighAddressIntValue){
                upperBoundValue = groupHighAddressIntValue
            }
            
        }
        return upperBoundValue
    }
}
