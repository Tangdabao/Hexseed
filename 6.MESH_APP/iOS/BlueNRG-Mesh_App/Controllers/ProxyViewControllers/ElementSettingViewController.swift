/**
 ******************************************************************************
 * @file    ElementSettingViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    09-Mar-2018
 * @brief   ViewController for "Element Settings" View.
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

protocol ElementSettingDelegate {
    /* Force delete to delete a node when not in network coverage */
    func deleteElement(nodeToDelete: STMeshNode,elementUpdates: STMeshElement, forceDelete: Bool)->Bool
    func updateElementName(nodeUpdated: STMeshNode,elementUpdated: STMeshElement, newName: String)->Bool
    func updateElementSwitchStatus(nodeUpdated: STMeshNode,elementUpdates: STMeshElement ,indexPath: IndexPath, status: Bool)->Bool
}


class ElementSettingViewController: UIViewController  {
    
    @IBOutlet weak var lblElementName: UITextField!
    @IBOutlet weak var lblDeviceType: UILabel!
    @IBOutlet weak var lblPublishAddress: UILabel!
    @IBOutlet weak var tblGroupsView: UITableView!
    @IBOutlet weak var btnChangeConfig: UIButton!
    @IBOutlet weak var btnEditName: UIButton!
    @IBOutlet weak var lblElementUnicastAddress: UILabel!
    @IBOutlet weak var groupHeight: NSLayoutConstraint!
    
    
    var isProxyNodeConnectionEstablished : Bool!
    var delegate : ElementSettingDelegate!
    var elementSetting : STMeshElement!
    var nodeRelatedToElement : STMeshNode!
    var indexPathElement : IndexPath!
    var currentNetworkDataManager : NetworkConfigDataManager!
    var manager:STMeshManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblGroupsView.dataSource = self
        tblGroupsView.delegate = self
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.lblElementName.isUserInteractionEnabled = false
        manager = STMeshManager.getInstance(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.setinItialData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    // MARK:Custom Method
    func setinItialData()
    {
        /* Nav bar title */
        self.title = "Element Settings"
        // element default setting
        if (elementSetting) != nil {
            self.lblElementName.text = elementSetting.elementName
            
            if let publishingNode  =  elementSetting.publishTarget as? STMeshElement {
                self.lblPublishAddress.text = publishingNode.elementName
            }
            if let  group =  elementSetting.publishTarget as? STMeshGroup {
                self.lblPublishAddress.text =  group.groupName
            }
            self.lblDeviceType.text = "Lighting"
            
            self.lblElementUnicastAddress.text = String(format:"%d",elementSetting.unicastAddress)
        }
        DispatchQueue.main.async {
            self.tblGroupsView.reloadData()
        }
    }
    
    // MARK: - Selectors for buttons
    @IBAction func changeConfigClicked(_ sender: Any) {
        if (isProxyNodeConnectionEstablished){
            /* Perform Segue here for adding groups. */
            self.performSegue(withIdentifier: "addGroupElementSegue", sender: nil)
        }
        else{
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (response) in
            })
        }
    }
    
    @IBAction func removeElementClicked(_ sender: Any) {
        
        if (isProxyNodeConnectionEstablished){
            /* Perform Segue here for removing the node. */
        }
        else{
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (response) in
            })
        }
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        self.lblElementName.isUserInteractionEnabled = true
        lblElementName.becomeFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGroupElementSegue"{
            if (isProxyNodeConnectionEstablished){
                let destinationVC = segue.destination as! AddConfigurationViewController
                destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
                destinationVC.nodeBeingAdded = nodeRelatedToElement
                let elementIndex = nodeRelatedToElement.elementList.index(of: elementSetting)
                destinationVC.isCommingFromAllElementClickedButton = false
                destinationVC.elementIndexInNodeElementArray = elementIndex
                destinationVC.isChangeConfig = true
            }
            else{
            }
        }
    }
}


extension ElementSettingViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text  != nil{
            
            elementSetting.elementName = textField.text!
            if let myDelegate = self.delegate { // change the name here for the element
                if(!myDelegate .updateElementName(nodeUpdated: nodeRelatedToElement, elementUpdated: elementSetting, newName: textField.text!)) {
                    /* Revert the name change, if not allowed by data model. */
                }
            }
            textField.resignFirstResponder()
            return true
        }
        else{
            CommonUtils.showAlertWith(title:"BlueNRG-Mesh", message:"Element name can't be empty!", presentedOnViewController: self)
            return false
        }
    }
}


extension ElementSettingViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groupHeight.constant = CGFloat(((elementSetting!.subscribedGroups.count) * 26) + 20)
        return (elementSetting?.subscribedGroups.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath) as! settingsNodeGroupsTableViewCell
        let group1 = elementSetting!.subscribedGroups[indexPath.row] as! STMeshGroup
        cell.groupName.text = group1.groupName
        cell.selectionStyle = .none
        return cell
    }
}


extension ElementSettingViewController :STMeshManagerDelegate{
    func meshManager(_ manager: STMeshManager!, didProxyConnectionChanged isConnected: Bool) {
        
    }
}
