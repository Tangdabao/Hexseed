/**
 ******************************************************************************
 * @file    HealthTestViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    09-Aug-2018
 * @brief   ViewController for the "HealthTest" View.
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
let KConstantMaxTimeValueInHealthModel = 20

class HealthTestViewController: UIViewController {
    var manager: STMeshManager!
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var nodeHealth : STMeshNode! = nil
    var marrHealthModelTableViewFaultsData : NSMutableArray! = nil
    
    // test screen outlet
    @IBOutlet weak var btnHealthModelGetFaults: UIButton!
    @IBOutlet weak var btnHealthModelClearFaults: UIButton!
    @IBOutlet weak var txtFieldHealthModelPeriodTimeInSec: UITextField!
    @IBOutlet weak var btnHealthModelSetPeriod: UIButton!
    @IBOutlet weak var btnHealthModelGetPeriod: UIButton!
    @IBOutlet weak var btnHealthModelSetAttention: UIButton!
    @IBOutlet weak var btnHealthModelGetAttention: UIButton!
    @IBOutlet weak var txtFieldHealthModelAttentionTimeInSec: UITextField!
    // result view outlet
    @IBOutlet var viewTestScreenResultView: UIView!
    @IBOutlet weak var tblviewHealthModelResult: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        manager = STMeshManager.getInstance(self)
        manager.getHealthModel().delegate = self
        txtFieldHealthModelAttentionTimeInSec.doneAccessory = true
        txtFieldHealthModelPeriodTimeInSec.doneAccessory = true
    }
    // MARK: Health Model Get Faults
    @IBAction func btnHealthModelGetFaultsClicked(_ sender: Any) {
        if checkingNodeConfiguredOrNot(currentNode: nodeHealth) == true{
            let cidValue = UInt16(Int(nodeHealth.cid, radix: 16)!)
            //            let cid = UInt16(Int("0030", radix: 16)!)
            manager?.getHealthModel().healthModelGetFaults(nodeHealth.unicastAddress, companyIdentifier: cidValue)
        }
    }
    
    // MARK: Health Model Clear Faults
    @IBAction func btnHealthModelClearFaultsClicked(_ sender: Any) {
        if checkingNodeConfiguredOrNot(currentNode: nodeHealth) == true{
            //            let cid = UInt16(Int("0030", radix: 16)!)
            let cidValue = UInt16(Int(nodeHealth.cid, radix: 16)!)
            
            //            manager.getHealthModel().healthFaultClear(nodeHealth.unicastAddress, companyIdentifier: cid )
            if UserDefaults.standard.bool(forKey: KConstantReliableModeKey){ // reliable command
                manager.getHealthModel().healthFaultClear(nodeHealth.unicastAddress, companyIdentifier: cidValue, isUnacknowledgedCommand: true)
            }
            else{
                manager.getHealthModel().healthFaultClear(nodeHealth.unicastAddress, companyIdentifier: cidValue, isUnacknowledgedCommand: false)
            }
        }
    }
    
    // MARK: Health Model Set Fault Period
    @IBAction func btnHealthModelSetFaultsPeriod(_ sender: Any) {
        
        if  txtFieldHealthModelPeriodTimeInSec.text?.count != 0 ,(Int(txtFieldHealthModelPeriodTimeInSec.text!)! > KConstantMaxTimeValueInHealthModel){
            UIView.animate(withDuration: 0.2, animations: {
                self.txtFieldHealthModelPeriodTimeInSec.createGenricViewError()
                
            }) { (completion) in
                self.txtFieldHealthModelPeriodTimeInSec.removeGenricViewError()
                
            }
        }
        else{
            if checkingNodeConfiguredOrNot(currentNode: nodeHealth) == true{
                if UserDefaults.standard.bool(forKey: KConstantReliableModeKey){ // reliable command
                    manager.getHealthModel().healthPeriodSet(nodeHealth.unicastAddress, fastPeriodDivisor: 1 , isUnacknowledgedCommand: true)
                }
                else{
                    manager.getHealthModel().healthPeriodSet(nodeHealth.unicastAddress, fastPeriodDivisor: 1, isUnacknowledgedCommand: false)
                }
                
            }
        }
    }
    
    // MARK: Health Model Get Period
    @IBAction func btnHealthModelGetPeriodClicked(_ sender: Any) {
        if checkingNodeConfiguredOrNot(currentNode: nodeHealth) == true{
            manager.getHealthModel().healthPeriodGet(nodeHealth.unicastAddress)
        }
    }
    
    // MARK: Health Model Get Attention
    @IBAction func btnHealthModelGetAttentionClicked(_ sender: Any) {
        if checkingNodeConfiguredOrNot(currentNode: nodeHealth) == true{
            manager.getHealthModel().healthAttentionGet(nodeHealth.unicastAddress)
        }
    }
    
    //MARK: Health Model Set Attention
    @IBAction func btnHealthModelSetAttentionClicked(_ sender: Any) {
        if checkingNodeConfiguredOrNot(currentNode: nodeHealth) == true{
            if UserDefaults.standard.bool(forKey: KConstantReliableModeKey){ // reliable command
                manager.getHealthModel().healthAttentionSet(nodeHealth.unicastAddress, attention: 1 ,isUnacknowledgedCommand: true)
            }
            else{
                manager.getHealthModel().healthAttentionSet(nodeHealth.unicastAddress, attention: 1, isUnacknowledgedCommand: false)
            }
        }
    }
    
    //Checking if node is configured.
    func isConfigureNotComplete(currentNode:STMeshNode) ->Bool{
        if !currentNode.configComplete{
            CommonUtils.showAlertWithOptionMessage(message:"Configuration of this node is not complete, Do you want to configure it?", continueBtnTitle:"Yes", cancelBtnTitle:"No", controller: self) { (response) in
                self.navigateToConfigureScreen(node: currentNode)
            }
        }
        return currentNode.configComplete
    }
    
    //Navigate to Configure Screen, if node not configured.
    func navigateToConfigureScreen(node:STMeshNode){
        let controller = UIStoryboard.loadViewController(storyBoardName: "Main", identifierVC: "AddConfigurationViewController", type: AddConfigurationViewController.self)
        controller.nodeBeingAdded = node
        controller.currentNetworkDataManager = self.currentNetworkDataManager
        controller.isCommingFromAllElementClickedButton = true;
        controller.elementIndexInNodeElementArray = 0;
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Removing the fault view
    @objc func removeFaultsView(tapgesture: UITapGestureRecognizer) -> Void {
        UIView.animate(withDuration: 0.2, animations: {
            self.viewTestScreenResultView.alpha = 0.0
            tapgesture.view?.removeGestureRecognizer(tapgesture)
        }) { (completion) in
            self.viewTestScreenResultView.removeFromSuperview()
        }
    }
    
    // checking the combination of the isProxyConnectionEnabled and IsNodeConfigure
    func checkingNodeConfiguredOrNot(currentNode : STMeshNode) -> Bool{
        if (manager?.isConnectedToProxyService())!{
            let node = currentNode as STMeshNode
            if isConfigureNotComplete(currentNode: node) == true{
                return true
            }
            else {// node is not configured
                
                return false
            }
        }
        else {         // not connected to proxy service
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (response) in
            })
            return false
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: Mesh Manager Delegates
extension HealthTestViewController : STMeshManagerDelegate{
    
}
//MARK: Health Model Callbacks
extension HealthTestViewController : STMeshHealthModelDelegate{
    func healthModel(_ healthModel: STMeshHealthModel!, didReceiveHealthStatusFromAddress peerAddress: UInt16, withPresentsFaults faultsArray: [Any]!) {
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(removeFaultsView(tapgesture:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        marrHealthModelTableViewFaultsData = NSMutableArray()
        if faultsArray.count == 0{
            marrHealthModelTableViewFaultsData.add("No fault in the node.")
            
        }else{
            marrHealthModelTableViewFaultsData.addObjects(from: faultsArray)
            
        }
        self.viewTestScreenResultView.alpha = 1.0
        commonAlertView().createUpperView(self.viewTestScreenResultView, withWidthMultiplier: 0.75, withHeightMultiplier: 0.4, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: self.view)
        self.tblviewHealthModelResult.delegate = self
        self.tblviewHealthModelResult.dataSource = self
        
    }
    
    func healthModel(_ healthModel: STMeshHealthModel!, didReceiveHealthPeriodStatusResponseFromAddress peerAddress: UInt16, withFastPeriodDivisor fastPeriodDivisor: UInt8) {
        
    }
    
    func healthModel(_ healthModel: STMeshHealthModel!, didReceiveHealthAttentionStatusResponseFromAddress peerAddress: UInt16, withAttention attention: UInt8) {
        print("Attention Status Recived")
    }
    
    
}

// MARK: Table View Delegates and Data sources
extension HealthTestViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marrHealthModelTableViewFaultsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "healthModelTableViewCell", for: indexPath)
        cell.textLabel?.text = (marrHealthModelTableViewFaultsData.object(at: indexPath.row) as! String)
        return cell
    }
}

//MARK: Text Field Extension for done button

extension UITextField{
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = UIColor.white
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
        if self.text?.count != 0 , (Int(self.text!)! > KConstantMaxTimeValueInHealthModel){
            UIView.animate(withDuration: 0.4, animations: {
                self.createGenricViewError()
                
            }) { (completion) in
                self.removeGenricViewError()
            }
        }
    }
}



