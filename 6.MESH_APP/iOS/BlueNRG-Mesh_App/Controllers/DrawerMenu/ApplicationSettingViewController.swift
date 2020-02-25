/**
 ******************************************************************************
 * @file    ApplicationSettingViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    13-June-2018
 * @brief   ViewController for the App settings View.
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

class ApplicationSettingViewController: UIViewController {
    
    @IBOutlet weak var txtFieldProvisionerNane: UITextField!
    @IBOutlet weak var switchShowHelperScreen: UISwitch!
    @IBOutlet weak var viewProvisionerName: UIView!
    @IBOutlet weak var lblNetworkName: UIView!
    @IBOutlet weak var txtFieldNetworkName: UITextField!
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForProxyViewController) && !UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForSettingViewController)){
            switchShowHelperScreen.isOn = true
        }
        else{
            switchShowHelperScreen.isOn = false
        }
        
        
        /* Adding prefilled name in the Provisioner and Network Name */
        txtFieldNetworkName.text = currentNetworkDataManager.currentNetworkData.meshName
        
        var provisionerName : String?
        for provisionerInstance in currentNetworkDataManager.currentNetworkData.onlyProvisionerArray as! [STMeshNode]{
            if (provisionerInstance.nodeUUID.caseInsensitiveCompare(UIDevice.current.identifierForVendor!.uuidString) == .orderedSame){
                provisionerName = provisionerInstance.nodeName!
                break
            }
        }
        if let provisionerNameFromForLoop = provisionerName{
            txtFieldProvisionerNane.text = provisionerNameFromForLoop
        }
        else{
            txtFieldProvisionerNane.text = UIDevice.current.name
        }
        
        txtFieldNetworkName.isUserInteractionEnabled = false
        txtFieldProvisionerNane.isUserInteractionEnabled = false
        
        /* Do any additional setup after loading the view. */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnNetworkNameEditIconClicked(_ sender: Any) {
        txtFieldProvisionerNane.delegate = nil
        txtFieldNetworkName.delegate = self
        txtFieldNetworkName.isUserInteractionEnabled = true
        txtFieldNetworkName.becomeFirstResponder()
        
    }
    
    @IBAction func btnProvisionerNameEditIconClicked(_ sender: Any) {
        txtFieldNetworkName.delegate = nil
        txtFieldProvisionerNane.delegate = self
        txtFieldProvisionerNane.isUserInteractionEnabled = true
        txtFieldProvisionerNane.becomeFirstResponder()
        
    }
    //MARK: Helper Screen Switch
    @IBAction func switchShowUserHelpScreenStateChanged(_ sender: Any) {
        
        /* If switch state is on then send the reliable commands and set the Reliable bool variable true */
        if switchShowHelperScreen.isOn{
            /* Set Reliable Variable */
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForSettingViewController)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForProxyViewController)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForLightingModelListViewController)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForVendorModelListViewController)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForGenricModelListViewController)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForModelListViewController)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForProxyViewControllerOnAtleastOneNode)
        }
        else{
            /* Unset Reliable variable */
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForSettingViewController)
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForProxyViewController)
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForLightingModelListViewController)
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForVendorModelListViewController)
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForGenricModelListViewController)
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForModelListViewController)
            UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForProxyViewControllerOnAtleastOneNode)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (txtFieldNetworkName.delegate != nil){
            let _ = self.textFieldShouldReturn(txtFieldNetworkName)
            
        }
        if (txtFieldProvisionerNane.delegate != nil){
            let _ =  self.textFieldShouldReturn(txtFieldProvisionerNane)
            
        }
    }
}
extension ApplicationSettingViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
            
            if (txtFieldProvisionerNane.delegate != nil){
                
                for provisionerInstance in currentNetworkDataManager.currentNetworkData.provisionerDataArray as! [STMeshProvisionerData]{
                    if (provisionerInstance.provisionerUUID.caseInsensitiveCompare(UIDevice.current.identifierForVendor!.uuidString) == .orderedSame){
                        provisionerInstance.provisionerName = textField.text!
                        
                        break
                    }
                }
                for eachNode in currentNetworkDataManager.currentNetworkData.onlyProvisionerArray as! [STMeshNode]{
                    if (eachNode.nodeUUID.caseInsensitiveCompare(UIDevice.current.identifierForVendor!.uuidString) == .orderedSame){
                        eachNode.nodeName = textField.text!
                        
                        break
                    }
                }
                currentNetworkDataManager.saveNetworkConfigToStorage()
                currentNetworkDataManager.retrieveNetworkConfigFromStorage()
            }
            else if txtFieldNetworkName.delegate != nil{
                currentNetworkDataManager.currentNetworkData.meshName = textField.text!
                currentNetworkDataManager.saveNetworkConfigToStorage()
                currentNetworkDataManager.retrieveNetworkConfigFromStorage()
            }
            textField.resignFirstResponder()
            
            return true
        }else{
            CommonUtils.showAlertWith(title:AppTitle, message:String(format: textField.placeholder! + " can't be empty"), presentedOnViewController: self)
            return false
        }
    }
    
}
