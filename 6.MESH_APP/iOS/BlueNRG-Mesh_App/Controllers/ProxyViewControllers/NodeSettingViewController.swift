/**
 ******************************************************************************
 * @file    SettingsViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.17.000
 * @date    17-Nov-2017
 * @brief   ViewController for "Node settings" View.
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

protocol SettingsDelegate {
    /* Force delete to delete a node when not in network coverage */
    func deleteNode(nodeToDelete: STMeshNode, forceDelete: Bool)->Bool
    func updateNodeName(nodeUpdated: STMeshNode, newName: String)->Bool
    func updateSwitchStatus(nodeUpdated: STMeshNode, status: Bool)->Bool
}
/* Main page -> click on settings icon -> SettingsViewController */
class NodeSettingViewController: UIViewController{
    
    
    @IBOutlet var viewNodeNameBar: UIView!
    
    @IBOutlet weak var viewProxyBar: UIView!
    @IBOutlet weak var viewRelayBar: UIView!
    @IBOutlet weak var viewFriendBar: UIView!
    @IBOutlet weak var viewLowPowerBar: UIView!
    
    @IBOutlet var viewNodeAddressBar: UIView!
    @IBOutlet var btnEditName: UIButton!
    @IBOutlet weak var btnRemoveNode: UIButton!
    @IBOutlet var changedName: UITextField!
    @IBOutlet var uuidLabel: UILabel!
    @IBOutlet var uuidValuesLbl: UILabel!
    @IBOutlet var name: UITextField!
    
    
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var settingsNode: STMeshNode? = nil
    var delegate : SettingsDelegate? = nil
    var lastSwitchState : Bool!
    var isProxyNodeConnectionEstablished : Bool = true
    
    // Element Changes
    var isComingFromElement : Bool!
    var elementSetting : STMeshElement!
    var ElementCell : ProvisionedElementsTableViewCell!
    var configManager = ConfigModelManager()
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Settings"
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    /* This is called when the back button is pressed */
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController:parent)
        if parent == nil {
            /* The back button was pressed or interactive gesture used */
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.setinItialData()
        configManager.initialSetup(currrentNewworkData:self.currentNetworkDataManager, delegate:self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "removeSegue" {
            let destinationVC = segue.destination as! RemovePopupViewController
            destinationVC.delegate = self
        }
        if segue.identifier == "addGroupSegue"{
            if (isProxyNodeConnectionEstablished){
                let destinationVC = segue.destination as! AddConfigurationViewController
                destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
                destinationVC.nodeBeingAdded = settingsNode
                destinationVC.isChangeConfig = true
            }
            else{
            }
        }
        if segue.identifier == "dropDownSegue"{
            let destinationVC = segue.destination as! PublishPopUpViewController
            destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
            destinationVC.currentNode = self.settingsNode
            destinationVC.delegate = self
        }
        
        if segue.identifier == "nodeFeatures"{
            let destinationVC = segue.destination as! NodeFeatureViewController
            destinationVC.node = self.settingsNode
        }
        
        if segue.identifier == "nodeInformation"{
            let destinationVC = segue.destination as! NodeInformationViewController
            destinationVC.nodeDetails = self.settingsNode
        }
    }
    
    // MARK: Selectors
    @IBAction func nodeNameEditingDidCancel(_ sender: Any) {
        if let myDelegate = self.delegate {
            /* Reset to old name */
            _ = myDelegate.updateNodeName(nodeUpdated: settingsNode!, newName: name.text!)
        }
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        self.changedName.isUserInteractionEnabled = true
        changedName.becomeFirstResponder()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        CommonUtils.showAlertTostMessage(title: "", message: "Current node does not support this feature", controller: self) { (finished) in
            
        }
    }
    
    @IBAction func nodeNameEditingDidEnd(_ sender: Any) {
        if let myDelegate = self.delegate {
            if(!myDelegate.updateNodeName(nodeUpdated: settingsNode!, newName: changedName.text!)) {
                //Revert the name change, if not allowed by data model.
                changedName.text = name.text
            }
        }
    }
    
    @IBAction func btnHealthModelClicked(_ sender: Any) {

    }
    
    @IBAction func btnHeartbeatModelClicked(_ sender: Any) {
         
    }
    
    @IBAction func changeConfigClicked(_ sender: Any) {
        
        if (isProxyNodeConnectionEstablished){
            self.performSegue(withIdentifier: "addGroupSegue", sender: nil)
        }
        else{
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (response) in
            })
        }
    }
    
    @IBAction func removeNodeClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "removeSegue", sender: nil)
    }
    
    // MARK:Custom Method
    func setinItialData()
    {
        self.title = "Node Settings"
        if (isComingFromElement){
            self.title = "Element Setting"
        }
        if let node = settingsNode {
            //self.name.text = node.nodeName
            if(node.nodeUUID.count == 36){
                self.uuidLabel.text = "UUID"
            }
            else if(node.nodeUUID.count == 17){
                self.uuidLabel.text = "MAC Address"
            }
            self.uuidValuesLbl.text = node.nodeUUID
            self.changedName.text = node.nodeName
            if (self.isComingFromElement)
            {
                self.changedName.text = ElementCell.lblElementName.text;
            }
        }
    }
}//class end


extension NodeSettingViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text  != nil{
            settingsNode?.nodeName = textField.text
            
            if let myDelegate = self.delegate {
                if(!myDelegate.updateNodeName(nodeUpdated: settingsNode!, newName: changedName.text!)) {
                    /* Revert the name change, if not allowed by data model. */
                }
            }
            textField.resignFirstResponder()
            return true
        }else{
            if (isComingFromElement){
                CommonUtils.showAlertWith(title:"BlueNRG-Mesh", message:"Element name can't be empty!", presentedOnViewController: self)
            }
            else{
                CommonUtils.showAlertWith(title:"BlueNRG-Mesh", message:"Node name can't be empty!", presentedOnViewController: self)
            }
            return false
        }
    }
}

extension NodeSettingViewController : RemoveDelegate {
    
    func confirmDelete(isDeleteConfirmed: Bool){
        if (isProxyNodeConnectionEstablished){
            configManager.removeNode(node:self.settingsNode!)
        }
        else{
            
            CommonUtils.showAlertWithOptionMessage(message:"Node not in range, do you want to force delete??", continueBtnTitle: "Yes", cancelBtnTitle:"No", controller: self) { (response) in
                self.currentNetworkDataManager.removeNodeFromNetworks(node:self.settingsNode!)
                self.navigationController?.popViewController(animated:true)
            }
        }
    }
}


extension NodeSettingViewController : PublishPopUpViewControllerDelegate {
    func cellSelected(cellName: String, address: UInt16) {
        self.setinItialData()
        settingsNode?.publishAddress = address   //check whether addess gets stored or not
    }
}

extension NodeSettingViewController: GroupSettingsPopupDelegate{
    func isMemberAdded(group: STMeshGroup, node: STMeshElement, didAdd: Bool, isPublisher: Bool) {
        
    }
    
    func isMemberAdded(group: STMeshGroup, node: STMeshNode, didAdd: Bool) -> Bool {
        if didAdd == true{
            return true
        }
        else{
            CommonUtils.showAlertWith(title:AppTitle, message:"Couldn't assign this group to the node. \n Try Again!", presentedOnViewController:self)
            return false
        }
    }
}

extension NodeSettingViewController:ConfigManagerDelegate{
    func didAppKeyAssignmentSuccessfullyCompleted(completed: Bool, message: String) {
        
    }
    
    func didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didAdd_RemovePublisherSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didRemoveNodeSuccessfullyCompleted(completed: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
}
