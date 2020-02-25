/**
 ******************************************************************************
 * @file    AddGroupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    02-Nov-2017
 * @brief   ViewController for "Add New Group" View.
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

class AddGroupViewController: UIViewController{
    
    var group = STMeshGroup()
    var groupsArray = [STMeshGroup]()
    @IBOutlet var groupName: UITextField!
    @IBOutlet var groupAddress: UITextField!
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Group"
        /* Auto increment the group address for convenience */
        let groups = self.currentNetworkDataManager.currentNetworkData.groups
        
        var groupAddess: UInt16 = 0xC000 /*Start with address 0xC000 */
        
        var addressLowRangeValue :UInt16 = 0
        var addressHighRangeValue :UInt16 = 0
        
        let provisionersArray = currentNetworkDataManager.currentNetworkData.provisionerDataArray
        for objProvisioner  in provisionersArray! as!  [STMeshProvisionerData] {
            
            if (objProvisioner.provisionerUUID == userDefault.value(forKey: STMesh_UserDefaultValues_CurrentProvisionerUUID) as? String){
                
                for rangeIndex in 0..<objProvisioner.marrProvisionerAllocatedGroupRange.count{
                    let objProvisionerLowRange = (objProvisioner.marrProvisionerAllocatedGroupRange[rangeIndex] as AnyObject).value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! String
                    let objProvisionerHighRange = (objProvisioner.marrProvisionerAllocatedGroupRange[rangeIndex] as AnyObject).value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
                    
                    addressLowRangeValue = UInt16(objProvisionerLowRange)!
                    addressHighRangeValue = UInt16(objProvisionerHighRange)!
                }
                
                groupAddess = addressLowRangeValue
                
                if let allGroups = groups?.sorted(by: { ($0 as! STMeshGroup).groupAddress < ($1 as! STMeshGroup).groupAddress }) as? [STMeshGroup]{
                    for i in 0..<allGroups.count {
                        let group = allGroups[i]
                        if(group.groupAddress >= addressLowRangeValue && group.groupAddress < addressHighRangeValue ) {
                            groupAddess += 1;
                        }
                    }
                }
            }
        }
        
        groupAddress.text = String(format:"%4X", groupAddess)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: selectors
    @IBAction func groupAdd(_ sender: Any) {
        /* Check validity of the group name and address text field */
        if((groupName.text?.isEmpty)! || (groupAddress.text?.isEmpty)!)
        {
            CommonUtils.showAlertWith(title:AppTitle, message: "Please enter the complete details of Group", presentedOnViewController: self)
            return
        }
        else if(Int(groupAddress.text!, radix: 16) == nil){
            CommonUtils.showAlertWith(title:AppTitle, message: "Please enter a valid Group Address.", presentedOnViewController: self)
            return
        }
        else if(((Int(groupAddress.text!, radix: 16)!) < 0xC000)||((Int(groupAddress.text!, radix: 16)!) > 0xFEFF)){
            CommonUtils.showAlertWith(title:AppTitle, message: "Please enter a valid Group Address.", presentedOnViewController: self)
            return
        }
        else if((UInt16(Int(groupAddress.text!, radix: 16)!) & 0xC000) != 0xC000){
            CommonUtils.showAlertWith(title:AppTitle, message: "Please enter a valid Group Address.", presentedOnViewController: self)
            return
        }
        for i in 0..<currentNetworkDataManager.currentNetworkData.groups.count{
            let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
            if(group.groupAddress == UInt16(Int(groupAddress.text!, radix: 16)!)){
                CommonUtils.showAlertWith(title:AppTitle, message:"Group Address already assigned. Please choose another Group Address", presentedOnViewController:self)
                return
            }
        }
        for i in 0..<currentNetworkDataManager.currentNetworkData.groups.count{
            let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
            if(group.groupName == groupName.text){
                CommonUtils.showAlertWith(title:AppTitle, message:"Group name already assigned. Please choose another Group Name", presentedOnViewController:self)
                return
            }
        }
        
        if (self.checkIfGroupAddressLyingInProvisionerRange(groupAddress: UInt16(Int(groupAddress.text!, radix: 16)!))){
            
            group.groupName = groupName.text
            group.groupAddress = UInt16(Int(groupAddress.text!, radix: 16)!)
            currentNetworkDataManager.addGroup(didAddNewGroup: group)
            
            currentNetworkDataManager.saveNetworkConfigToStorage()
            self.navigationController?.popViewController(animated: true)
        }
        else{
            
            print("Address is out of allocated address range :", groupAddress)
        }
    }
    
    func checkIfGroupAddressLyingInProvisionerRange(groupAddress: UInt16) -> Bool {
        
        let provisionersArray = currentNetworkDataManager.currentNetworkData.provisionerDataArray
        for objProvisioner  in provisionersArray! as!  [STMeshProvisionerData] {
            
            if (objProvisioner.provisionerUUID == userDefault.value(forKey: STMesh_UserDefaultValues_CurrentProvisionerUUID) as? String){
                
                
                for rangeIndex in 0..<objProvisioner.marrProvisionerAllocatedGroupRange.count{
                    
                    let provisionerEachRangLowValue = (objProvisioner.marrProvisionerAllocatedGroupRange[rangeIndex] as! NSDictionary ).value(forKey: STMesh_Provisioner_AddressLowRange_Key
                        ) as! String
                    let provisionerEachRangHighValue = (objProvisioner.marrProvisionerAllocatedGroupRange[rangeIndex] as! NSDictionary ).value(forKey: STMesh_Provisioner_AddressHighRange_Key
                        ) as! String
                    
                    
                    if (groupAddress >= UInt16(provisionerEachRangLowValue)! && groupAddress <  UInt16(provisionerEachRangHighValue)!){
                        return true
                    }
                    else{
                        let alertController = UIAlertController(title: "" , message: "Group Address should be in the range of " + String(format: "", provisionerEachRangLowValue)+" to " + String(format: "",+UInt16(provisionerEachRangHighValue)!) + ".", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            // print("OK")
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        return false
                    }
                }
            }
        }
        return false
    }
    
}//class end


extension AddGroupViewController :UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
