/**
 ******************************************************************************
 * @file    ProvisioningManager.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.02.000
 * @date    06-Feb-2018
 * @brief   Manager class for Provisioning.
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
import Foundation

protocol ProvisioningManagerDelegate {
    func didReciveNewNode(newNode:UnprovisionedNode)
    func rssiValueDidChangeFor(node:UnprovisionedNode, index:IndexPath)
    func didProvisioningFinishFor(unprovisionedNode:UnprovisionedNode, newNode:STMeshNode)
}

class ProvisioningManager: NSObject {
    
    var manager:STMeshManager!
    var nodeNamePrifixed = "New Node"
    var addTimer: Timer!
    var provisioningTimer: Timer!
    var nodeBeingAdded: STMeshNode?
    var unprovisionedNodesCount = 0
    var provisioningCurrentStep = 0
    var nodeToAdd: UnprovisionedNode!
    var currentNetworkMangager:NetworkConfigDataManager?
    var delegate:ProvisioningManagerDelegate?
    var operationMode = BLEOperationModes.Disabled
    var provisioningProgressView:ProvisioningPopUpController?
    var unprovisionedNodes: [UnprovisionedNode] = []
    
    
    func initialSetup(currrentNewworkData:NetworkConfigDataManager){
        self.currentNetworkMangager = currrentNewworkData
        //createProvisionerDataFieldValues()
        unprovisionedNodes = []
        manager = STMeshManager.getInstance(self)
        manager.getProvisioner().delegate = self
        
        startScanfordevice()
    }
    
    /**
     These methods are private
     */
    private func startScanfordevice(){
        manager.getProvisioner().startDeviceScan(15)
    }
    private func stopScanForDevice(){
        manager.getProvisioner().stopDeviceScan()
    }
    
    private func findNodeIndex(uuid: String) -> Int? {
        for index in 0..<unprovisionedNodes.count {
            if(unprovisionedNodes[index].nodeUUID == uuid) {
                return index
            }
        }
        return nil
    }
    
    fileprivate func addOrUpdateNode(uuid:String, rssi:Int32) {
        if let index = findNodeIndex(uuid: uuid) {
            /* Already exists */
            let indexPath = IndexPath(row: index, section: 0)
            let node = unprovisionedNodes[index]
            /* Check if update is required */
            if(node.rssiValue != rssi) {
                node.rssiValue = rssi

                delegate?.rssiValueDidChangeFor(node:node, index: indexPath)
            }
        }
        else {
            let newNode = UnprovisionedNode()
            newNode.nodeUUID = uuid
            newNode.rssiValue = rssi
            newNode.nodeName = String(format:"New Node %02d",getNewNodeNameSuffix())
            unprovisionedNodes.append(newNode)
            delegate?.didReciveNewNode(newNode:newNode)
            unprovisionedNodesCount += 1
        }
    }
    
    
    /* Get new node name with suffix */
    private func getNewNodeNameSuffix()->Int{
        var nodeNameSuffix = 01
        if (self.currentNetworkMangager?.currentNetworkData.nodes.count)! > 0 {
            let provisionedNode  =  self.currentNetworkMangager?.currentNetworkData.nodes.filter{ (node) -> Bool in
                (node as! STMeshNode).nodeName.contains(nodeNamePrifixed)
            }
            if let addNodeNodes = provisionedNode as? [STMeshNode] , addNodeNodes.count > 0{
                for i in -(addNodeNodes.count-1)...0{
                    let node = addNodeNodes[abs(i)]
                    let lastNodeNameArray = node.nodeName.split(separator:" ")
                    if (lastNodeNameArray.last as NSString?)?.intValue != nil  && (lastNodeNameArray.last! as NSString).intValue > 0{
                        nodeNameSuffix = Int((lastNodeNameArray.last as NSString?)!.intValue + 1)
                        return nodeNameSuffix
                    }
                }
            }
        }
        return nodeNameSuffix
    }
    
    public func startProvisioningforNode(node:UnprovisionedNode, progressView:ProvisioningPopUpController){
        
        if (!ProvisionerAdditionController.sharedInstance.checkIfProvisionerExist()){
            ProvisionerAdditionController.sharedInstance.createProvisionerDataFieldValues()
        }
        
        self.provisioningProgressView = progressView
        nodeToAdd = node
        provisioningCurrentStep = 1
        nodeBeingAdded = STMeshNode()
        nodeBeingAdded!.nodeUUID = node.nodeUUID
        nodeBeingAdded!.nodeName = node.nodeName
        nodeBeingAdded!.unicastAddress = self.getUnicastAddressOfNode()
        manager?.getProvisioner().provisionDevice(nodeBeingAdded!, deviceAddress: 0, identificationTime: 10)
    }
    
    /* Called for getting unicast address of newUnprovisioned node */
    fileprivate func getUnicastAddressOfNode() ->UInt16{
        
        for objProvisioner in (self.currentNetworkMangager?.currentNetworkData.provisionerDataArray)! as! [STMeshProvisionerData] {
            
            let allocatedUnicastRange = objProvisioner.marrProvisionerAllocatedUnicastRange[0]
            let unicastLowRange = (allocatedUnicastRange as AnyObject).value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! String
            let unicastHighRange = (allocatedUnicastRange as AnyObject).value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
            
            let allocatedUnicastLowAddressIntValue = UInt16(unicastLowRange, radix: 16)!
            let allocatedUnicastHighAddressIntValue = UInt16(unicastHighRange, radix: 16)!
            
            /* Currentlly provisioning UUID is Device UUID it will change */
            let  strProvUUID = (UIDevice.current.identifierForVendor?.uuidString)!
            
            if ((objProvisioner.provisionerUUID as String).caseInsensitiveCompare(strProvUUID) == .orderedSame ){
                _ = objProvisioner
                
                /* Start with address current provisioner unicastLowAddressRange + 2 */
                var nextUnicastAddress: UInt16 = allocatedUnicastLowAddressIntValue + 1
                
                let nodes = self.currentNetworkMangager?.currentNetworkData.nodes!
                if let newNode = nodes?.sorted(by: { ($0 as! STMeshNode).unicastAddress < ($1 as! STMeshNode).unicastAddress }) as? [STMeshNode]{
                    if (newNode.count != 0 ){
                        for i in 0..<newNode.count {
                            if (newNode[i].unicastAddress > allocatedUnicastLowAddressIntValue && newNode[i].unicastAddress < allocatedUnicastHighAddressIntValue){
                                let node = newNode[i]
                                if(node.unicastAddress == nextUnicastAddress ) {
                                    let nodeElementCount : UInt16 = UInt16(node.elementList.count);
                                    nextUnicastAddress = nodeElementCount + nextUnicastAddress ;
                                }
                            }
                            else{
                                print("Unicast Address of node", newNode[i].unicastAddress ,"is not between in ",unicastLowRange ,"to ", unicastHighRange , "range")
                            }
                        }
                        return nextUnicastAddress;
                    }
                    else{
                        return nextUnicastAddress;
                    }
                }
            }
        }
        return 0;
    }
    
    class func getSTMeshBleRadioStatus(state:STMeshBleRadioState) ->(mode:BLEOperationModes , message:String?){
        let alertTitle = "BLE Status"
        var alertMessage = ""
        var operationMode = BLEOperationModes.Disabled
        
        switch state {
        case STMeshBleRadioState_Unknown:
            alertMessage = "Radio state is unknown"
        case STMeshBleRadioState_Unsupported:
            alertMessage = "BLE is not supported on this device,do you want dummy mode active"
            operationMode = BLEOperationModes.DummyMode
        //dummyMode = true
        case STMeshBleRadioState_Unauthorized:
            alertMessage = "This App does not have permission to use BLE, Please Grant it."
            
        case STMeshBleRadioState_PoweredOn:
            operationMode = BLEOperationModes.RadioMode
            return (operationMode, nil)
        case STMeshBleRadioState_PoweredOff:
            alertMessage = "Bluetooth is switched off. do you want dummy mode active" //Running in dummy mode
            operationMode = BLEOperationModes.DummyMode
        default: break
        }
        if alertMessage.count > 0 && operationMode != BLEOperationModes.DummyMode{
            // if alertMessage.count > 0{
            CommonUtils.showAlertWith(title:alertTitle, message: alertMessage, presentedOnViewController:CommonUtils.getTopNavigationController().viewControllers.last)
            //  if alertMessage.count > 0{
            //        CommonUtils.showAlertWith(title:alertTitle, message: alertMessage, presentedOnViewController:CommonUtils.getTopNavigationController().viewControllers.last)
            //        commonAlertView().setUpGUIAlertView(title: alertTitle, message: alertMessage, viewController: CommonUtils.getTopNavigationController().viewControllers.last!, firstButtonTitle: "OK", reqSecondButton: false, secondButtonText: "", firstButtonAction: blankClosure, secondButtonAction: blankClosure)
        }
        return (operationMode, alertMessage)
    }
}

