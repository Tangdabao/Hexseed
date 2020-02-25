/**
 ******************************************************************************
 * @file    GroupSettingsPopupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    02-Nov-2017
 * @brief   ViewController for "Group Settings" View.
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

protocol GroupSettingsPopupDelegate {
    func isMemberAdded(group: STMeshGroup, node: STMeshElement, didAdd: Bool , isPublisher:Bool)
}

class GroupSettingsPopupViewController: UIViewController{
    
    var alertController:UIAlertController!
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var group: STMeshGroup!
    var didAddMember: Bool!
    var manager:STMeshManager?
    var selectedElement:STMeshElement?
    var currentConfig:ConfigMode?
    /* To store the value of command whether member is added or not */
    var isAddPublish = false
    @IBOutlet var membersTableView: UITableView!
    weak var groupSettingVC: GroupSettingsViewController!
    var nonGroupMembers = [STMeshElement]()
    var delegate : GroupSettingsPopupDelegate? = nil
    var configManager = ConfigModelManager()
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = STMeshManager.getInstance(self as STMeshManagerDelegate)
        self.membersTableView.isHidden = false
        if isAddPublish{
            getNonAddedPublisher()
        }else{
            getNonAddedNodeOnGroup()
        }
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.membersTableView.isHidden = false
            self.membersTableView!.reloadData()
        }
        configManager.initialSetup(currrentNewworkData:self.currentNetworkDataManager, delegate:self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: custom methods
    func initialSetup(){
        self.membersTableView.center = (self.membersTableView.superview?.center)!;
        if CGFloat((nonGroupMembers.count * 40) + 10) <= ( screenHeight - membersTableView.frame.origin.y)
        {
            membersTableView.frame.size.height = CGFloat((nonGroupMembers.count * 40) + 10)
        }else{
            membersTableView.frame.size.height = ( screenHeight - membersTableView.frame.origin.y)
        }
        membersTableView.layer.cornerRadius = 20
        membersTableView.layer.masksToBounds = true
    }
    
    func getNonAddedNodeOnGroup(){
        for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
            
            let node = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
            for ele in node.elementList{
                var flag = 0
                for a in 0..<group.subscribersElem.count{
                    if((ele as! STMeshElement).unicastAddress == (group.subscribersElem[a] as! STMeshElement).unicastAddress){
                        flag = 1;
                        break;
                    }
                }
                if(flag == 0){
                    nonGroupMembers.append(ele as! STMeshElement )
                }
            }
        }
    }
    
    func getNonAddedPublisher(){
        for publisherNode in currentNetworkDataManager.currentNetworkData.nodes{
            let publish = (publisherNode as! STMeshNode).elementList.filter { (element) -> Bool in
                print((element as! STMeshElement).unicastAddress)
                let publishArray = (element as! STMeshElement).modelList.filter { (model) -> Bool in
                    
                    if  (model as? STMeshModel)?.publish != nil , let group =  (model as? STMeshModel)?.publish as? STMeshGroup , group.groupAddress == self.group.groupAddress {
                        return false
                    }
                    return true
                }
                return publishArray.count > 0 ? true :false
            }
            if let publisher =  publish as? [STMeshElement] {
                nonGroupMembers = nonGroupMembers + publisher
            }
            
        }
    }
}//class end

extension GroupSettingsPopupViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  nonGroupMembers.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsPopUpCell", for: indexPath) as! GroupSettingsPopupTableViewCell
        cell.nodeName.text =  nonGroupMembers[indexPath.row].parentNode.nodeName + " / "  + nonGroupMembers[indexPath.row].elementName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        membersTableView.isHidden = true
        selectedElement = nonGroupMembers[indexPath.row]
        if !self.isAddPublish{
            
            if ((selectedElement?.subscribedGroups.count)! >= MaximumSubscribersOfNode){
                CommonUtils.showAlertWith(title:AppTitle, message: "Selected node has reached its maximum subscription limit.", presentedOnViewController: self)
            }
            else{
                configManager.addSubscriber(element: selectedElement!, addSubcriberList: [group], removeSubcriberList: nil)
            }
        }
        else{
            if self.selectedElement?.publishTarget != nil{
                self.showAlert()
            }else{
                addPublisher()
            }
        }
    }
    
    func addPublisher(){
        configManager.addPublisher(element:selectedElement!, publisher:group)
    }
    
    func showAlert(){
        CommonUtils.showAlertWithOptionMessage(message: "This node already has a publisher do you want to change it?.", continueBtnTitle: "Continue" , cancelBtnTitle: "Cancel", controller: self) { (response) in
            self.addPublisher()
        }
    }
}

extension GroupSettingsPopupViewController : STMeshManagerDelegate{
}

extension GroupSettingsPopupViewController : ConfigManagerDelegate{
    func didRemoveNodeSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didAppKeyAssignmentSuccessfullyCompleted(completed: Bool, message: String) {
    }
    
    func didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: Bool) {
        
        addPublishToDataBase(completed:completed)
    }
    
    func didAdd_RemovePublisherSuccessfullyCompleted(completed: Bool) {
        addPublishToDataBase(completed:completed)
    }
    
    func addPublishToDataBase(completed:Bool){
        self.didAddMember = completed
        self.dismiss(animated: true, completion: nil)
        self.delegate?.isMemberAdded(group: self.group, node: selectedElement!, didAdd: self.didAddMember, isPublisher:self.isAddPublish)
        self.groupSettingVC.viewWillAppear(true)
        self.groupSettingVC.viewDidAppear(true)
    }
}
