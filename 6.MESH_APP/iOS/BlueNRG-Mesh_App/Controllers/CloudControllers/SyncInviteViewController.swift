/**
 ******************************************************************************
 * @file    SyncInviteViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    06-June-2018
 * @brief   ViewController for the "Sync & Invite" View.
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

class SyncInviteViewController: UIViewController {
    
    static var isLogin : Bool = false
    
    var isComingFromSideMenu : Bool = false
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblInvitationCode: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSync: UIButton!
    @IBOutlet weak var btnGenerateInvitationCode: UIButton!
    var currentNetworkDataMgr = NetworkConfigDataManager.sharedInstance
    
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil){
            LoginSignUpManager.sharedInstance.createLoginPage(callingClassDelegate: self)
        }
        if ((UserDefaults.standard.value(forKey: KConstant_UserID_key) as? String) != nil) ,((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String) != nil) {
            
            lblUserName.isHidden = false
            lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
            self.btnLogin.setTitle("Logout", for: .normal)
        }
        else{
            lblUserName.isHidden = true
            self.btnLogin.setTitle("Login", for: .normal)
        }
        scrollViewContentHeight.constant = screenHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Sync Button Clicked
    @IBAction func btnSyncClicked(_ sender: Any) {
        if (UserDefaults.standard.value(forKey: KConstant_UserID_key) == nil){
            CommonUtils.showAlertTostMessage(title: "Error", message: "You are not logged in", controller: self) { (completion) in
            }
            return
        }
        
        if (currentNetworkDataMgr.currentNetworkData.meshUUID != nil){
            if !UserDefaults.standard.bool(forKey: KConstant_UserCreatedNetworkOnCloud_Key) {
                CloudOperationHandler.sharedInstance.createNetwork(viewController: self)
            }
            else {
                CloudOperationHandler.sharedInstance.uploadExistingNetwork(viewController: self)
            }
        }
        else{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You don't have any network to sync", controller: self) { (completion) in
            }
        }
    }
    
    // MARK: Get Invitation Code
    @IBAction func btnGenerateInvitationCodeClicked(_ sender: Any) {
        if userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You are not logged in", controller: self) { (completion) in
            }
            return
        }
        let parameters : Parameters = [
            "userKey":(userDefaultLoginDetails.value(forKey: KConstant_UserID_key)as! String),
            "MeshUUID":currentNetworkDataMgr.currentNetworkData.meshUUID as String
        ]
        //making a post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForInvite), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForInvitationCode(notificationReponseObject:)), name: Notification.Name(kNotificationNameForInvite), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_INVITE_IN_NETWORK, parameters: parameters, viewController: self, notificationName: kNotificationNameForInvite)
    }
    
    @objc private func responseFromCloudForInvitationCode(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForInvite), object: nil)
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        
        //  performing valid operations
        self.lblInvitationCode.isHidden = false
        self.lblInvitationCode.alpha = 1.0
        self.lblInvitationCode.text = responseMessage
        
        
        //adding tap gesture to copy the text
        self.lblInvitationCode.isUserInteractionEnabled = true
        let lblTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.copyLabelText))
        lblTapGesture.numberOfTapsRequired = 2
        self.lblInvitationCode.addGestureRecognizer(lblTapGesture)
        CommonUtils.showAlertToastWithColor(title: "", message: "Double tap to copy", controller: self, color: .black ,fontSize : 16) { (response) in      }
    }
    
    @objc func copyLabelText() -> Void {
        UIPasteboard.general.string = lblInvitationCode.text
        
        CommonUtils.showAlertToastWithColor(title: "", message: "Code copied successfully!!", controller: self, color: KConstant_SuccessfulColorCode_Key ,fontSize :20) { (response) in      self.navigationController?.popViewController(animated: true) }
    }
    
    //MARK: Login Process
    @IBAction func btnSignInClicked(_ sender: Any) {
        if (userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil && ((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Login") == .orderedSame){
            //            self.callLoginPageIfNotLogin()
            LoginSignUpManager.sharedInstance.createLoginPage(callingClassDelegate: self)
        }
        else if (((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Logout") == .orderedSame)
        {
            let logoutButtonAction = { () ->Void in
                
                SignOutOperation.sharedInstance.signOutProcess(viewController : self)
            }
            
            let cancelButtonAction = { ()-> Void in
                
            }
            
            commonAlertView().setUpGUIAlertView(title: "", message: "Do you really want to Log out", viewController: self, firstButtonTitle: "logout", reqSecondButton: true, secondButtonText: "Cancel", firstButtonAction: logoutButtonAction, secondButtonAction: cancelButtonAction)        }
    }
}


extension SyncInviteViewController : LoginAndSignUpDelegate{
    func removeLoginClicked() {
        self.removeLoginView(tapGesture: nil)
    }
    
    func loginSuccessful() {
        SyncInviteViewController.isLogin = true
        self.removeLoginView(tapGesture: nil)
        self.btnLogin.setTitle("Logout", for: .normal)
        UIView.transition(with: self.btnLogin, duration: 0.75, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        lblUserName.isHidden = false
        appDelegate.menuViewController.lblUserName.isHidden = false
        lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
        appDelegate.menuViewController.lblUserName.text = lblUserName.text!
        
        if let loginUsername = (UserDefaults.standard.value(forKey: KConstant_UserName_key)) , let ntwRegisteredUsername = (UserDefaults.standard.value(forKey: KConstant_NetworkRegisteredByUsername)), (loginUsername as! String).caseInsensitiveCompare((ntwRegisteredUsername as! String)) != .orderedSame {
            UserDefaults.standard.set(false, forKey: KConstant_UserCreatedNetworkOnCloud_Key)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func signupSuccessful() {
        SyncInviteViewController.isLogin = true
        self.removeLoginView(tapGesture: nil)
        self.btnLogin.setTitle("Logout", for: .normal)
        UIView.transition(with: self.btnLogin, duration: 0.75, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        lblUserName.isHidden = false
        lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
        appDelegate.menuViewController.lblUserName.text = lblUserName.text!
        appDelegate.menuViewController.lblUserName.isHidden = false
    }
    
    @objc func removeLoginView(tapGesture:UITapGestureRecognizer?)  {
        
        if isComingFromSideMenu{
            for sv in self.view.subviews{
                sv.alpha = 0.0
            }
            self.dismiss(animated: true) {
            }
        }
        else{
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
}


extension SyncInviteViewController : SignOutOperationDelegate{
    func signOutSuccessful() {
        self.btnLogin.setTitle("Login", for: .normal)
        self.navigationController?.popViewController(animated: true)
        
        UIView.transition(with: self.btnLogin, duration: 0.3, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
}




