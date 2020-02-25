/**
 ******************************************************************************
 * @file    ImportExportConfigController
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    04-April-2018
 * @brief   ViewController for the "Import / Export Configuration" View.
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
import MobileCoreServices
import MessageUI

protocol ImportConfigDelegate{
    func didImportNewConfig()
}

extension  ImportConfigDelegate{
    func didImportNewConfig(){
    }
}


class ImportExportConfigController: UIViewController{
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var delegate:ImportConfigDelegate?
    var manager:STMeshManager!
    
    @IBOutlet var viewDeleteNetworkAlert: UIView!
    @IBOutlet weak var btnImportFromFile: UIButton!
    @IBOutlet weak var layoutHeightConstraintForExportToMail: NSLayoutConstraint!
    @IBOutlet weak var btnExportToMail: UIButton!
    @IBOutlet weak var btnDeleteConfiguration: UIButton!
    @IBOutlet weak var layoutExportButtonHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    var isComingFromFirstTimeSetup : Bool = false
    
    @IBOutlet var importAlertView: UIView!
    @IBOutlet weak var cancelImportAlert: UIButton!
    @IBOutlet weak var continueImportAlert: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Import/Export Config"
        manager =  STMeshManager.getInstance(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if (isComingFromFirstTimeSetup){
            self.btnExportToMail.isHidden = true
            self.btnDeleteConfiguration.isHidden = true
        }
        else{
            self.btnExportToMail.isHidden = false
        }
        
        scrollViewContentHeight.constant = screenHeight
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.ST_DarkBlue]
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Import Clicked
    @IBAction func importFromMailBtnAction(_ sender: UIButton) {
        
        self.createImportAlertView()
        
    }
    
    //MARK: Button Export Clicked
    @IBAction func exportToMailBtnAction(_ sender: UIButton) {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("BlueNRG-Mesh Configuration File ")
            mailComposer.setMessageBody("Please find configuration file as attachment!. ", isHTML: false)
            let json  = currentNetworkDataManager.generateJsonFromNetworkConfigModel()
            if let data =  self.jsonToNSData(json:json.rawValue as AnyObject){
                mailComposer.addAttachmentData(data as Data, mimeType: "application/json", fileName: "bluenrg-mesh_configuration.json")
                self.present(mailComposer, animated: true, completion: nil)
            }
        }
    }
    
    func getInitialData() {
        //        DispatchQueue.global(qos: .userInitiated).async {
        self.currentNetworkDataManager.retrieveNetworkConfigFromStorage()
        if  let node = CommonUtils.getCurrentProvisioner()
        {
            self.manager?.createNetwork(node)
        }else{
            self.manager?.createNetwork(10000)
        }
        self.manager?.setNetworkData(self.currentNetworkDataManager.currentNetworkData)
        self.currentNetworkDataManager.saveNetworkConfigToStorage()
        // }
    }
    
    //MARK: Delete Configuration
    @IBAction func btnDeleteConfigurationClicked(_ sender: Any) {
        self.view.addBlurEffect(style: .light)
        let deleteButtonClicked = {()-> Void in
            
            UserDefaults.standard.set(nil, forKey: STMesh_NetworkSettings_Key)
            UserDefaults.standard.set(nil, forKey: KConstant_JoinedMeshNetworkUUID)
            UserDefaults.standard.set(false, forKey: KConstant_UserCreatedNetworkOnCloud_Key)
            UserDefaults.standard.set(false, forKey: KConstantHelpScreenToShowForProxyViewController)
            self.tabBarController?.navigationController?.popToViewController((self.tabBarController?.viewControllers?[1])!, animated: true)
            NetworkConfigDataManager.destroyCurrentNetwork()
            
            self.getInitialData()
            UIView.animate(withDuration: 0.2, animations: {
                
                self.viewDeleteNetworkAlert.alpha = 0.0
            }) { (completion) in
                self.view.removeBlurEffect()
                self.dismiss(animated: true, completion: {
                })
            }
        }
        
        let cancelButtonClicked = {
            ()-> Void in
            UIView.animate(withDuration: 0.2, animations: {
                self.view.removeBlurEffect()
            }) { (completion) in
                self.viewDeleteNetworkAlert.removeFromSuperview()
            }
        }
        commonAlertView().setUpGUIAlertView(title: "", message: "Do you really want to delete the current network", viewController: self, firstButtonTitle: "Delete", reqSecondButton: true, secondButtonText: "Cancel", firstButtonAction: deleteButtonClicked, secondButtonAction: cancelButtonClicked)
        UIView.animate(withDuration: 0.15, animations: {
        }) { (completion) in
        }
    }
    
    @IBAction func alertCancelAction(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.removeBlurEffect()
        }) { (completion) in
            self.viewDeleteNetworkAlert.removeFromSuperview()
        }
    }
    
    @IBOutlet weak var alertCancelAction: UIButton!
    func jsonToNSData(json: AnyObject) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    func showAlert(message:String, json:JSON) {
        
        CommonUtils.showAlertWithOptionMessage(message:message, continueBtnTitle:"Continue", cancelBtnTitle: "Cancel", controller: self) { (response) in
            self.manager.stopNetwork()
            DispatchQueue.global(qos: .userInitiated).async {
                self.currentNetworkDataManager.populateNetworkConfigModelFromJson(settingJSON:json, currentNetworkDataModel: self.currentNetworkDataManager.currentNetworkData)
                self.currentNetworkDataManager.saveNetworkConfigToStorage()
            }
            CommonUtils.showAlertWith(title:AppTitle, message:"Configuration imported successfully", presentedOnViewController:self)
            self.delegate?.didImportNewConfig()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: via cloud Interaction
    @IBAction func viaCloudClicked(_ sender: Any) {
        
        if (!UserDefaults.standard.bool(forKey: KConstant_UserCreatedNetworkOnCloud_Key) ){
            self.performSegue(withIdentifier: "joinNetworkViewController", sender: nil)
            
        }
        else{
            self.performSegue(withIdentifier: "cloudSyncViewController", sender: nil)
        }
    }
    
    // MARK: Create Import Alert
    func createImportAlertView(){
        self.view.addBlurEffect()
        
        self.importAlertView.alpha = 0.0
        self.importAlertView.frame = CGRect(x: 15 , y: self.view.frame.size.height/3, width: self.view.frame.size.width - 30, height: self.view.frame.size.height/3)
        self.view.addSubview(importAlertView)
        
        UIView.animate(withDuration: 0.15, animations: {
            self.importAlertView.alpha = 1.0
        }) { (completion) in
        }
    }
    
    @IBAction func continueImportAlertClicked(_ sender: Any) {
        self.view.removeBlurEffect()
        UIView.animate(withDuration: 0.2, animations: {
            self.importAlertView.alpha = 0.0
        }) { (completion) in
            self.importAlertView.removeFromSuperview()
        }
        
        
        if #available(iOS 11.0, *) {
            let type = [kUTTypeJSON as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: type, in:.import)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor as NSAttributedStringKey : UIColor.blue], for: .normal)
            
            documentPicker.delegate = self
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor as NSAttributedStringKey : UIColor.blue], for: .normal)
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .fullScreen
            self.present(documentPicker, animated:true) {
            }
        } else {
            CommonUtils.showAlertWith(title:AppTitle, message:"This feature is supported iOS 11 onwards.", presentedOnViewController: self)
        }
    }
    
    @IBAction func cancelImportAlertClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.removeBlurEffect()
            
            self.importAlertView.alpha = 0.0
        }) { (completion) in
            self.importAlertView.removeFromSuperview()
        }
        
    }
    
}


extension ImportExportConfigController : UIDocumentPickerDelegate,UINavigationControllerDelegate ,MFMailComposeViewControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let jsonData =  try? Data(contentsOf:urls.first!) as Data? {
            let readableJSON = JSON(data: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
            print(readableJSON)
            showAlert(message:"Import would overwrite existing configuration with the new configuration", json:readableJSON)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension ImportExportConfigController: STMeshManagerDelegate{
}



