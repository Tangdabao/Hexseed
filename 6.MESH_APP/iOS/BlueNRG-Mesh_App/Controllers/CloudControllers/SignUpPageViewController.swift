/**
 ******************************************************************************
 * @file    SignUpPageViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    10-Apr-2018
 * @brief   ViewController for the "Sign-Up" View.
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

protocol signUpDelegate {
    func signUpSuccessfullyCompleted() ->  Void;
    func signUpClosedClicked() ->  Void;
}


class SignUpPageViewController: UIViewController {
    
    //The login script url make sure to write the ip instead of localhost
    //you can get the ip using ifconfig command in terminal
    
    /* The defaultvalues to store user data */
    let defaultUserValues = UserDefaults.standard
    var delegate : signUpDelegate!
    @IBOutlet weak var textFieldSignUpUserName: UITextField!
    @IBOutlet weak var textFieldSignUpPassword: UITextField!
    //    @IBOutlet weak var textFieldSignUpEmailID: UITextField!
    @IBOutlet weak var lblCreateUserStatus: UILabel!
    @IBOutlet weak var txtFieldConfirmPassword: UITextField!
    @IBOutlet weak var txtFieldSecurityQuestion1: UITextField!
    @IBOutlet weak var txtFieldAnswer1: UITextField!
    @IBOutlet weak var txtFieldSecurityQuestion2: UITextField!
    @IBOutlet weak var txtFieldAnswer2: UITextField!
    @IBOutlet weak var txtFieldSecurityQuestion3: UITextField!
    @IBOutlet weak var txtFieldAnswer3: UITextField!
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.title = "Sign up"
        // Do any additional setup after loading the view.
        scrollViewContentHeight.constant = screenHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Button sign up page closed */
    @IBAction func btnNotNowClicked(_ sender: Any) {
        self.delegate.signUpClosedClicked()
    }
    /* Sign up button pressed*/
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        self.removeErrorNotation()
        if(!self.textFieldValidation() ) {
            return
        }
        
        /* Getting the username and password */
        let parameters: Parameters=[
            "Username":textFieldSignUpUserName.text!,
            "password":textFieldSignUpPassword.text!,
            "Email":"rasta@gmail.com"
        ]
        
        /* Making post request */
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSignUp), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloud(notificationReponseObject:)), name: Notification.Name(kNotificationNameForSignUp), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_USER_CREATE, parameters: parameters, viewController: self, notificationName: kNotificationNameForSignUp)
    }
    
    // MARK: Response for Signup=
    @objc private func responseFromCloud(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSignUp), object: nil)
        
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        
        
        UserDefaults.standard.set(responseMessage, forKey: KConstant_UserID_key)
        UserDefaults.standard.set(textFieldSignUpUserName.text, forKey: KConstant_UserName_key)
        self.registeringSecurityQuestions()
        
    }
    
    //MARK: Registering Security Questions
    func registeringSecurityQuestions() -> Void {
        
        let parameters: Parameters=[
            
            
            "Username":textFieldSignUpUserName.text!,
            "firstQuestion":txtFieldSecurityQuestion1.text!,
            "secondQuestion":txtFieldSecurityQuestion2.text?.caseInsensitiveCompare("") != .orderedSame ? txtFieldSecurityQuestion2.text! : "",
            "thirdQuestion":txtFieldSecurityQuestion3.text?.caseInsensitiveCompare("") != .orderedSame ? txtFieldSecurityQuestion3.text! : "",
            "firstPassword":txtFieldAnswer1.text!,
            "secondPassword":txtFieldAnswer2.text?.caseInsensitiveCompare("") != .orderedSame ? txtFieldAnswer2.text! : "",
            "thirdPassword":txtFieldAnswer3.text?.caseInsensitiveCompare("") != .orderedSame ? txtFieldAnswer3.text! : "",
            ]
        // Making post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForRegisterSecurityQuestions), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForSecurityQuestions(notificationReponseObject:)), name: Notification.Name(kNotificationNameForRegisterSecurityQuestions), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_REGISTER_SECURITY_QUESTIONS, parameters: parameters, viewController: self, notificationName: kNotificationNameForRegisterSecurityQuestions)
    }
    
    // MARK: Response for Security Questions
    @objc private func responseFromCloudForSecurityQuestions(notificationReponseObject : Notification) -> Void {
        
        CommonUtils.showAlertToastWithColor(title: "", message: "Sign up successful.", controller: self, titleColor: KConstant_SuccessfulColorCode_Key, messsageColor: .darkText, titleFontSize: 18.0, messageFontSize: 13.0, success: { (completion) in })
        self.delegate.signUpSuccessfullyCompleted()
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    /* Showing Error Messages*/
    func showErrorMessage(errorText:String) -> Void {
        
        self.lblCreateUserStatus.text = errorText
        self.lblCreateUserStatus.alpha = 1.0
        self.textFieldSignUpUserName.layer.borderWidth = 1.25
        self.textFieldSignUpPassword.layer.borderWidth = 1.25
        //        self.textFieldSignUpEmailID.layer.borderWidth = 1.25
        self.textFieldSignUpUserName.layer.borderColor = UIColor.red.cgColor
        self.textFieldSignUpPassword.layer.borderColor = UIColor.red.cgColor
        //        self.textFieldSignUpEmailID.layer.borderColor = UIColor.red.cgColor
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(int_fast64_t(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            
            self.removeErrorNotation()
        })
        
    }
    
    /* Remove Error Notation */
    func removeErrorNotation() -> Void {
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.lblCreateUserStatus.text = ""
            self.lblCreateUserStatus.alpha = 0.0
            self.textFieldSignUpUserName.layer.borderWidth = 0
            self.textFieldSignUpPassword.layer.borderWidth = 0
            //            self.textFieldSignUpEmailID.layer.borderWidth = 0
            self.textFieldSignUpUserName.layer.borderColor = UIColor.clear.cgColor
            self.textFieldSignUpPassword.layer.borderColor = UIColor.clear.cgColor
            //            self.textFieldSignUpEmailID.layer.borderColor = UIColor.clear.cgColor
        }, completion: {(_ b: Bool) -> Void in
            
            self.view.layoutIfNeeded()
        })
    }
    
    /* Checking the email is valid */
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    /* Checking the all field Validation */
    func textFieldValidation() -> Bool {
        if ((textFieldSignUpUserName.text?.count)! < 4){
            CommonUtils.showAlertTostMessage(title: "", message: KConstant_Message_UserName_Length_Check, controller: self) { (completion) in
                
            }
            //            self.textFieldSignUpUserName.layer.borderWidth = 1.25
            //            self.textFieldSignUpUserName.layer.borderColor = UIColor.red.cgColor
            return false
        }
        /* Sign up password length check */
        if ((textFieldSignUpPassword.text?.count)! < 4){
            CommonUtils.showAlertTostMessage(title: "", message: KConstant_Message_Password_Length_Check, controller: self) { (completion) in
                
            }
            self.textFieldSignUpPassword.layer.borderWidth = 1.25
            self.textFieldSignUpPassword.layer.borderColor = UIColor.red.cgColor
            return false
            
        }
        
        /* pasword mismatch */
        if (textFieldSignUpPassword.text != txtFieldConfirmPassword.text){
            
            CommonUtils.showAlertTostMessage(title: "", message: KConstant_Message_Passwod_Reconfirm_Mismatch, controller: self) { (completion) in
            }
            return false
        }
        
        /* Question length */
        if ((txtFieldSecurityQuestion1.text?.count)! < 5){
            CommonUtils.showAlertTostMessage(title: "", message: KConstant_Message_Same_Security_Question_Length_Check, controller: self) { (completion) in
            }
            return false
        }
        
        /* Question text match in each question */
        if (txtFieldSecurityQuestion1.text == ((txtFieldSecurityQuestion2.text != nil) ? txtFieldSecurityQuestion2.text! : "" ) || txtFieldSecurityQuestion1.text == ((txtFieldSecurityQuestion3.text != nil) ? txtFieldSecurityQuestion3.text! : "" )  ){
            
            CommonUtils.showAlertTostMessage(title: "", message: KConstant_Message_Same_Security_Question, controller: self) { (completion) in
            }
            return false
        }
        
        /* Answer field check */
        if ((txtFieldAnswer1.text?.count)! < 4){
            CommonUtils.showAlertTostMessage(title: "", message:KConstant_Message_Same_Security_Answer_Length_Check, controller: self) { (completion) in
            }
            return false
        }
        if (txtFieldSecurityQuestion1.text != nil){
            if (txtFieldAnswer1 == nil){
                return false
            }
            
        }
        if (txtFieldSecurityQuestion2.text != nil){
            if (txtFieldAnswer2 == nil){
                return false
            }
        }
        if (txtFieldSecurityQuestion3.text != nil){
            if (txtFieldAnswer3 == nil){
                return false
            }
        }
        return true
    }
}


extension SignUpPageViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}
