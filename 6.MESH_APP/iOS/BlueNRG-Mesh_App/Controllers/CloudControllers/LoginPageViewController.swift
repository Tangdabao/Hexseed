/**
 ******************************************************************************
 * @file    LoginPageViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    09-Apr-2018
 * @brief   ViewController for the "Login" View.
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
let userDefaultLoginDetails = UserDefaults.standard

protocol loginPageDelegate {
    func loginSuccessfullyCompleted() ->  Void
    func signUpClicked() ->  Void;
    func forgotPassWordClicked() -> Void
    func closeLoginController() -> Void
    
}


class LoginPageViewController: UIViewController {
    
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    //    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var btnLoginClicked: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnKeepMeLogIn: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    
    var delegate : loginPageDelegate!
    
    var objChangePasswordViewController : ChangePasswordViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.title = "Login"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        self.scrollViewContentHeight.constant = screenHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Buttons Touch Up Inside
    @IBAction func btnSignUpClicked(_ sender: Any) {
        self.delegate.signUpClicked()
        
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        self.delegate.closeLoginController()
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        
        /* Getting the username and password */
        let parameters: Parameters=[
            "lUserName":textFieldUserName.text!,
            "lPassword":textFieldPassword.text!,
            "staySignedInFlag": btnKeepMeLogIn.isSelected
        ]
        
        /*  Making Post request */
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForLoginUser), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloud(notificationReponseObject:)), name: Notification.Name(kNotificationNameForLoginUser), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_USER_LOGIN, parameters: parameters, viewController: self, notificationName: kNotificationNameForLoginUser)
    }
    
    @objc private func responseFromCloud(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForLoginUser), object: nil)
        
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        UserDefaults.standard.set(responseMessage, forKey: KConstant_UserID_key)
        UserDefaults.standard.set(textFieldUserName.text, forKey: KConstant_UserName_key)
        
        CommonUtils.showAlertToastWithColor(title: "", message: "Successfully logged in.", controller: self, titleColor: KConstant_SuccessfulColorCode_Key, messsageColor: .darkText, titleFontSize: 18.0, messageFontSize: 13.0, success: { (completion) in
            self.delegate.loginSuccessfullyCompleted()
            self.navigationController?.popViewController(animated: true)
            
        })
    }
    
    func showErrorMessage() -> Void {
        //        self.lblLoginStatus.alpha = 1.0
        self.textFieldUserName.layer.borderWidth = 1.25
        self.textFieldPassword.layer.borderWidth = 1.25
        self.textFieldUserName.layer.borderColor = UIColor.red.cgColor
        self.textFieldPassword.layer.borderColor = UIColor.red.cgColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(int_fast64_t(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            self.removeErrorNotation()
        })
    }
    
    func removeErrorNotation() -> Void {
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            //            self.lblLoginStatus.alpha = 0.0
            self.textFieldUserName.layer.borderWidth = 0.0
            self.textFieldPassword.layer.borderWidth = 0.0
            self.textFieldUserName.layer.borderColor = UIColor.clear.cgColor
            self.textFieldPassword.layer.borderColor = UIColor.clear.cgColor
        }, completion: {(_ b: Bool) -> Void in
            
            self.view.layoutIfNeeded()
        })
    }
    
    /* attributed Text */
    func addAttributesToText(text:String , bold:Bool , Underline:Bool , textColor:UIColor , italics:Bool) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: text)
        if (bold){
            let attrs:[NSAttributedStringKey:Any] = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 18)!]
            attributedString.addAttributes(attrs, range: NSRange(location: 0, length: text.count))
        }
        if(Underline){
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: text.count))
        }
        
        attributedString.textColor(text, color: textColor)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.paragraphStyle: paragraph]
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.count))
        return attributedString
        
    }
    
    @IBAction func btnKeepMeLoggedInClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func btnForgotPasswordClicked(_ sender: Any) {
        
        self.delegate.forgotPassWordClicked()
    }
    
    @IBAction func btnChangePasswordClicked(_ sender: Any) {
        
        LoginSignUpManager.sharedInstance.backBlurView.removeFromSuperview()
        LoginSignUpManager.sharedInstance.loginView.alpha = 0.0
    }
}

// MARK : NSMutbaleAttributedString Extension
extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[NSAttributedStringKey:Any] = [ NSAttributedStringKey.font: UIFont(name: "AvenirNext-Medium", size: 12)!]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
    
    @discardableResult func underline(_ text:String)->NSMutableAttributedString {
        let underline = NSMutableAttributedString(string: text)
        underline.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedStringKey, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: underline.length - 1))
        self.append(underline)
        return self
    }
    @discardableResult func textColor(_ text:String , color:UIColor)->NSMutableAttributedString {
        let color = NSMutableAttributedString(string: text)
        color.addAttribute(NSAttributedStringKey.foregroundColor as NSAttributedStringKey,value: color, range: NSRange(location: 0, length: color.length - 1))
        self.append(color)
        return self
    }
}

/* Called when 'return' key pressed. return NO to ignore. */
extension LoginPageViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
}
