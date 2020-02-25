/**
 ******************************************************************************
 * @file    CloudInteractionViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    06-June-2018
 * @brief   Cloud Synchronization
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
//import Alamofire
class CloudInteractionViewController: UIViewController {
    
    static var isLogin : Bool = false
    var objLoginPageViewController : LoginPageViewController!
    var objSignUpPageViewController : SignUpPageViewController!
    var loginView : UIView!
    var signUp : UIView!
    var backBlurView = UIView()
    var isComingFromSideMenu : Bool = false
    var cloudInteractionObject = SyncOperationController.sharedInstance
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblInvitationCode: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSync: UIButton!
    @IBOutlet weak var btnGenerateInvitationCode: UIButton!
    var currentNetworkDataMgr = NetworkDataManager.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil){
            self.callLoginPageIfNotLogin()
        }
        if ((UserDefaults.standard.value(forKey: KConstant_UserID_key)) != nil){
            lblUserName.isHidden = false
            lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
            self.btnLogin.setTitle("Logout", for: .normal)
        }
        else{
            lblUserName.isHidden = true
            self.btnLogin.setTitle("Login", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func btnSyncClicked(_ sender: Any) {
        // first check the userdefault if mesh UUID is created
        // if not created then hit the create network then hit the upload API
        // hit the donwload the Api
        if (currentNetworkDataMgr.currentNetworkData.meshUUID != nil){
            if !UserDefaults.standard.bool(forKey: KConstant_UserCreatedNetworkOnCloud_Key) {
                cloudInteractionObject.syncNetwork(viewController: self)
            }
            else {
                SyncOperationController.sharedInstance.CloudInteractionViewControllerInstance = self
                SyncOperationController.sharedInstance.uploadExistingNetwork()
            }
        }
        else{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You don't have any network to sync", controller: self) { (completion) in
            }
        }
  
        
        
    }
    
    // MARK: Get Invitation Code
    @IBAction func btnGenerateInvitationCodeClicked(_ sender: Any) {
        var parameters : Parameters
        if userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You are not logged in", controller: self) { (completion) in
            }
            return
        }
        else{
            
            parameters  = [
                "userKey":(userDefaultLoginDetails.value(forKey: KConstant_UserID_key)as! String),
                "MeshUUID":currentNetworkDataMgr.currentNetworkData.meshUUID as String
            ]
        }
        //making a post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForInvite), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForInvitationCode(notificationReponseObject:)), name: Notification.Name(kNotificationNameForInvite), object: nil)
        CloudOperationManager.sharedInstance.stWebRequest(strURL: KURL_INVITE_IN_NETWORK, parameters: parameters, viewController: self, notificationName: kNotificationNameForInvite)
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
    
    
    
    
    // MARK: CALL Login PAGE IN THE START
    func callLoginPageIfNotLogin() -> Void {
        self.backBlurView.frame = self.view.frame
        self.backBlurView.addBlurEffect()
        self.backBlurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.removeLoginView(tapGesture:))))
        (UIApplication.shared.delegate as! AppDelegate).window?.addSubview(self.backBlurView)
        
        let storyboard = UIStoryboard(name: "CloudSync", bundle: nil)
        objLoginPageViewController = storyboard.instantiateViewController(withIdentifier: "LoginPageViewController") as! LoginPageViewController
        objLoginPageViewController.delegate = self;
        
        let loginViewWidth : CGFloat = (2 * self.view.frame.size.width)/3
        let loginViewHeight : CGFloat = (2 * self.view.frame.size.height)/3
        loginView = UIView(frame: CGRect(x: self.view.frame.size.width / 6 , y: -loginViewHeight-100 , width: loginViewWidth, height: loginViewHeight))
        loginView.layoutIfNeeded()
        loginView.addSubview(objLoginPageViewController.view)
        (UIApplication.shared.delegate as! AppDelegate).window?.addSubview(loginView)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {() -> Void in
            self.loginView.frame = CGRect(x: self.view.frame.size.width / 6 , y: self.view.frame.size.height / 6 , width: loginViewWidth, height: loginViewHeight)
        }) {
            (completion) -> Void in
        }
        self.loginView.layoutIfNeeded()
    }
    
    @objc func removeLoginView(tapGesture:UITapGestureRecognizer)  {
 
        if isComingFromSideMenu{
            for sv in self.view.subviews{
                sv.alpha = 0.0
            }
            self.backBlurView.removeFromSuperview()
            self.loginView.removeFromSuperview()
            self.dismiss(animated: true) {
            }
        }
        else{
            backBlurView.removeFromSuperview()
            loginView.removeFromSuperview()
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    
    //MARK: Login Process
    @IBAction func btnSignInClicked(_ sender: Any) {
        if (userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil && ((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Login") == .orderedSame){
            self.callLoginPageIfNotLogin()
        }
        else if (((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Logout") == .orderedSame)
        {
            let alertControllerSignOut = UIAlertController(title: "", message: "Do you want to Logout?", preferredStyle: UIAlertControllerStyle.alert)
            let alertSignOutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) { (completion) in
                self.signOutProcess()
                alertControllerSignOut.dismiss(animated: true, completion: nil)
            }
            let alertCancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (completion) in
                alertControllerSignOut.dismiss(animated: true, completion: nil)
            }
            alertControllerSignOut.addAction(alertSignOutAction)
            alertControllerSignOut.addAction(alertCancelAction)
            self.present(alertControllerSignOut, animated: true, completion: nil)
        }
    }
    
    // MARK : Sign Out
    func signOutProcess() -> Void {
        let parameters: Parameters=[
            "userKey":UserDefaults.standard.value(forKey: KConstant_UserID_key)!]
        
        // Making post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSignOut), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloud(notificationReponseObject:)), name: Notification.Name(kNotificationNameForSignOut), object: nil)
        CloudOperationManager.sharedInstance.stWebRequest(strURL: KURL_USER_LOGOUT, parameters: parameters, viewController: self, notificationName: kNotificationNameForSignOut)
    }
    // MARK : Sign out Response
    @objc private func responseFromCloud(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSignOut), object: nil)
        userDefaultLoginDetails.set(nil, forKey: KConstant_UserID_key)
        UserDefaults.standard.setValue(nil, forKey: KConstant_UserID_key)
        self.btnLogin.setTitle("Login", for: .normal)
        UIView.transition(with: self.btnLogin, duration: 0.3, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        
        
        CommonUtils.showAlertToastWithColor(title: "", message: "Logout successful.", controller: self, titleColor: KConstant_SuccessfulColorCode_Key, messsageColor: .darkText, titleFontSize: 18.0, messageFontSize: 13.0, success: { (completion) in
            
        })
    }
}
//  MARK: VIEW CONTROLLER EXTENSIONS
extension CloudInteractionViewController : loginPageDelegate {
    func loginSuccessfullyCompleted() {
        
        CloudInteractionViewController.isLogin = true
        self.removeLoginView(tapGesture: UITapGestureRecognizer())
        self.btnLogin.setTitle("Logout", for: .normal)
        UIView.transition(with: self.btnLogin, duration: 0.75, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        lblUserName.isHidden = false
        lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
        appDelegate.menuViewController.lblUserName.text = lblUserName.text!

        
    }
    
    func signUpClicked() ->  Void{
        let storyboard = UIStoryboard(name: "CloudSync", bundle: nil)
        objSignUpPageViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPageViewController") as! SignUpPageViewController
        objSignUpPageViewController.delegate = self
        loginView.addSubview(objSignUpPageViewController.view)
        UIView.transition(with: self.loginView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: {(completion) -> Void in
        })
    }
    
}
extension CloudInteractionViewController : signUpDelegate {
    func signUpSuccessfullyCompleted() {
        
        CloudInteractionViewController.isLogin = true
        self.removeLoginView(tapGesture: UITapGestureRecognizer())
        self.btnLogin.setTitle("Logout", for: .normal)
        UIView.transition(with: self.btnLogin, duration: 0.75, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        lblUserName.isHidden = false
        lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
        appDelegate.menuViewController.lblUserName.text = lblUserName.text!
        appDelegate.menuViewController.lblUserName.isHidden = false
    }
    
    func signUpClosedClicked() {
        loginView.addSubview(objLoginPageViewController.view)
        UIView.transition(with: self.loginView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: {(completion) -> Void in
                            
        })
    }
}

