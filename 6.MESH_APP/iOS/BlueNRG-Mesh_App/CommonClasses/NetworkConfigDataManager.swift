/**
 ******************************************************************************
 * @file    NetworkConfigDataManager.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.02.000
 * @date    20-Nov-2017
 * @brief   Class to store the Mesh network settings
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

let defaultGroupName = "Default"
let defaultGroupAddress = "C000"
let allNodeGroupName = "All Nodes"
let allNodeGroupAddress = "FFFF"

class NetworkConfigDataManager {
    
    var currentNetworkData = STMeshNetworkSettings()
    // MARK: Shared Instance
    static var sharedInstance: NetworkConfigDataManager = {
        let instance = NetworkConfigDataManager()
        
        return instance
    }()
    
    var meshNetworkName : String?
    
    /* Singleton */
    private init() { }
    class func destroyCurrentNetwork() -> Void {
        sharedInstance.currentNetworkData = STMeshNetworkSettings()
        UserDefaults.standard.removeObject(forKey:STMesh_NetworkSettings_Key )
    }
    
    
    func retrieveNetworkConfigFromStorage() -> Void {
        /* Load the already stored values from UserDefaults to nodes array */
        let settingString = UserDefaults.standard.object(forKey: STMesh_NetworkSettings_Key) as? String
        
        if(settingString != nil) {
            
            let settingJSON = JSON.init(parseJSON: settingString!)
            print("JSON Values in saving method",settingJSON)
            populateNetworkConfigModelFromJson(settingJSON:settingJSON,currentNetworkDataModel: currentNetworkData)
        }
        else {
            SetDefaultNetworkConfig()
        }
    }
    
    func SetDefaultNetworkConfig()
    {
        /* New network */
        currentNetworkData = STMeshNetworkSettings.initAsNewNetwork()
        /* Create "All Nodes" Group at first run */
        let firstGroup = STMeshGroup()
        firstGroup.groupName = allNodeGroupName

        firstGroup.groupAddress = UInt16(Int(allNodeGroupAddress, radix: 16)!)
        currentNetworkData.groups.add(firstGroup)
        /* Create "Default Group" typically at first run. */
        let defaultGroup = STMeshGroup()
        defaultGroup.groupAddress = UInt16(Int(defaultGroupAddress, radix: 16)!)
        defaultGroup.groupName = defaultGroupName
        currentNetworkData.groups.add(defaultGroup)
        currentNetworkData.iVindex = 1
        currentNetworkData.meshName = meshNetworkName
        
    }
    
    func populateNetworkConfigModelFromJson(settingJSON:JSON, currentNetworkDataModel:STMeshNetworkSettings){
        currentNetworkDataModel.reinitNetworkDataList()
        
        if let _ = settingJSON[STMesh_IVIndex_Key].int32{
            currentNetworkDataModel.iVindex = settingJSON[STMesh_IVIndex_Key].uInt32!
        }
        
        if let netkey = settingJSON[STMesh_NetKey_Key].arrayObject{
            for netkeyJson in netkey{
                if let netkeyJson = netkeyJson as? [String:Any] , let key  = netkeyJson[STMesh_key] as? String{
                    currentNetworkDataModel.netKey = key
                }
            }
        }
        if let appkey = settingJSON[STMesh_AppKey_Key].arrayObject{
            for appkeyJson in appkey{
                if let appkeyJson = appkeyJson as? [String:Any] , let key  = appkeyJson[STMesh_key] as? String{
                    currentNetworkDataModel.appKey = key
                }
            }
        }
        
        currentNetworkDataModel.meshName = settingJSON[STMesh_MeshName_Key].string
        if let meshNetworkUUId = settingJSON[STMesh_MeshUUID_Key].string
        {
            currentNetworkDataModel.meshUUID = meshNetworkUUId
        }
        
        /* Adding  provisioner values in the data model from the json template */
        
        /* Provisioner Section */
        if let provisionerJson = settingJSON[STMesh_ProvisionerDataCollection_Key].arrayObject as? [[String:Any]]{
            populateProvisionerFromNetworkConfigDataJson(provisionerJson:provisionerJson, currentNetworksDataModel:currentNetworkDataModel)
        }
        var nodesJSON = settingJSON[STMesh_NodeCollection_Key]
        let nodeCount = nodesJSON.count
        
        var groupsJSON = settingJSON[STMesh_GroupCollection_Key]
        for nodeIndex in 0..<groupsJSON.count {
            let myGroup = STMeshGroup()
            myGroup.groupName = groupsJSON[nodeIndex][STMesh_GroupName_Key].string ?? ""
            if let group  =  groupsJSON[nodeIndex][STMesh_GroupAddress_Key].string{

                if let hexGroupAddress = UInt16(group, radix: 16){
                    myGroup.groupAddress  = hexGroupAddress
                }
            }
            currentNetworkDataModel.groups.add(myGroup)
        }

        let subscribeGroup  =  currentNetworkData.groups.filter{ (group) -> Bool in
            String((group as! STMeshGroup).groupAddress, radix: 16).uppercased() == allNodeGroupAddress
        }
        if subscribeGroup.count == 0{
            let firstGroup = STMeshGroup()
            firstGroup.groupName = allNodeGroupName
            firstGroup.groupAddress = UInt16(Int(allNodeGroupAddress, radix: 16)!)
            currentNetworkDataModel.groups.insert(firstGroup, at:0)
        }
        
        for nodeIndex in 0..<nodeCount {
            self.populateNetworkConfigNodesData(node: nodesJSON[nodeIndex])
        }
        
        /* Assigning publish and Subscribe to groups */
        for group in  currentNetworkDataModel.groups{
            
            if let nodeInGroup =  self.getElementsSubscribedTo(groupAddress:((group as? STMeshGroup)?.groupAddress)!, netWorksSetting:currentNetworkData) , nodeInGroup.count > 0 {
                
                /* Adding subscriber node of group */
                (group as! STMeshGroup).subscribersElem = NSMutableArray(array: nodeInGroup)
            }
            if  let publishNode  = self.isGroupAddedAsPublishTarget(groupAddress:((group as? STMeshGroup)?.groupAddress)!, netWorksSetting:currentNetworkData) , publishNode.count > 0 {
                /* Adding publish node of group */
            }
        }
        
        for node in currentNetworkDataModel.nodes{
            for element in ((node as? STMeshNode)?.elementList)!{
                if let publisher = (element as! STMeshElement).publishTarget as? STMeshElement{
                    
                    /* checking publisher of element is it selft that element */
                    if publisher.unicastAddress == (element as! STMeshElement).unicastAddress{
                        (element as! STMeshElement).publishTarget = element
                    }else{
                        /* checking publisher of element is it other element */
                        for elmNode in currentNetworkData.nodes{
                            for elemList in (elmNode as! STMeshNode).elementList
                            {
                                if publisher.unicastAddress == (elemList as! STMeshElement).unicastAddress{
                                    (element as! STMeshElement).publishTarget = elemList
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func populateProvisionerFromNetworkConfigDataJson(provisionerJson:[[String:Any]], currentNetworksDataModel:STMeshNetworkSettings){
        
        for provisioner in provisionerJson {
            let provisionerObject = STMeshProvisionerData()
            
            if let name  = provisioner[STMesh_ProvisionerName_Key] as? String {
                provisionerObject.provisionerName = name
            }
            if let UUID  = provisioner[STMesh_ProvisionerUUID_Key] as? String {
                provisionerObject.provisionerUUID = UUID
            }
            
          
            if let unicastAddressArrary  = provisioner[STMesh_ProvisionerUnicastAddressRange_Key] as? [[String :Any]] {
                let provisionerRangeInstance = self.populateProvisionerAddressRangeFromCurrentNetworkData(addressRangeJson:unicastAddressArrary)
                provisionerObject.marrProvisionerAllocatedUnicastRange.add(provisionerRangeInstance)
            }
            
            if let groupAddressArray  = provisioner[STMesh_ProvisionerGroupAdressRange_Key] as? [[String:Any]] {
                let provisionerRangeInstance = self.populateProvisionerAddressRangeFromCurrentNetworkData(addressRangeJson:groupAddressArray)
                provisionerObject.marrProvisionerAllocatedGroupRange.add(provisionerRangeInstance)
            }
            currentNetworksDataModel.provisionerDataArray.add(provisionerObject)
        }
    }
    
    func populateProvisionerAddressRangeFromCurrentNetworkData(addressRangeJson:[[String:Any]]) -> ProvisioningRangeObjects{
        for unicastArray in addressRangeJson{
            if let lowAddress = unicastArray[STMesh_Provisioner_AddressLowRange_Key] as? String, let highAddress = unicastArray[STMesh_Provisioner_AddressHighRange_Key] as? String,
                let provisionerRangeInstance = ProvisioningRangeObjects.init(rangeObjectsWithMinValue:lowAddress , maxValue: highAddress)
            {
                return provisionerRangeInstance
            }
        }
        return ProvisioningRangeObjects()
    }
    
    func populateNetworkConfigNodesData(node : JSON) -> Void {
        
        let myNode = STMeshNode()
        if let name  = node[STMesh_NodeName_Key].string {
            myNode.nodeName = name
        }
        if  myNode.nodeName == "" ,  let name  = node[STMesh_NodeName_Key.lowercased()].string {
            myNode.nodeName = name
        }
        if let uuid =   node[STMesh_NodeUUID_Key].string{
            myNode.nodeUUID  = uuid
        }
        if let  configComplete = node[STMesh_ConfigComplete_Key].bool{
            myNode.configComplete = configComplete
        }
        if let deviceKey  = node[STMesh_DeviceKey_Key].string{
            myNode.deviceKey = deviceKey
        }
        if let blackList = node[STMesh_Blacklisted_Key].bool{
            myNode.blacklisted = blackList
        }
        if let features = node[STMesh_NodeFeatures_key].dictionary{
            myNode.features = STMeshNodeFeatures()
            if  let relay = features[STMesh_NodeFeaturesRelay_key]?.uInt8{
                myNode.features.relay = relay
            }
            if  let proxy = features[STMesh_NodeFeaturesProxy_key]?.uInt8 {
                myNode.features.proxy = proxy
            }
            if  let friend = features[STMesh_NodeFeaturesFriend_key]?.uInt8 {
                myNode.features.friendFeature = friend
            }
            if  let lowPower = features[STMesh_NodeFeaturesLowPower_key]?.uInt8 {
                myNode.features.lowPower = lowPower
            }
            
        }
        //
        if  let cid = node[STMesh_NodeCid_Key].string{
            myNode.cid = cid
        }
        if  let pid = node[STMesh_NodePid_Key].string {
            myNode.pid = pid
        }
        if  let vid = node[STMesh_NodeVid_Key].string {
            myNode.vid  = vid
        }
        if  let crpl = node[STMesh_NodeCrpl_Key].string {
            myNode.crpl = crpl
        }
        
        if let elementsJsonArray = node[STMesh_ElementCollection_Key].arrayObject as? [[String:Any]]{
            for (index , elementsJson ) in elementsJsonArray.enumerated(){
                
                let element : STMeshElement = STMeshElement()
                
                if let modelArrayJson  = elementsJson[STMesh_ModelsCollection_Key] as? [[String:Any]] , let elementUnicastAddress = elementsJson[STMesh_ElemementUnicastAddress_Key] as? String{
                    if (index == 0)
                    {
                        myNode.unicastAddress = UInt16(elementUnicastAddress, radix: 16)!
                    }
                    element.unicastAddress = UInt16(elementUnicastAddress, radix: 16)!
                    if let elementName = elementsJson[STMesh_ElementName_Key] as? String{
                        element.elementName = elementName
                        
                    }
                    if  element.elementName == "" , let elementName = elementsJson[STMesh_ElementName_Key.lowercased()] as? String{
                        element.elementName = elementName
                        
                    }
                    
                    element.parentNode = myNode
                    for (modelIndex , model ) in modelArrayJson.enumerated(){
                        let modelObj : STMeshModel = STMeshModel()
                        if let modelID = model[STMesh_ModelId_Key]  as? String{
                            modelObj.modelId = UInt32(modelID, radix: 16)!
                            modelObj.modelName = CommonModel.GetModelName(modelId: modelObj.modelId)
                        }
                        
                        if let subscribeList = model[STMesh_SubscribeCollection_Key] as? [String]{
                            for subscribeId in subscribeList{
                                
                                let subscribeGroup  =  currentNetworkData.groups.filter{ (group) -> Bool in
                                    String((group as! STMeshGroup).groupAddress, radix: 16).uppercased() == subscribeId.uppercased()
                                }
                                if let groupSub =  subscribeGroup as? [STMeshGroup]{
                                    for group in groupSub{
                                        if (modelIndex == 0){
                                            element.subscribedGroups.add(group)
                                            
                                        }
                                        modelObj.subscribeList.add(group)
                                        
                                    }
                                }
                            }
                        }
                        if  let publish = model[STMesh_Model_Publish_Key] as? [String :Any], let _ = model[STMesh_ModelId_Key] as? String{
                            if let publishAddress = publish[STMesh_Publish_Address_key] as? String{
                                if publishAddress.uppercased() >= defaultGroupAddress {
                                    // This is group Address
                                    let publishGroup  =  currentNetworkData.groups.filter{ (group) -> Bool in
                                        String((group as! STMeshGroup).groupAddress, radix: 16).uppercased()  == publishAddress.uppercased()
                                    }
                                    if publishGroup.count > 0{
                                        if (modelIndex == 0){
                                            element.publishTarget = publishGroup.first
                                        }
                                        modelObj.publish = publishGroup.first
                                    }
                                }else{
                                    let publishElement = STMeshElement()
                                    publishElement.unicastAddress = UInt16(publishAddress, radix: 16)!
                                    if (modelIndex == 0){
                                        element.publishTarget = publishElement
                                    }
                                    modelObj.publish = publishElement
                                }
                            }
                        }
                        element.modelList.add(modelObj)
                        
                        //                                }
                    }// if index check ends here
                    myNode.elementList.add(element)
                }
            }
            
            var isProvisionerNode = false
            
            for objProvisionerData in currentNetworkData.provisionerDataArray as! [STMeshProvisionerData]{
                if (node[STMesh_NodeUUID_Key].string!.caseInsensitiveCompare(objProvisionerData.provisionerUUID) == .orderedSame ){
                    isProvisionerNode = true
                }
                
            }
            if (isProvisionerNode == true){
                currentNetworkData.onlyProvisionerArray.add(myNode)
                print("Only provisioner list ", currentNetworkData.onlyProvisionerArray)
            }
            else
            {
                let nodeMesh = myNode as STMeshNode
                currentNetworkData.nodes.add(nodeMesh)
                print("Only node list without provisioner", currentNetworkData.onlyProvisionerArray)
            }
        }
        
    }
    
    /* Called for searching group address used subscribe in node */
    func getElementsSubscribedTo(groupAddress : UInt16, netWorksSetting:STMeshNetworkSettings) -> [STMeshElement]? {
        var  nodeArray = [STMeshElement]()
//        _ =   netWorksSetting.nodes.map { (node) -> [Any]? in
//            if node.count > 0{
                for node in netWorksSetting.nodes{
                    for element in (node as? STMeshNode)!.elementList{
                    
                    _ = (element as! STMeshElement ).modelList.map { (model) -> [Any]? in
                            
                            let subscribeGroup =   (model.firstObject as? STMeshModel)?.subscribeList.filter{ (subscribeGroup) -> Bool in
                                return (subscribeGroup as! STMeshGroup).groupAddress == groupAddress
                            }
                            
                            if (((subscribeGroup as? [STMeshGroup]) != nil) && (subscribeGroup?.count)! > 0 ){
                                nodeArray.append((element as! STMeshElement))
                            }
                            return nil
                        }
                    }
       }
        return nodeArray
    }
    
    /* Called for checking group address as publish address to Node */
    func isGroupAddedAsPublishTarget(groupAddress : UInt16,netWorksSetting:STMeshNetworkSettings) -> [STMeshElement]?{
        
        var  elementArray = [STMeshElement]()
        _ =  netWorksSetting.nodes.filter { (node) -> Bool in
            let elementList = (node as? STMeshNode)?.elementList.filter({ (element) -> Bool in
                let modelList = (element as? STMeshElement)?.modelList.filter({ (model) -> Bool in
                    if let publisherTarget = (model as! STMeshModel).publish as? STMeshGroup {
                        print(publisherTarget.groupAddress)
                        return publisherTarget.groupAddress  == groupAddress
                    }
                    return false
                })
                return  modelList!.count > 0 ? true :false
            })
            if let elmArr = elementList as? [STMeshElement]{
                elementArray = elementArray + elmArr
            }
            return elementList!.count > 0 ?true :false
        }
        return elementArray
    }
    
    func saveNetworkConfigToStorage() -> Void {
        let json = generateJsonFromNetworkConfigModel()
        print("JSON Values in saving method",json)
        UserDefaults.standard.set(json.rawString(), forKey: STMesh_NetworkSettings_Key)
    }
    
    func generateJsonFromNetworkConfigModel() -> JSON{
        var networkSettingsForJson = Dictionary<String, Any>()
        var nodeArrayForJson = Array<Any>()
        let nodeProvisionerArrayForJSON = Array<Any>()
        var groupsArrayForJson = Array<Any>()
        let nodes = currentNetworkData.nodes!
        let provisionerOnly = currentNetworkData.onlyProvisionerArray
        let groups = currentNetworkData.groups!
        for i in 0..<currentNetworkData.nodes.count {
            
            let nodeData = nodes[i] as! STMeshNode
            nodeArrayForJson.append(self.writeNodeDataInJson(node: nodeData))
        }
        for i in 0..<currentNetworkData.onlyProvisionerArray.count {
            
            let nodeData = provisionerOnly![i] as! STMeshNode
            nodeArrayForJson.append(self.writeNodeDataInJson(node: nodeData))
        }
        
        for i in 0..<currentNetworkData.groups.count{
            let currGroupForJson = [STMesh_GroupName_Key:(groups[i] as! STMeshGroup).groupName,
                                    STMesh_GroupAddress_Key: String((groups[i] as! STMeshGroup).groupAddress, radix: 16).uppercased()
                ] as [String : Any]
            groupsArrayForJson.append(currGroupForJson);
        }
        networkSettingsForJson["$schema"] = "mesh.jsonschema"
        networkSettingsForJson[STMesh_IVIndex_Key] = currentNetworkData.iVindex
        var netKeyCollectionArray = Array<[String:Any]>()
        for _ in 0..<1{
            let netKeyJson = [STMesh_AppKey_Index_Key:0, STMesh_key:currentNetworkData.netKey ?? ""] as [String :Any]
            netKeyCollectionArray.append(netKeyJson)
        }
        networkSettingsForJson[STMesh_NetKey_Key] = netKeyCollectionArray
        
        var appKeyCollectionArray = Array<[String:Any]>()
        for _ in 0..<1{
            
            let appKeyJson = [STMesh_AppKey_Index_Key:0,STMesh_AppKey_BoundNetKey_Key:0,STMesh_key:currentNetworkData.appKey ?? ""] as [String : Any]
            appKeyCollectionArray.append(appKeyJson)
        }
        networkSettingsForJson[STMesh_AppKey_Key] = appKeyCollectionArray
        networkSettingsForJson[STMesh_GroupCollection_Key] = groupsArrayForJson
        networkSettingsForJson[STMesh_NodeCollection_Key] = nodeArrayForJson
        networkSettingsForJson[STMesh_ProvisionerDataCollection_Key] = nodeProvisionerArrayForJSON
        
        networkSettingsForJson[STMesh_MeshUUID_Key] = currentNetworkData.meshUUID
        networkSettingsForJson[STMesh_MeshName_Key] = currentNetworkData.meshName
        
        /* addding provisioner to the array in the JSON */
        var provisionerArrayForJson = Array<Any>()
        let provisionerArrayCount = currentNetworkData.provisionerDataArray.count
        
        
        for provisionerIndex in 0..<provisionerArrayCount{
            let provisionerArrayObject = currentNetworkData.provisionerDataArray[provisionerIndex] as! STMeshProvisionerData
            let unicastAllocatedAddressArray = provisionerArrayObject.marrProvisionerAllocatedUnicastRange
            let groupAllocatedAddressArray = provisionerArrayObject.marrProvisionerAllocatedGroupRange
            
            let currProvisionerForJson = [STMesh_ProvisionerName_Key:provisionerArrayObject.provisionerName,
                                          STMesh_ProvisionerUUID_Key:provisionerArrayObject.provisionerUUID,
                                          STMesh_ProvisionerUnicastAddressRange_Key:unicastAllocatedAddressArray as Any,
                                          STMesh_ProvisionerGroupAdressRange_Key: groupAllocatedAddressArray as Any]  as [String : Any]
            
            provisionerArrayForJson.append(currProvisionerForJson)
        }
        networkSettingsForJson[STMesh_ProvisionerDataCollection_Key] = provisionerArrayForJson
        return JSON(networkSettingsForJson)
    }
    func writeNodeDataInJson(node : STMeshNode) -> [String: Any] {
        
        
        var elementInNodeArray = Array<[String:Any]>()
        for elm in node.elementList{
            var modelInElementArray = Array<[String:Any]>()
            let element  = elm as! STMeshElement
            for model in element.modelList{
                let modelObj  = model as! STMeshModel
                var subscriberOfElemArray = Array<String>()
                for i in 0..<(modelObj).subscribeList.count{
                    let groupAdress = String(((modelObj ).subscribeList[i] as! STMeshGroup).groupAddress, radix: 16).uppercased()
                    subscriberOfElemArray.append(groupAdress)
                }
                
                //Currently single model implementation
                // for  m in 0..<((element ).modelList.count){
                var modelJson = [STMesh_ModelId_Key:String(modelObj.modelId, radix: 16).uppercased() ,STMesh_SubscribeCollection_Key:subscriberOfElemArray, ] as [String : Any]
                
                if modelObj.publish != nil{
                    var publisherJson:[String:Any] = [:]
                    if let publisher   = modelObj.publish as? STMeshElement{
                        publisherJson = [STMesh_Publish_Address_key:String(publisher.unicastAddress, radix: 16).uppercased()]
                    }else if let publisher   = modelObj.publish as? STMeshGroup{
                        publisherJson = [STMesh_ModelPublish_Key:String(publisher.groupAddress, radix: 16).uppercased()]
                    }
                    modelJson[STMesh_Model_Publish_Key] =  publisherJson
                }
                modelInElementArray.append(modelJson)
                //  }
            }
            
            let currNodeElementJson :[String:Any] = [STMesh_Element_Index_key:0,STMesh_ElemementUnicastAddress_Key: String(element.unicastAddress, radix: 16).uppercased(),STMesh_ModelsCollection_Key:modelInElementArray , STMesh_ElementName_Key:element.elementName] // element Name is an optional in json schema.
            
            elementInNodeArray.append(currNodeElementJson)
        }
        
        var currNodeForJson = [STMesh_NodeName_Key:node.nodeName,
                               STMesh_NodeUUID_Key:node.nodeUUID,//This not part of official json schema
            STMesh_DeviceKey_Key:node.deviceKey,
            STMesh_ConfigComplete_Key:node.configComplete,
            STMesh_PublishAddress_Key:node.publishAddress,
            STMesh_Blacklisted_Key:node.blacklisted,
            STMesh_ElementCollection_Key:elementInNodeArray] as [String : Any]
        
        if node.cid != nil{
            currNodeForJson[STMesh_NodeCid_Key] = node.cid;
        }
        if node.pid != nil{
            currNodeForJson[STMesh_NodePid_Key] = node.pid;
        }
        if node.vid != nil{
            currNodeForJson[STMesh_NodeVid_Key] = node.vid
        }
        
        if node.crpl != nil{
            currNodeForJson[STMesh_NodeCrpl_Key] = node.crpl
        }
        
        if node.features != nil{
            var nodeFeaturesJson = [String:Any]()
            nodeFeaturesJson[STMesh_NodeFeaturesRelay_key] = node.features.relay
            nodeFeaturesJson[STMesh_NodeFeaturesProxy_key] = node.features.proxy
            nodeFeaturesJson[STMesh_NodeFeaturesFriend_key] = node.features.friendFeature
            nodeFeaturesJson[STMesh_NodeFeaturesLowPower_key] = node.features.lowPower
            currNodeForJson[STMesh_NodeFeatures_key]  = nodeFeaturesJson
        }
        
        return currNodeForJson
    }
    
    func addNode(didAddNewNode: STMeshNode) -> Void{
        currentNetworkData.nodes.add(didAddNewNode)
    }
    
    func addPublisherTargetToNode(publisher:AnyObject, node:STMeshNode) -> Void
    {
        node.publishTarget = publisher
        for currentNode in currentNetworkData.nodes {
            if (currentNode as! STMeshNode).nodeUUID == node.nodeUUID{
                (currentNode as! STMeshNode).publishTarget = publisher
            }
        }
        saveNetworkConfigToStorage()
    }
    
    func addPublisherTargetToElement(publisher:AnyObject, node:STMeshNode , element:STMeshElement) -> Void
    {
        for  i in 0..<currentNetworkData.nodes.count{
            let node = currentNetworkData.nodes[i] as! STMeshNode
            
            for j in 0..<node.elementList.count{
                let elementInNode = node.elementList[j] as! STMeshElement
                if (elementInNode.unicastAddress == element.unicastAddress){
                    elementInNode.publishTarget = publisher
                    for k in 0..<elementInNode.modelList.count
                    {
                        let Model = elementInNode.modelList[k] as! STMeshModel
                        Model.publish = publisher
                    }
                }
            }
        }
        saveNetworkConfigToStorage()
    }
    
    func fillCompostionDataToNode(peerAddresss:UInt16,compostionData:STMeshCompositionDataModel){
        for  i in 0..<currentNetworkData.nodes.count{
            let node = currentNetworkData.nodes[i] as! STMeshNode
            if node.unicastAddress == peerAddresss{
                node.features = STMeshNodeFeatures()
                node.features.friendFeature = compostionData.isFriendFeature ? 1:0
                node.features.relay = compostionData.isRelayFeature ? 1:0
                node.features.proxy = compostionData.isProxyFeature ? 1:0
                node.features.lowPower = compostionData.isLowPowerFeature ? 1:0
                node.cid = compostionData.cid != 0  ? NSString(format:"%i",compostionData.cid) as String :"";
                node.vid = compostionData.vid != 0  ? NSString(format:"%i",compostionData.vid) as String :"";
                node.pid = compostionData.pid != 0  ? NSString(format:"%i",compostionData.pid) as String :"";
                node.crpl = compostionData.crpl != 0  ? NSString(format:"%i",compostionData.crpl) as String :"";
                
                let elementListCount = node.elementList.count < compostionData.elementList.count ? compostionData.elementList.count : node.elementList.count
                
                for i in 0..<elementListCount{
                    let element = node.elementList[i] as! STMeshElement
                    if compostionData.elementList.count > i {
                        if let compostionElement = compostionData.elementList.object(at:i) as? ElementField , let _ = compostionElement.sigModels
                        {
                            for sig in compostionElement.sigModels {
                                let model = STMeshModel()
                                if ((sig as? UInt32) != nil){
                                    model.modelId = sig as! UInt32
                                    element.modelList.add(model)
                                    model.modelName = CommonModel.GetModelName(modelId: model.modelId)
                                }
                            }
                        }
                        
                        if let compostionElement = compostionData.elementList.object(at:i) as? ElementField , let vendor = compostionElement.vendorModels {
                            let model = STMeshModel()
                            if ((vendor.object(at:0) as? UInt32) != nil){
                                model.modelId = UInt32(vendor.object(at:0) as! UInt32)
                                //  UInt16(vendor.object(at:0), radix: 16)
                                model.modelName = CommonModel.GetModelName(modelId: model.modelId)
                                element.modelList.add(model)
                            }
                        }
                    }
                }
                saveNetworkConfigToStorage()
            }
        }
        saveNetworkConfigToStorage()
    }
    
    func removePublisherFromElement(publisher:AnyObject, node:STMeshNode , element:STMeshElement){
        for  i in 0..<currentNetworkData.nodes.count{
            let node = currentNetworkData.nodes[i] as! STMeshNode
            
            for j in 0..<node.elementList.count{
                let elementInNode = node.elementList[j] as! STMeshElement
                if (elementInNode.unicastAddress == element.unicastAddress){
                    elementInNode.publishTarget = nil
                    for k in 0..<elementInNode.modelList.count
                    {
                        let Model = elementInNode.modelList[k] as! STMeshModel
                        Model.publish = nil
                    }
                }
            }
        }
        saveNetworkConfigToStorage()
    }
    
    func removeGroupFromNetwork(group:STMeshGroup){
        currentNetworkData.groups.remove(group)
        saveNetworkConfigToStorage()
    }
    
    func addPublisherElementToGroup(publishNode:STMeshNode,group:STMeshGroup , element: STMeshElement){
        
        for i in 0..<currentNetworkData.groups.count{
            let currentGroup = currentNetworkData.groups[i] as! STMeshGroup
            if(currentGroup.groupAddress == group.groupAddress){
            }
        }
    }
    
    func addGroup(didAddNewGroup: STMeshGroup) -> Void{
        
        for i in 0..<currentNetworkData.groups.count{
            let group = currentNetworkData.groups[i] as! STMeshGroup
            if(group.groupAddress == didAddNewGroup.groupAddress) {
                return
            }
        }
        currentNetworkData.groups.add(didAddNewGroup)
    }
    
    func addGroupToElementForNode(didAddNewGroup: STMeshGroup, elementAddedNewGroup: STMeshElement,didAddToNode: STMeshNode) -> Void{
        
        for i in 0..<currentNetworkData.nodes.count{
            let node = currentNetworkData.nodes[i] as! STMeshNode
            if(node.nodeUUID == didAddToNode.nodeUUID)
            {
                for e in 0..<node.elementList.count
                {
                    var isAlreadyInSubscriberList = false
                    let element = node.elementList[e] as! STMeshElement
                    if(element.unicastAddress == elementAddedNewGroup.unicastAddress){
                        for m in 0..<element.modelList.count
                        {
                            isAlreadyInSubscriberList = false
                            let elementModel = element.modelList[m] as! STMeshModel
                            let elementGroupArray = elementModel.subscribeList as NSMutableArray
                            
                            for eG in 0..<elementGroupArray.count{
                                let elementGroup = elementModel.subscribeList[eG] as! String
                                if(elementGroup == String(format:"",didAddNewGroup.groupAddress)){
                                    isAlreadyInSubscriberList = true
                                    return ;
                                }
                            }
                            if !isAlreadyInSubscriberList{
                                elementModel.subscribeList.add(didAddNewGroup)
                            }
                        }
                        if !isAlreadyInSubscriberList{
                            element.subscribedGroups.add(didAddNewGroup)
                        }
                    }
                }
            }
        }
    }
    
    func addElementToGroup(didAddNewNode: STMeshNode,elementAddedToGroup : STMeshElement, didAddToGroup: STMeshGroup) -> Void{
        
        for i in 0..<currentNetworkData.groups.count{
            let group = currentNetworkData.groups[i] as! STMeshGroup
            var iselementAlreadyAddedInGroup : Bool = false
            if(group.groupAddress == didAddToGroup.groupAddress){
                for a in 0..<group.subscribersElem.count{
                    let element = group.subscribersElem[a] as! STMeshElement
                    if (elementAddedToGroup.unicastAddress == element.unicastAddress){
                        iselementAlreadyAddedInGroup = true
                        return
                    }
                }
                if !iselementAlreadyAddedInGroup{
                    group.subscribersElem.add(elementAddedToGroup)
                }
            }
        }
    }
    
    
    func removeNodeFromNetworks(node:STMeshNode){
        for i in 0..<currentNetworkData.groups.count{
            let group = currentNetworkData.groups[i] as! STMeshGroup
            for a in 0..<group.subscribersElem.count{
                let element = group.subscribersElem[a] as! STMeshElement
                if(element.parentNode.nodeUUID == node.nodeUUID){
                    group.subscribersElem.removeObject(at: a)
                    break;
                }
            }
        }
        currentNetworkData.nodes.remove(node)
        self.saveNetworkConfigToStorage()
    }
    
    func deleteElementFromGroup(nodeToDelete: STMeshNode, elementToDelete:STMeshElement ,deleteFromGroup: STMeshGroup) -> Void{
        
        deleteFromGroup.subscribersElem.remove(nodeToDelete)
        for i in 0..<currentNetworkData.groups.count{
            let group = currentNetworkData.groups[i] as! STMeshGroup
            
            if(group.groupAddress == deleteFromGroup.groupAddress){
                group.subscribersElem.remove(elementToDelete)
            }
        }
    }
}

