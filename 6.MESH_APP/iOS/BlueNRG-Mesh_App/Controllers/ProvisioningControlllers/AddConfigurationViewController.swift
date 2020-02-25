/**
 ******************************************************************************
 * @file    AddConfigurationViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    28-Nov-2017
 * @brief   ViewController for "Add Group Pop-up" View.
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

enum ConfigMode:Int{
    case ConfigMode_AddAppKey = 0
    case ConfigMode_AddGroup
    case ConfigMode_RemoveGroup
    case ConfigMode_AddPublish
    case ConfigMode_RemovePublish
}

protocol  AddGroupPopUpViewDelegate{
    func startProvision(flag: Bool, group:STMeshGroup)
}

import UIKit
import Darwin

class AddConfigurationViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var configBtn: UIButton!
    @IBOutlet var groupTableView: UITableView!
    var isCommingFromAllElementClickedButton : Bool = false
    
    @IBOutlet weak var notableToreadCompositionLbl: UILabel!
    var elementIndexInNodeElementArray : Int!
    var flagValue = 0
    var expendedSection = 0
    var manager:STMeshManager?
    var connectionTimer:Timer?
    var defaultSelectedGroup = 1
    var currentConfigMode:ConfigMode?
    var nodeBeingAdded: STMeshNode?
    var isChangeConfig = false
    var publisherArray:[AnyObject] = []
    var alertController:UIAlertController!
    var selectedPublisherIndex:IndexPath?
    var groupSelected:[String:Bool] = [:]
    var delegate : AddGroupPopUpViewDelegate? = nil
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var selectedGroupIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    var configManager = ConfigModelManager()
    var isAddConfigButtonclicked = false
    
    //MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Configuration"
        configBtn.setTitle(isChangeConfig ? "Change Configuration" : "Add Configuration" , for: .normal)
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!userDefault.bool(forKey: KConstantProxyConnectionNodeIdentityModeKey)){
            let elementRelateToNodeAtIndex = nodeBeingAdded?.elementList[elementIndexInNodeElementArray] as! STMeshElement
            manager?.startNetwork(elementRelateToNodeAtIndex.configComplete == true ? 0 : (nodeBeingAdded?.unicastAddress)!)
        }
        else { // false
            manager?.startNetwork(0)
        }
        if ( !isChangeConfig && !(nodeBeingAdded?.configComplete)! || !(manager?.isConnectedToProxyService())!){
            connectionTimer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(self.updateCnnection), userInfo: nil, repeats: false)
            CommonTostAlrt.sharedInstance.showAlertTostMessage(title:"Connecting", message: "Waiting for proxy connection! ", controller:self)
        }
        self.groupTableView!.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       if configManager.alertController != nil {
            alertController.dismiss(animated:true, completion:nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPublisherArray()
        manager = STMeshManager.getInstance(self)
        configManager.initialSetup(currrentNewworkData:self.currentNetworkDataManager, delegate:self)
        checkselectedGroup()
        setValueToGroupDict()
    }
    
    func intialSetUpForConfigElement() -> Void {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewGroupSegue"{
            let destinationVC = segue.destination as! AddGroupViewController
            destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
        }
    }
    
    // MARK: Selectors
    @objc func updateCnnection(){
        if (manager?.isConnectedToProxyService())!{
            connectionTimer?.invalidate()
            connectionTimer = nil
            CommonTostAlrt.sharedInstance.hideAlertTostMessage()
            _ = configManager.readCompostionData(element: nodeBeingAdded?.elementList[0] as! STMeshElement)
        }
        if connectionTimer != nil{
            connectionTimer?.invalidate()
            CommonTostAlrt.sharedInstance.hideAlertTostMessage()
            showErrorAlert(message: "Error in proxy connection, configure this node later!")
        }
    }
    
    func startConfigration(){
        let elementRelatedToNodeInIndex = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
        if  nodeBeingAdded?.configComplete == false {
            STCustomEventLogClass.sharedInstance.STEvent_ConfigurationTimeStartEvent()
            configManager.addAppKey(node:nodeBeingAdded!)
        }
        else if (isChangeConfig) || (elementRelatedToNodeInIndex.subscribedGroups.count == 0 && elementRelatedToNodeInIndex.publishTarget == nil){
            self.assignGroupsAfterAsigningAppKeyToNode()
        }
        else {
            if currentConfigMode == ConfigMode.ConfigMode_AddGroup || isCommingFromAllElementClickedButton {
                self.assignGroupsAfterAsigningAppKeyToNode()
            }
            else if (currentConfigMode != ConfigMode.ConfigMode_AddGroup || currentConfigMode != ConfigMode.ConfigMode_RemoveGroup) && selectedPublisherIndex != nil {
                self.assignPublisherToElement(indexPath: selectedPublisherIndex!)
            }
        }
        
        
    }
    
    @IBAction func startProvisioningButton(_ sender: Any) {
        isAddConfigButtonclicked = true
        notableToreadCompositionLbl.isHidden = true
        if  manager?.isConnectedToProxyService() == true{
            if  configManager.readCompostionData(element: nodeBeingAdded?.elementList[0] as! STMeshElement) == false
            {
                self.startConfigration()
            }
        }
        else{
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (finished) in
            })
        }
    }
    
    func assignGroupsAfterAsigningAppKeyToNode() -> Void {
        if let groups = (self.currentNetworkDataManager.currentNetworkData.groups as? [STMeshGroup]), groups.count > 0 {
            if self.isChangeConfig{
                self.checkGroupIsAdded(groupsArray:groups)
            }else{
                let group = groups[self.selectedGroupIndexPath.row + 1]
                let element = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
                configManager.addSubscriber(element:element, addSubcriberList:[group], removeSubcriberList:nil)
            }
        }
    }
    
    // MARK: Custom methods
    
    /* Check mark in check box for already subscribed group in element */
    func setValueToGroupDict(){
        if isChangeConfig && (self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement).subscribedGroups != nil{
            
            for i in 0..<currentNetworkDataManager.currentNetworkData.groups.count{
                var addedToNode = false
                let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
                for a in 0..<((self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement).subscribedGroups.count){
                    let elementGroup = (self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement).subscribedGroups[a] as! STMeshGroup
                    if(group.groupAddress == elementGroup.groupAddress){
                        addedToNode = true
                    }
                }
                let groupAddress = String(format:"%i",group.groupAddress)
                groupSelected[groupAddress] = addedToNode
            }
        }
    }
    
    func geNumberOfRowInSection(section:Int) -> Int {
        switch section {
        case 0:
            return currentNetworkDataManager.currentNetworkData.groups.count - 1
        default:
            return  publisherArray.count
        }
    }
    
    func showErrorAlert(message:String) {
        CommonUtils.showAlertWithOptionMessage(message:message, continueBtnTitle:"Retry", cancelBtnTitle:"Cancel", controller:self) { (response) in
            STCustomEventLogClass.sharedInstance.STEvent_ConfigurationTimeStartEvent()
            self.configManager.addAppKey(node:self.nodeBeingAdded!)
        }
    }
    
    func processForPublisherAssignment(){
        if selectedPublisherIndex != nil{
            assignPublisherToElement(indexPath: selectedPublisherIndex!)
        }else{
            self.navigationController?.popViewController(animated:true)
        }
    }
    
    func getPublisherArray(){
        let elementRelatedToNodeInIndex = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
        publisherArray  = []
        
        for i in 1..<currentNetworkDataManager.currentNetworkData.groups.count{
            
            let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
            if  isChangeConfig  == true, elementRelatedToNodeInIndex.publishTarget != nil, let publisherTarget =  elementRelatedToNodeInIndex.publishTarget as? STMeshGroup , group == publisherTarget{
                selectedPublisherIndex  = IndexPath(row:publisherArray.count, section:1)
            }
            publisherArray.append(group)
        }
        for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
            
            let node = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
            for i in 0..<(node.elementList).count{
                let element = node.elementList[i] as? STMeshElement
                if  isChangeConfig == true , elementRelatedToNodeInIndex.publishTarget != nil, let publisherTarget =  elementRelatedToNodeInIndex.publishTarget as? STMeshElement , element == publisherTarget{
                    selectedPublisherIndex  = IndexPath(row:publisherArray.count, section:1)
                }
                publisherArray.append(element!)
            }
        }

     
        for i in 0..<currentNetworkDataManager.currentNetworkData.onlyProvisionerArray.count {
            
            let node = currentNetworkDataManager.currentNetworkData.onlyProvisionerArray[i] as! STMeshNode
            for i in 0..<(node.elementList).count{
                let element = node.elementList[i] as? STMeshElement
                if  isChangeConfig == true , elementRelatedToNodeInIndex.publishTarget != nil, let publisherTarget =  elementRelatedToNodeInIndex.publishTarget as? STMeshElement , element == publisherTarget{
                    selectedPublisherIndex  = IndexPath(row:publisherArray.count, section:1)
                }
                publisherArray.append(element!)
            }
        }
    }
    
    /* Selection */
    func checkselectedGroup(){
        let elementRelatedToNodeInIndex = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
        if ((nodeBeingAdded?.subscribedGroups != nil) && ((nodeBeingAdded?.subscribedGroups.count)! > 0)){
            for i in 0..<currentNetworkDataManager.currentNetworkData.groups.count{
                
                if (((currentNetworkDataManager.currentNetworkData.groups[i]) as! STMeshGroup).groupAddress == (elementRelatedToNodeInIndex.subscribedGroups[0] as! STMeshGroup).groupAddress){
                    self.selectedGroupIndexPath = IndexPath(row:i - 1, section: 0)
                }
            }
        }
        groupTableView.reloadData()
    }
    func checkGroupIsAdded(groupsArray:[STMeshGroup]){
        var addSubscription = [STMeshGroup]()
        var removeSubscription = [STMeshGroup]()
        let element = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
        if !isChangeConfig
        {
            addSubscription.append(groupsArray[selectedGroupIndexPath.row + 1])
        }else{
            for group in groupsArray{
                let groupAddress = String(format:"%i",(group.groupAddress))
                
                if let isAdded = groupSelected[groupAddress]{
                    var groupIsAdded = false
                    for elementGroup in (element.subscribedGroups)!{
                        if (elementGroup as? STMeshGroup)?.groupAddress == group.groupAddress{
                            groupIsAdded = true
                        }
                    }
                    if groupIsAdded == false && isAdded == true{
                        /* new group added on Node */
                        addSubscription.append(group)
                    }
                    else if groupIsAdded == true && isAdded == false{
                        removeSubscription.append(group)
                    }else{
                    }
                }
            }
        }
        if addSubscription.count > 0 || removeSubscription.count > 0{
            configManager.addSubscriber(element:element, addSubcriberList:addSubscription, removeSubcriberList:removeSubscription)
        } else if selectedPublisherIndex != nil {
            let element = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
            configManager.addPublisher(element:element, publisher: publisherArray[(selectedPublisherIndex?.row)!])
        }
    }
    
    func assignPublisherToElement(indexPath:IndexPath)
    {
        let element = self.nodeBeingAdded?.elementList[self.elementIndexInNodeElementArray] as! STMeshElement
        configManager.addPublisher(element:element, publisher: publisherArray[indexPath.row])
    }
    
    // MARK: This Method will be called when User Clicked All Element Config Button
    func reCallAllProcessForAllElement() -> Void {
        for elementIndex in 0..<nodeBeingAdded!.elementList.count{
            let  element = nodeBeingAdded?.elementList[elementIndex] as! STMeshElement
            if (element.modelList.count > 0 && element.subscribedGroups.count == 0){
                /* Element is not yet configured */
                self.elementIndexInNodeElementArray = elementIndex
                self.startProvisioningButton(elementIndex)
                break
            }
            else{
                if (nodeBeingAdded?.elementList.count == elementIndex + 1){
                    /* Pass the control to root view controller */
                    if (STCustomEventLogClass.sharedInstance.timeStarted != 0){
                        STCustomEventLogClass.sharedInstance.STEvent_ConfigurationTimeTakenEvent()
                    }
                    CommonUtils.showAlertTostMessage(title: "", message: "All elements are configured successfully", controller: self, success: { (comleted) in
                        self.tabBarController?.selectedIndex = 1
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }
        }
    }
}

extension AddConfigurationViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return   geNumberOfRowInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addNewGroupCell", for: indexPath) as! ConfigurationTableViewCell
        cell.setButtonImage(isRedio:isChangeConfig && indexPath.section == 0 ? false : true)
        if indexPath.section == 0 {
            
            let group = currentNetworkDataManager.currentNetworkData.groups[indexPath.row + 1] as! STMeshGroup
            cell.groupName.text = group.groupName
            if isChangeConfig {
                
                // selecting check box button
                let groupAddress = String(format:"%i",group.groupAddress)
                cell.radioButton.isSelected =  groupSelected[groupAddress] != nil ? groupSelected[groupAddress]! : false
            }else{
                // selecting radio button
                cell.radioButton.isSelected = selectedGroupIndexPath.row == indexPath.row ? true :false
            }
        }
        else{
            cell.radioButton.isSelected = ((selectedPublisherIndex != nil) && (selectedPublisherIndex?.row == indexPath.row)) ? true : false
            
            if let element =  publisherArray[indexPath.row] as? STMeshElement{
                cell.groupName.text =  (((element.parentNode)?.nodeName) ?? "") + "/"  + element.elementName
                
            }
            if  let group = publisherArray[indexPath.row] as? STMeshGroup {
                cell.groupName.text =  group.groupName
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier:"HeaderTableCell") as! HeaderTableCell
        cell.expendebleButton.tag = section
        cell.updateArrowData(isExpended:expendedSection == section ? true:false)
        switch section {
        case 0:
            cell.titleNameLbl.text = "Group Subscription"
        case 1:
            cell.titleNameLbl.text = "Publish Target"
        default:
            cell.titleNameLbl.text = ""
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // De-selecting previous node if fist time configuring
        switch indexPath.section {
        case 0:
            if  indexPath.section == 0,  let cell = tableView.cellForRow(at:selectedGroupIndexPath) as? ConfigurationTableViewCell {
                cell.radioButton.isSelected = isChangeConfig ? cell.radioButton.isSelected :false
            }
        default:
            if selectedPublisherIndex != nil, selectedPublisherIndex != indexPath, let cell = tableView.cellForRow(at:selectedPublisherIndex!) as? ConfigurationTableViewCell {
                cell.radioButton.isSelected = false
            }
        }
        // storing selected node index
        if indexPath.section == 0 {
            if isChangeConfig {
                
                let group = currentNetworkDataManager.currentNetworkData.groups[indexPath.row + 1] as! STMeshGroup
                let groupAddress = String(format:"%i",group.groupAddress)
                groupSelected[groupAddress] =   groupSelected[groupAddress] != nil ? !groupSelected[groupAddress]! : false
            }else{
                selectedGroupIndexPath = indexPath
            }
        }
        if let cell = tableView.cellForRow(at:indexPath) as? ConfigurationTableViewCell {
            cell.radioButton.isSelected =  (indexPath.section == 0 && !isChangeConfig) ? true : !cell.radioButton.isSelected
            if indexPath.section == 1{
                selectedPublisherIndex = (cell.radioButton.isSelected && indexPath.section == 1) ? indexPath :nil
            }
        }
    }
}

extension AddConfigurationViewController:STMeshManagerDelegate {
    
    func meshManager(_ manager: STMeshManager!, didProxyConnectionChanged isConnected: Bool) {
        if connectionTimer != nil{
            connectionTimer?.invalidate()
        }
        _ = configManager.readCompostionData(element: nodeBeingAdded?.elementList[0] as! STMeshElement)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            CommonTostAlrt.sharedInstance.hideAlertTostMessage()
        }
    }
}

extension AddConfigurationViewController :ConfigManagerDelegate{
    
    func didReceivedCompostionData(completed:Bool){
        if isAddConfigButtonclicked {
            self.notableToreadCompositionLbl.isHidden = completed
            if completed{
                isAddConfigButtonclicked = false
                self.startConfigration()
            }
        }
    }
    
    func didRemoveNodeSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didAppKeyAssignmentSuccessfullyCompleted(completed: Bool, message:String) {
        if completed{
            nodeBeingAdded?.configComplete = true
            currentNetworkDataManager.saveNetworkConfigToStorage()
            self.checkGroupIsAdded(groupsArray:currentNetworkDataManager.currentNetworkData.groups as! [STMeshGroup])
        }else{
            showErrorAlert(message:message)
        }
    }
    
    func didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: Bool) {
        if completed{
            if selectedPublisherIndex != nil{
                processForPublisherAssignment()
            }
            else{
                /* If coming from all element config button then will check for other element to get proceed further */
                if (isCommingFromAllElementClickedButton) {
                    self.reCallAllProcessForAllElement()
                }
                else{
                    /* if single element is processed then will go the same element screen */
                    var isAnyOtherElementleftToGetConfig : Bool = false
                    for i in 0..<nodeBeingAdded!.elementList.count {
                        let element = nodeBeingAdded?.elementList[i] as! STMeshElement
                        if (element.subscribedGroups.count == 0)
                        {
                            isAnyOtherElementleftToGetConfig = true
                        }
                    }
                    if (isAnyOtherElementleftToGetConfig) {
                        navigationController?.popViewController(animated: true)
                    }
                        /* if it was the last element to get completed then will go to the root view controller. */
                    else{
                        self.tabBarController?.selectedIndex = 1
                        self.navigationController?.popToRootViewController(animated:true)
                    }
                }
            }
        }else{
            currentConfigMode = ConfigMode.ConfigMode_AddGroup
        }
    }
    
    func didAdd_RemovePublisherSuccessfullyCompleted(completed: Bool) {
        if completed{
            /* Checking if all element button is configured */
            if (isCommingFromAllElementClickedButton) {
                // then will proceed to next element
                self.reCallAllProcessForAllElement()
            }
            else{
                /* If each element config is pressed then will go the same element list screen for the next element */
                var isAnyOtherElementleftToGetConfig : Bool = false
                for i in 0..<nodeBeingAdded!.elementList.count {
                    let element = nodeBeingAdded?.elementList[i] as! STMeshElement
                    if (element.subscribedGroups.count == 0)
                    {
                        isAnyOtherElementleftToGetConfig = true
                    }
                }
                /* Anyone still left unconfig the will go the element list view controller */
                if (isAnyOtherElementleftToGetConfig) {
                    navigationController?.popViewController(animated: true)
                }
                else{
                    /* else will go to the root view controller */
                    self.tabBarController?.selectedIndex = 1
                    self.navigationController?.popToRootViewController(animated:true)
                }
            }
        }else{
            currentConfigMode = ConfigMode.ConfigMode_AddPublish
        }
    }
}

class HeaderTableCell:UITableViewCell {
    
    @IBOutlet var titleNameLbl: UILabel!
    @IBOutlet var arrowImage: UIImageView!
    @IBOutlet var expendebleButton: UIButton! {
        didSet{
            arrowImage.image =  expendebleButton.isSelected ? UIImage(named:"upperArrow") :  UIImage(named:"lowerArrow")
        }
    }
    
    func updateArrowData(isExpended: Bool) {
        arrowImage.image =  isExpended ? UIImage(named:"lowerArrow") :  UIImage(named:"lowerArrow")
    }
    
    override func awakeFromNib() {
    }
}

