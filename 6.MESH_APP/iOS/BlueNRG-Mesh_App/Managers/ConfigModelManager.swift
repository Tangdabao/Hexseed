  /**
   ******************************************************************************
   * @file    ConfigManager.swift
   * @author  BlueNRG-Mesh Team
   * @version V1.03.000
   * @date    22-Mar-2018
   * @brief   Class to manage network configuration.
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
  
  protocol ConfigManagerDelegate
  {
    func didAppKeyAssignmentSuccessfullyCompleted(completed:Bool , message:String);
    func didAdd_RemoveSubcriptionSuccessfullyCompleted(completed:Bool)
    func didAdd_RemovePublisherSuccessfullyCompleted(completed:Bool)
    func didRemoveNodeSuccessfullyCompleted(completed:Bool)
    func didReceivedCompostionData(completed:Bool)
    func didProxyStatusReceived(status:ConfigState,address:UInt16)
    func didFreiendStatusReceived(status:ConfigState,address:UInt16)
    func didRelayStatusReceived(status:ConfigState,address:UInt16)
  }
  extension ConfigManagerDelegate{
    
    func didReceivedCompostionData(completed:Bool){}
    func didProxyStatusReceived(status:ConfigState,address:UInt16){}
    func didFreiendStatusReceived(status:ConfigState,address:UInt16){}
    func didRelayStatusReceived(status:ConfigState,address:UInt16){}
  }
  
  
  
  
  class ConfigModelManager: NSObject {
    var manager :STMeshManager!
    var currentNetworkData:NetworkConfigDataManager!
    var delegate:ConfigManagerDelegate!
    var currentConfigMode:ConfigMode?
    var alertController:UIAlertController!
    var selectedElement:STMeshElement?
    var addGroup:[STMeshGroup] = [STMeshGroup]()
    var removeGroup:[STMeshGroup] = [STMeshGroup]()
    var currentGroupIndex = 0
    var publisher:AnyObject?
    var nodeToBeDelete:STMeshNode?
    func initialSetup(currrentNewworkData:NetworkConfigDataManager,delegate:ConfigManagerDelegate?){
        self.currentNetworkData = currrentNewworkData
        self.delegate = delegate
        manager = STMeshManager.getInstance(self)
        manager.getConfigurationModel().delegate = self
    }
    
    
    func addAppKey(node:STMeshNode)
    {
        self.manager?.getConfigurationModel().addConfigAppKey(onNode:node.unicastAddress, appKeyIndex:0, netKeyIndex: 0)
        self.showGroupProcessingMsg(message:"App key is being assigned to Element :\" \(node.nodeName ?? "")\".")
    }
    
    /* Add publisher of a element */
    func addPublisher(element:STMeshElement,publisher:AnyObject){
        currentConfigMode = .ConfigMode_AddPublish
        currentGroupIndex = 0
        selectedElement = element
        self.publisher = publisher
        if let publishElemTarget =  publisher as? STMeshElement {
            self.currentConfigMode =  .ConfigMode_AddPublish
            manager?.getConfigurationModel().setConfigModelPublicationOnNode(element.parentNode.unicastAddress, elementAddress: element.unicastAddress, publishAddress: publishElemTarget.unicastAddress, appKeyIndex: 0, credentialFlag: true, publishTTL: 0, publishPeriod: 0, retransmitCount: 0, retransmitInterval: 0, modelIdentifier: 0, isVendorModelId: false)
            self.showGroupProcessingMsg(message:"Element \"\(publishElemTarget.elementName ?? "")\" is being assigned as a publisher for Element:\" \(element.elementName ?? "")\".")
        }
        
        /* Checking publish address is  Group unicast address*/
        if let group =  publisher as? STMeshGroup {
            self.currentConfigMode =  .ConfigMode_AddPublish
            self.showGroupProcessingMsg(message:"group \"\(group.groupName ?? "")\" is being assigned as a publisher for Element:\" \(element.elementName ?? "")\".")
            self.currentConfigMode =  .ConfigMode_AddPublish
            manager?.getConfigurationModel().setConfigModelPublicationOnNode(element.parentNode.unicastAddress, elementAddress: element.unicastAddress, publishAddress: group.groupAddress, appKeyIndex: 0, credentialFlag: true, publishTTL: 0, publishPeriod: 0, retransmitCount: 0, retransmitInterval: 0, modelIdentifier: 0, isVendorModelId: false)
            
        }
    }
    
    
    /* Remove publisher of a element */
    func removePublisher(element:STMeshElement,publisher:AnyObject){
        currentConfigMode = .ConfigMode_RemovePublish
        currentGroupIndex = 0
        selectedElement = element
        self.publisher = publisher
        
        /* Checking publish address is Element unicast address*/
        if let publishElemTarget =  publisher as? STMeshElement {
            manager?.getConfigurationModel().setConfigModelPublicationOnNode(element.parentNode.unicastAddress, elementAddress: element.unicastAddress, publishAddress: 0, appKeyIndex: 0, credentialFlag: true, publishTTL: 0, publishPeriod: 0, retransmitCount: 0, retransmitInterval: 0, modelIdentifier: 0, isVendorModelId: false)
            self.showGroupProcessingMsg(message:"Element \"\(publishElemTarget.elementName ?? "")\" is being removed as a publisher for Element:\" \(element.elementName ?? "")\".")
        }
        
        /* Checking publish address is Element unicast address*/
        if let group =  publisher as? STMeshGroup {
            self.showGroupProcessingMsg(message:"group \"\(group.groupName ?? "")\" is being removed as a publisher for Element:\" \(element.elementName ?? "")\".")
            manager?.getConfigurationModel().setConfigModelPublicationOnNode(element.parentNode.unicastAddress, elementAddress: element.unicastAddress, publishAddress: 0, appKeyIndex: 0, credentialFlag: true, publishTTL: 0, publishPeriod: 0, retransmitCount: 0, retransmitInterval: 0, modelIdentifier: 0, isVendorModelId: false)
            
        }
    }
    
    /* Add multipal subscription / remove multipal subscription */
    func addSubscriber(element:STMeshElement,addSubcriberList:[STMeshGroup]?, removeSubcriberList:[STMeshGroup]?){
        addGroup = addSubcriberList ?? addGroup
        removeGroup = removeSubcriberList ?? removeGroup
        selectedElement = element
        if  removeSubcriberList != nil &&  (removeSubcriberList?.count)! > 0 {
            currentConfigMode = .ConfigMode_RemoveGroup
            currentGroupIndex = 0
            self.removeSubscriber(element:element, removeSubscriberList: removeSubcriberList!)
        }
            
            /* Checking is add subscription*/
        else if  addSubcriberList != nil {
            currentConfigMode = .ConfigMode_AddGroup
            currentGroupIndex = 0
            self.showGroupProcessingMsg(message:"group \"\(addSubcriberList![0].groupName!)\" is being assigned to Element :\" \(selectedElement?.elementName ?? "")\".")
            
            self.manager?.getConfigurationModel().addConfigModelSubscription(toNode:element.parentNode.unicastAddress, elementAddress: element.unicastAddress, address: addSubcriberList![0].groupAddress, modelIdentifier: 0, isVendorModelId: false)
        }
        
        
    }
    
    /* Read compostion data */
    func readCompostionData(element:STMeshElement) -> Bool{
        if element.modelList.count < 1{
            
            manager.getConfigurationModel().getConfigCompositionData(element.parentNode.unicastAddress, pageNumber: 0);
        }
        return element.modelList.count < 1 ? true : false
        
    }
    
    /* Refresh proxy status */
    func refreshProxyStatus(node:STMeshNode){
        let result =  manager.getConfigurationModel().getConfigNodeGATTProxy(node.unicastAddress)
        if result  == STMeshStatus(rawValue: 0){
            self.showGroupProcessingMsg(message:"reading GATT Proxy status for Node :\" \(selectedElement?.parentNode.nodeName ?? "")\".")}
        
    }
    
    /* Refresh friend status */
    func refreshFriendStatus(node:STMeshNode){
        let result =   manager.getConfigurationModel().getConfigNodeFriend(node.unicastAddress)
        if result  == STMeshStatus(rawValue: 0){
            self.showGroupProcessingMsg(message:"reading Friend status for Node :\" \(node.nodeName ?? "")\".")}
        
    }
    
    /* Refresh relay status */
    func refreshRelayStatus(node:STMeshNode){
        let result =  manager.getConfigurationModel().getConfigNodeRelay(node.unicastAddress)
        if result  == STMeshStatus(rawValue: 0){
            self.showGroupProcessingMsg(message:"reading Relay Status for Node :\" \(node.nodeName ?? "")\".")}
        
    }
    
    /* Set proxy feature*/
    func setGATTProxyFeature(node:STMeshNode, isOn:Bool)
    {
        let result =  manager.getConfigurationModel().setConfigNodeGATTProxy(node.unicastAddress, proxyState: isOn)
        if result  == STMeshStatus(rawValue: 0){
            self.showGroupProcessingMsg(message:"Updating Proxy feature for Node :\" \(node.nodeName ?? "")\".")
        }
        
    }
    /* Set relay feature */
    func setRelayFeature(node:STMeshNode, isOn:Bool)
    {
        let result = manager.getConfigurationModel().setConfigNodeRelay(node.unicastAddress, relay: isOn, retransmitCount:78, retransmitInterval: 9)
        if result  == STMeshStatus(rawValue: 0){
            self.showGroupProcessingMsg(message:"Updating Relay feature for Node :\" \(node.nodeName ?? "")\".")
        }
        
    }
    /* Set friend feature */
    func setFriendFeature(node:STMeshNode, isOn:Bool)
    {
        let result =  manager.getConfigurationModel().setConfigNodeFriend(node.unicastAddress, friendState:isOn)
        if result  == STMeshStatus(rawValue: 0){
            self.showGroupProcessingMsg(message:"Updateing Friend feature for Node :\" \(node.nodeName ?? "")\".")
        }
        
    }
    
    /* Remove subscription */
    private func removeSubscriber(element:STMeshElement,removeSubscriberList:[STMeshGroup]){
        
        self.showGroupProcessingMsg(message:"group \"\(removeSubscriberList[0].groupName!)\" is being removed from Node :\" \(selectedElement?.elementName ?? "")\".")
        
        /* Remove node from network */
        self.manager.getConfigurationModel().deleteConfigModelSubscription(fromNode: element.parentNode.unicastAddress, elementAddress:element.unicastAddress , group:removeSubscriberList[0].groupAddress, modelIdentifier: 0, isVendorModelId: false )
        
    }
    
    func removeNode(node:STMeshNode){
        nodeToBeDelete = node
        self.showGroupProcessingMsg(message:"Node: \"\(node.nodeName!)\"is being removed from network")
        manager?.getConfigurationModel().resetConfigNode(node.unicastAddress)
    }
    
    /* Methode used to check add selected group subscription done */
    func isGroupSubscriptionFinished()->Bool{
        if (currentConfigMode != nil && currentConfigMode == .ConfigMode_RemoveGroup){
            if (currentGroupIndex < removeGroup.count - 1){
                currentGroupIndex = currentGroupIndex + 1
                self.checkGroupAlreadyIsAdded(group: removeGroup[currentGroupIndex], isRemoveSubscription:true)
            }else{
                currentGroupIndex = 0
            }
            if (currentGroupIndex < addGroup.count) {
                self.checkGroupAlreadyIsAdded(group:addGroup[currentGroupIndex], isRemoveSubscription:false)
                return false
            }
        }
        else if ((currentConfigMode != nil && currentConfigMode == .ConfigMode_AddGroup)){
            /* Called for multiple group selected */
            if (currentGroupIndex < addGroup.count - 1){
                currentGroupIndex = currentGroupIndex + 1
                self.checkGroupAlreadyIsAdded(group:addGroup[currentGroupIndex], isRemoveSubscription:false)
                return false
            }else{
                return true
            }
        }
        return true
    }
    
    func saveGroupSubcriptionData(){
        
        /* Time-out is not implemented */
        /* Checking is add subscription */
        if (currentConfigMode != nil && currentConfigMode == .ConfigMode_AddGroup)  {
            if ((selectedElement?.modelList) != nil) && (selectedElement?.modelList.count)!  > 0 {
                (selectedElement?.modelList[0] as!STMeshModel ).subscribeList.add(addGroup[currentGroupIndex])
                selectedElement?.subscribedGroups.add(addGroup[currentGroupIndex])
                currentNetworkData.addElementToGroup(didAddNewNode:(selectedElement?.parentNode!)!, elementAddedToGroup:selectedElement! , didAddToGroup: addGroup[currentGroupIndex])
            }
        }
            /* Checking is remove subscription */
        else if (currentConfigMode != nil && currentConfigMode == .ConfigMode_RemoveGroup){
            if ((selectedElement?.modelList) != nil) && (selectedElement?.modelList.count)!  > 0 {
                selectedElement?.subscribedGroups.remove(removeGroup[currentGroupIndex])
                (selectedElement?.modelList[0] as!STMeshModel ).subscribeList.remove(removeGroup[currentGroupIndex])
                currentNetworkData.deleteElementFromGroup(nodeToDelete:(selectedElement?.parentNode!)!, elementToDelete:selectedElement! , deleteFromGroup: removeGroup[currentGroupIndex])
            }
        }
        currentNetworkData.saveNetworkConfigToStorage()
    }
    
    func savePublisher(){
        if publisher != nil {
            if let element = (publisher as? STMeshElement), currentConfigMode == .ConfigMode_AddPublish {
                currentNetworkData.addPublisherTargetToElement(publisher: element, node:(selectedElement?.parentNode)!, element:selectedElement!)
            }
            
            /* Checking is add  publisher */
            if let group = publisher as? STMeshGroup , currentConfigMode == .ConfigMode_AddPublish {
                currentNetworkData.addPublisherTargetToElement(publisher: group, node:(selectedElement?.parentNode)!, element:(selectedElement)!)
                currentNetworkData.addPublisherElementToGroup(publishNode:(selectedElement?.parentNode)!, group:group , element: selectedElement!)
            }
            
            /* Checking is remove publisher  and checking pusher adrress is group */
            if let element = (publisher as? STMeshElement), currentConfigMode == .ConfigMode_RemovePublish {
                currentNetworkData.removePublisherFromElement(publisher: element, node:(selectedElement?.parentNode)!, element:selectedElement!)
            }
            
            /* Checking is remove publisher  and checking publisher adrress is group */
            if let group = publisher as? STMeshGroup , currentConfigMode == .ConfigMode_RemovePublish {
                currentNetworkData.removePublisherFromElement(publisher: group, node:(selectedElement?.parentNode)!, element:selectedElement!)
            }
            currentNetworkData.saveNetworkConfigToStorage()
        }
    }
    
    func showGroupProcessingMsg(message:String) {
        
        if alertController == nil{
            let attributedString = NSAttributedString(string: "Processing", attributes: [
                (kCTFontAttributeName as NSAttributedStringKey ): UIFont.systemFont(ofSize: 20),
                NSAttributedStringKey.foregroundColor as NSAttributedStringKey : UIColor.hexStringToUIColor(hex: "#228B22")
                ])
            alertController = UIAlertController(title: "" , message: message, preferredStyle: UIAlertControllerStyle.alert)
            alertController?.setValue(attributedString, forKey: "attributedTitle")
            alertController.view.alpha = 1.0
            if self.delegate != nil{
                (self.delegate  as! UIViewController).present(alertController!, animated: false, completion: nil)
            }
        }
        alertController?.message = message
    }
    
    /* This func checking Element already subscribed on particular group */
    func checkGroupAlreadyIsAdded(group:STMeshGroup, isRemoveSubscription:Bool){
        var groupIsAdded = false
        for elementGroup in (selectedElement?.subscribedGroups)!{
            if (elementGroup as? STMeshGroup)?.groupAddress == group.groupAddress{
                groupIsAdded = true
            }
        }
        if groupIsAdded == true && !isRemoveSubscription{
            /* Group is Already added to node nothing to do */
            _ = self.isGroupSubscriptionFinished()
        }
        else if groupIsAdded == false && !isRemoveSubscription{
            /* New group added on Node */
            currentConfigMode  = .ConfigMode_AddGroup
            self.manager?.getConfigurationModel().addConfigModelSubscription(toNode:(selectedElement?.parentNode.unicastAddress)!, elementAddress: (selectedElement?.unicastAddress)!, address: group.groupAddress, modelIdentifier: 0, isVendorModelId: false)
            self.showGroupProcessingMsg(message:"group \"\(group.groupName!)\" is being assigned to Node :\" \(selectedElement?.elementName ?? "")\".")
        }
        else if groupIsAdded == true && isRemoveSubscription{
            /* Group is Already added to node need to remove group from node */
            currentConfigMode  = .ConfigMode_RemoveGroup
            self.manager.getConfigurationModel().deleteConfigModelSubscription(fromNode: (selectedElement?.parentNode?.unicastAddress)!, elementAddress:(selectedElement?.unicastAddress)! , group:group.groupAddress, modelIdentifier: 0, isVendorModelId: false)
            self.showGroupProcessingMsg(message:"group \"\(group.groupName!)\" is being removed from Node :\" \(selectedElement?.elementName ?? "")\".")
        }else{
            _ = self.isGroupSubscriptionFinished()
        }
    }
  }
  
  extension ConfigModelManager:STMeshConfigModelDelegate{
    
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveAppKeyStatus configurationStatus: ConfigModelStatus, peerAddress: UInt16, netKeyIndex: UInt16, appkeyIndex appKeyIndex: UInt16) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        if configurationStatus == ConfigModelStatus.init(rawValue: 0) {
            delegate.didAppKeyAssignmentSuccessfullyCompleted(completed:true, message:"")
            
        }else{
            let message = configurationStatus == ConfigModelStatus.init(rawValue: 0xFF) ? "Appkey assignment operation timeout " : "Appkey assignment operation failed"
            delegate.didAppKeyAssignmentSuccessfullyCompleted(completed:false, message:message)
        }
    }
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveSubscriptionStatus configurationStatus: ConfigModelStatus, peerAddress: UInt16, elementAddress elementAdrress: UInt16, modelIdentifier: UInt32) {
        
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        if configurationStatus == ConfigModelStatus.init(rawValue: 0)  {
            saveGroupSubcriptionData()
            
            if self.isGroupSubscriptionFinished(){
                delegate.didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: true)
            }else{
                
            }
        }else{
            let message = configurationStatus == ConfigModelStatus.init(rawValue: 0xFF) ?"Group subscription operation timeout ":"Group subscription operation failed"
            CommonUtils.showAlertWith(title:AppTitle, message:message, presentedOnViewController: delegate as? UIViewController)
            delegate.didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: false)
        }
        
    }
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceivePublishStatus configurationStatus: ConfigModelStatus, peerAddress: UInt16, elementAddress: UInt16, publishAddress: UInt16, appKeyIndex: UInt16, credentialFlag: Bool, publishTTL: UInt8, publishPeriod: UInt32, retransmitCount count: UInt8, retransmitInterval interval: UInt16, modelIdentifier: UInt32) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        if configurationStatus == ConfigModelStatus.init(rawValue: 0){
            self.savePublisher()
            delegate.didAdd_RemovePublisherSuccessfullyCompleted(completed:true)
        }else{
            let message = configurationStatus == ConfigModelStatus.init(rawValue: 0xFF) ? "publisher assignment operation timeout " :"Publisher assignment operation failed"
            CommonUtils.showAlertWith(title:AppTitle, message:message, presentedOnViewController: delegate as? UIViewController)
            delegate.didAdd_RemovePublisherSuccessfullyCompleted(completed:false)
        }
    }
    
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveFriendStatus peerAddress: UInt16, friendStatus friendState: ConfigState) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        delegate?.didFreiendStatusReceived(status:friendState, address: peerAddress)
        
    }
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveConfigNodeIdentityStatus peerAddress: UInt16, indentity: ConfigState) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        
    }
    
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveProxyStatus peerAddress: UInt16, proxy proxyState: ConfigState) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        delegate.didProxyStatusReceived(status:proxyState, address: peerAddress)
    }
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveResetStatus configurationStatus: STMeshStatus, peerAddress: UInt16) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        
        currentNetworkData.removeNodeFromNetworks(node:nodeToBeDelete!)
        delegate?.didRemoveNodeSuccessfullyCompleted(completed: true)
    }
    
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveConfigRelayStatus peerAddress: UInt16, relay: ConfigState, retransmitCount count: UInt8, retransmitInterval interval: UInt16) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
        delegate.didRelayStatusReceived(status:relay, address:peerAddress)
        
    }
    
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didGroupRemoveFromNetwork Status: STMeshStatus, groupAddress: UInt16) {
        if alertController != nil{
            alertController.dismiss(animated:false, completion: nil)
            alertController =  nil
        }
    }
    
    func meshConfigModel(_ configModel: STMeshConfigurationModel!, didReceiveCompositionData configurationStatus: STMeshStatus, peerAddress: UInt16, pageNumber: UInt8, receivedData data: STMeshCompositionDataModel) {
        if configurationStatus == STMeshStatus.init(rawValue: 0){
            for node in currentNetworkData.currentNetworkData.nodes{
                
                STCustomEventLogClass.sharedInstance.STEvent_CompositionPageCompanyIdentifier(companyIdentifier: data.cid)
                
                if (node as! STMeshNode).unicastAddress == peerAddress{
                    if ((node as! STMeshNode).elementList.object(at:0) as! STMeshElement).modelList.count > 0{
                    }else{
                        currentNetworkData.fillCompostionDataToNode(peerAddresss: peerAddress, compostionData: data)
                        delegate?.didReceivedCompostionData(completed: configurationStatus.rawValue == UInt32(ConfigModelStatus.init(rawValue: 0).rawValue) ? true : false)
                    }
                }
            }
            delegate?.didReceivedCompostionData(completed:true)
        }else{
            delegate?.didReceivedCompostionData(completed:false)
        }
    }
    
  }
  extension ConfigModelManager :STMeshManagerDelegate{
    func meshManager(_ manager: STMeshManager!, didProxyConnectionChanged isConnected: Bool) {
        
    }
  }
  
  