extension ProvisioningManager :STMeshManagerDelegate{
    
    func meshManager(_ manager: STMeshManager!, didProxyConnectionChanged isConnected: Bool) {
        
    }
    
    func meshManager(_ manager:STMeshManager!, didBTStateChange state:STMeshBleRadioState) {
        let radioMode = ProvisioningManager.getSTMeshBleRadioStatus(state:state)
        operationMode = radioMode.mode
    }
    
}

extension ProvisioningManager :STMeshProvisionerDelegate
{
    func provisioner(_ provisioner: STMeshProvisioner!, didDeviceAppearedWithUUID uuid: String!, rssi: Int32) {
        addOrUpdateNode(uuid: uuid, rssi: rssi)
    }
    func provisioner(_ provisioner:STMeshProvisioner!, didProvisionStageChanged percentage:Int32,
                     updateMessage message:String!, hasError error:Bool) {
        provisioningProgressView?.updateProgress(percent: Int(percentage), message: message, isError: false)
        if(percentage == 100) {
            if(provisioningTimer != nil) {
                // self.stopScanForDevice()
                provisioningTimer.invalidate()
            }
            
            delegate?.didProvisioningFinishFor(unprovisionedNode:nodeToAdd, newNode:nodeBeingAdded!)
        }
    }
    
    func provisioner(_ provisioner: STMeshProvisioner!, didReceiveCapabilitesElementCount elementCount: UInt8) {
        if (nodeBeingAdded != nil)
        {
            for  elementNumber in 0 ..< elementCount
            {
                let element = STMeshElement()
                element.unicastAddress = (nodeBeingAdded?.unicastAddress)! + UInt16(elementNumber)
                print("element address is ",element)
                element.elementName = String(format:"Element 0%d",elementNumber+1)
                print(element.elementName)
                element.parentNode = nodeBeingAdded
                nodeBeingAdded?.elementList.add(element)
            }
            currentNetworkMangager?.saveNetworkConfigToStorage()
        }
    }
}

