/**
 ******************************************************************************
 * @file    GroupSettingsViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.02.000
 * @date    02-Nov-2017
 * @brief   ViewController for "Group Settings" View.s
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
import  Foundation

protocol GroupSettingsDelegate {
    func updateGroupName(groupUpdated: STMeshGroup, newName: String) -> Bool
    func updateSwitchStatus(groupUpdated: STMeshGroup, status: Bool)
}

class GroupSettingsViewController: UIViewController{
    
    @IBOutlet var memberTableViewHeight: NSLayoutConstraint!
    @IBOutlet var removeGroupButton: UIButton!
    @IBOutlet var groupAddressLbl: UILabel!
    @IBOutlet var changedGroupName: UITextField!
    @IBOutlet var groupMembersView: UITableView!
    var alertController:UIAlertController!
    @IBOutlet var groupName: UILabel!
    
    var group: STMeshGroup!
    var delegate : GroupSettingsDelegate? = nil
    var manager:STMeshManager!
    var groupPublish:[STMeshElement] = [STMeshElement]()
    var publishersArray:[AnyObject] = [STMeshElement]()
    var currentConfig:ConfigMode?
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var configManager = ConfigModelManager()
    
    // MARK:Life cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        getGroupPublishList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager = STMeshManager.getInstance(self as STMeshManagerDelegate)
        self.tabBarController?.tabBar.isHidden = true
        removeGroupButton.isHidden = group.groupAddress == 49152 ? true : false
        getPublishAddress()
        self.reloadPage()
        configManager.initialSetup(currrentNewworkData:self.currentNetworkDataManager, delegate:self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadPage(){
        self.groupMembersView.reloadData()
        memberTableViewHeight.constant = groupMembersView.contentSize.height <= (screenHeight - (groupMembersView.frame.origin.x  + 60)) ? groupMembersView.contentSize.height : (screenHeight - (groupMembersView.frame.origin.x  + 60))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupSettingsPopupSegue" {
            
            let destinationVC = segue.destination as! GroupSettingsPopupViewController
            destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
            destinationVC.group = self.group
            destinationVC.delegate = self
            if let button  = sender as? UIButton
            {
                destinationVC.isAddPublish = button.tag == 0 ? false : true
            }
            destinationVC.groupSettingVC = self
            return
        }
    }
    
    func getMaxSubscriberCount() ->Int{
        var count = 0
        for node in currentNetworkDataManager.currentNetworkData.nodes{
            count =  count + ((node as? STMeshNode)?.elementList.count)!
        }
        return count
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.manager.isConnectedToProxyService() {
            if let button  = sender as? UIButton{
                if identifier == "groupSettingsPopupSegue" {
                    if  (self.group.subscribersElem.count == getMaxSubscriberCount()) && button.tag == 0{
                        return false
                    }
                    else if(self.publishersArray.count == 0) && button.tag == 1{
                        self.showErrorMessage()
                        return false
                    }
                }
            }
            return true
        }else{
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (response) in
            })
            return false
        }
    }
    
    // MARK: Custom function
    func initialSetup(){
        
        manager = STMeshManager.getInstance(self as STMeshManagerDelegate)
        self.groupMembersView.delegate = self
        self.groupMembersView.dataSource = self
        self.changedGroupName.text = group.groupName
        self.groupAddressLbl.text = String(group.groupAddress, radix: 16).uppercased();
        //back button
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.title = "Group Settings"
        //CHANGE:
        self.groupMembersView.sectionHeaderHeight = 50
    }
    
    func getGroupPublishList(){
        if let publishList = currentNetworkDataManager.isGroupAddedAsPublishTarget(groupAddress:group.groupAddress, netWorksSetting:currentNetworkDataManager.currentNetworkData), publishList.count > 0{
            groupPublish =  publishList
        }else{
            groupPublish =  [STMeshElement]()
        }
    }
    
    func getPublishAddress(){
        for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
            let tempNode = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
            if let publisher = tempNode.publishTarget as? STMeshGroup,publisher.groupAddress == group.groupAddress {
                
            }else{
                publishersArray.append(tempNode.nodeName as AnyObject)
            }
        }
    }
    
    func showErrorMessage(){
        CommonUtils.showAlertWith(title: AppTitle, message:"No new node available to add.", presentedOnViewController:self)
    }
    
    func getNonGroupMembers() -> [STMeshNode]{
        
        var nonGroupMembers = [STMeshNode]()
        for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
            var flag = 0
            let node = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
            for a in 0..<group.subscribersElem.count{
                if(node.nodeUUID == (group.subscribersElem[a] as AnyObject).nodeUUID){
                    flag = 1;
                    break;
                }
            }
            if(flag == 0){
                nonGroupMembers.append(node)
            }
        }
        return nonGroupMembers
    }
    
    // MARK: selectors
    @IBAction func editButtonAction(_ sender: UIButton) {
        changedGroupName.isUserInteractionEnabled = true
        changedGroupName.becomeFirstResponder()
    }
    
    @IBAction func removeGroupButtonAction(_ sender: UIButton) {
        if group.subscribersElem.count == 0 && groupPublish.count == 0{
            configManager.showGroupProcessingMsg(message:"group :\"\(group.groupName!)\" is being removed from Network.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.currentNetworkDataManager.removeGroupFromNetwork(group:self.group)
                if self.configManager.alertController != nil{
                    self.configManager.alertController.dismiss(animated:true, completion:nil)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            CommonUtils.showAlertWith(title:AppTitle, message:"group can't be deleted. Remove all subscribers and publish target from the group.", presentedOnViewController:self)
        }
    }
    
}//class end


extension GroupSettingsViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = group.subscribersElem.count
        }
        if section == 1 {
            rowCount = groupPublish.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupMembersCell", for: indexPath) as! GroupMembersTableViewCell
        cell.indexPath =  indexPath
        cell.controller = self
        cell.delegate = self
        switch (indexPath.section) {
        case 0:
            let groupMember = group.subscribersElem[indexPath.row] as! STMeshElement
            cell.memberName.text = groupMember.parentNode.nodeName + " / "  + groupMember.elementName
            cell.memberToDelete = groupMember
        case 1:
            cell.memberToDelete = groupPublish[indexPath.row]
            cell.memberName.text = groupPublish[indexPath.row].parentNode.nodeName + " / "  + groupPublish[indexPath.row].elementName
            
        default:
            print()
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! GroupMembersHeaderTableViewCell
        header.addSubscriber.tag = section
        if section == 0{
            header.headerTitle.text = "Subscribers:"
        }
        else{
            header.headerTitle.text = "Publishers:"
        }
        return header
    }
}


extension GroupSettingsViewController: GroupMemberDeleteProtocol{
    
    func deleteMember(yes: Bool, member: STMeshElement, indexPath: IndexPath) {
        configManager.initialSetup(currrentNewworkData:currentNetworkDataManager, delegate:self)
        if yes == true , indexPath.section == 0{
            
            configManager.addSubscriber(element:member, addSubcriberList:nil, removeSubcriberList:[group])
        }else if  yes == true , indexPath.section == 1{
            configManager.removePublisher(element: member, publisher: group)
        }
        self.groupMembersView!.reloadData()
    }
    
    func deleteMember(yes: Bool, member: STMeshNode) {
    }
}


extension GroupSettingsViewController: GroupSettingsPopupDelegate{
    func isMemberAdded(group: STMeshGroup, node: STMeshElement, didAdd: Bool, isPublisher: Bool) {
        if didAdd == true{
            if isPublisher == false{
                currentNetworkDataManager.addElementToGroup(didAddNewNode: node.parentNode, elementAddedToGroup: node, didAddToGroup: group)
                currentNetworkDataManager.addElementToGroup(didAddNewNode: node.parentNode, elementAddedToGroup: node, didAddToGroup: group)
            }else{
                currentNetworkDataManager.addPublisherTargetToElement(publisher: group, node: node.parentNode, element: node)
                getGroupPublishList()
            }
            currentNetworkDataManager.saveNetworkConfigToStorage()
        }
        self.groupMembersView!.reloadData()
        if didAdd == false{
            CommonUtils.showAlertWith(title: AppTitle, message:"Can't add this member to the group. \n Try Again!", presentedOnViewController: self)
        }
    }
}


extension GroupSettingsViewController :UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
            
            group?.groupName = textField.text
            textField.resignFirstResponder()
            for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
                
                let node = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
                for a in 0..<node.subscribedGroups.count{
                    
                    let nodeGroup = node.subscribedGroups[a] as! STMeshGroup
                    if(group.groupAddress == nodeGroup.groupAddress){
                        nodeGroup.groupName = textField.text
                        break;
                    }
                }
                if let nodePublisher = node.publishTarget as? STMeshGroup , nodePublisher.groupAddress == group.groupAddress{
                    nodePublisher.groupName = textField.text
                }
            }
            currentNetworkDataManager.saveNetworkConfigToStorage()
            return true
        }else{
            CommonUtils.showAlertWith(title:AppTitle, message:"Group name can't be empty!", presentedOnViewController: self)
            return false
        }
    }
}


extension GroupSettingsViewController :STMeshManagerDelegate{
    
}

extension GroupSettingsViewController :ConfigManagerDelegate{
    func didRemoveNodeSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didAppKeyAssignmentSuccessfullyCompleted(completed: Bool, message: String) {
    }
    
    func didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: Bool) {
        for allGroup in currentNetworkDataManager.currentNetworkData.groups{
            if (allGroup  as? STMeshGroup)?.groupAddress == group.groupAddress{
                group = (allGroup  as? STMeshGroup)
                break ;
            }
        }
        reloadPage()
    }
    
    func didAdd_RemovePublisherSuccessfullyCompleted(completed: Bool) {
        for allGroup in currentNetworkDataManager.currentNetworkData.groups{
            if (allGroup  as? STMeshGroup)?.groupAddress == group.groupAddress{
                group = (allGroup  as? STMeshGroup)
                break ;
            }
        }
        getGroupPublishList()
        self.reloadPage()
    }
}
