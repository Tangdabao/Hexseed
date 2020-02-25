/**
 ******************************************************************************
 * @file    RecoverPasswordViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    26-June-2018
 * @brief   ViewController for "Password Recovery" View.
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

protocol RecoverPasswordDelegate {
    func btnBackClicked() -> Void
    func retrievedPasswordCompleted() ->Void
}

class RecoverPasswordViewController: UIViewController {
    
    @IBOutlet weak var txtFieldSecurityAnswer1: UITextField!
    @IBOutlet weak var txtFieldSecurityAnswer2: UITextField!
    @IBOutlet weak var txtFieldSecurityAnswer3: UITextField!
    @IBOutlet weak var btnSubmitQuestion: UIButton!
    @IBOutlet weak var btnSubmitUserName: UIButton!
    @IBOutlet weak var textFieldSecurityAnswer3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldSecurityAnswer2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldSecurityQuestion3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldSecurityQuestion2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtFieldSecurityQuestion1: UILabel!
    @IBOutlet weak var txtFieldSecurityQuestion2: UILabel!
    @IBOutlet weak var txtFieldSecurityQuestion3: UILabel!
    @IBOutlet weak var viewUpperBar: UIView!
    @IBOutlet var viewEnterUsername: UIView!
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var scrollViewContentHeight: NSLayoutConstraint!
    @IBOutlet weak var userNameBlurBackground: UIView!
    
    var objChangePasswordViewController : ChangePasswordViewController!
    var blurView : UIView! = nil
    var delegate : RecoverPasswordDelegate!
    var userNameFilled : String = ""
    private let loginViewWidth : CGFloat = UIScreen.main.bounds.size.width
    private let loginViewHeight : CGFloat = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameBlurBackground.isHidden = false
        self.view.frame = CGRect(x: 0, y: 0, width: loginViewWidth, height: loginViewHeight)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func screenRotated() -> Void{
        if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown){
            
        }
        else if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight){
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewUpperBar.layoutIfNeeded()
        
        
        self.txtFieldSecurityQuestion1.addBlurEffect(style: .light)
        self.txtFieldSecurityQuestion2.addBlurEffect(style: .light)
        self.txtFieldSecurityQuestion3.addBlurEffect(style: .light)
        ViewConstraintHandling.createUpperView(self.viewEnterUsername, withWidthMultiplier: 0.6, withHeightMultiplier: 0.3, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: self.view)
        
        
        self.viewEnterUsername.layoutIfNeeded()
        scrollViewContentHeight.constant = screenHeight
        txtFieldSecurityAnswer1.isUserInteractionEnabled = false
        txtFieldSecurityAnswer2.isUserInteractionEnabled = false
        txtFieldSecurityAnswer3.isUserInteractionEnabled = false
        btnSubmitQuestion.isUserInteractionEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Button Username Submit Clicked
    @IBAction func btnUsernameSubmitClicked(_ sender: Any) {
        
        txtFieldUsername.resignFirstResponder()
        let parameters : Parameters = [
            "userName" : self.txtFieldUsername.text! ]        
        /* Making post request */
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForRetrieveSecurityQuestions), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudRetrievedSecurityQuestions(notificationReponseObject:)), name: Notification.Name(kNotificationNameForRetrieveSecurityQuestions), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_RETRIEVE_SECURITY_QUESTIONS, parameters: parameters, viewController: self, notificationName: kNotificationNameForRetrieveSecurityQuestions)
    }
    
    //MARK: Retrieved Questions
    @objc func responseFromCloudRetrievedSecurityQuestions(notificationReponseObject : Notification) -> Void {
        
        txtFieldSecurityAnswer1.isUserInteractionEnabled = true
        txtFieldSecurityAnswer2.isUserInteractionEnabled = true
        txtFieldSecurityAnswer3.isUserInteractionEnabled = true
        btnSubmitQuestion.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.2, animations: {
            self.userNameBlurBackground.alpha = 0.0
            self.userNameBlurBackground.isHidden = true
        }) { (completion) in
            self.userNameBlurBackground.alpha = 0.4
        }
        
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        let questionRetrievedDict = convertToDictionary(text: responseMessage) as! Dictionary<String, String>
        userNameFilled = txtFieldUsername.text!
        txtFieldSecurityQuestion1.text = questionRetrievedDict[KConstant_RetrievedFirstQuestionKey]
        if (questionRetrievedDict[KConstant_RetrievedSecondQuestionKey]?.caseInsensitiveCompare("") != .orderedSame){
            txtFieldSecurityQuestion2.text = questionRetrievedDict[KConstant_RetrievedSecondQuestionKey]
            
        }
        else{
            self.textFieldSecurityQuestion2HeightConstraint.constant = -self.txtFieldSecurityQuestion2.frame.size.height
            self.textFieldSecurityAnswer2HeightConstraint.constant = -self.txtFieldSecurityAnswer2.frame.size.height
            
        }
        
        if (questionRetrievedDict[KConstant_RetrievedThirdQuestionKey]?.caseInsensitiveCompare("") != .orderedSame){
            txtFieldSecurityQuestion3.text = questionRetrievedDict[KConstant_RetrievedThirdQuestionKey]
            
        }
        else{
            self.textFieldSecurityQuestion3HeightConstraint.constant = -self.txtFieldSecurityQuestion3.frame.size.height
            self.textFieldSecurityAnswer3HeightConstraint.constant = -self.txtFieldSecurityAnswer3.frame.size.height
            
        }
        self.restoreViewVisuals()
        
    }
    func restoreViewVisuals() -> Void {
        UIView.animate(withDuration: 0.1, animations: {
            self.viewEnterUsername.alpha = 0.0
            self.txtFieldSecurityQuestion1.removeBlurEffect()
            self.txtFieldSecurityQuestion2.removeBlurEffect()
            self.txtFieldSecurityQuestion3.removeBlurEffect()
        }) { (completion) in
            self.viewEnterUsername.removeFromSuperview()
            
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    //MARK: Button Submit Answers Clicked
    @IBAction func btnSubmitClicked(_ sender: Any) {
        txtFieldSecurityAnswer3.resignFirstResponder()
        txtFieldSecurityAnswer2.resignFirstResponder()
        txtFieldSecurityAnswer1.resignFirstResponder()
        let parameters : Parameters = [
            "userName" : txtFieldUsername.text! ,
            KConstant_FirstPasswordKey : txtFieldSecurityAnswer1.text!,
            KConstant_SecondPasswordKey : txtFieldSecurityAnswer2.text!,
            KConstant_ThirdPasswordKey : txtFieldSecurityAnswer3.text!
        ]
        /* Making post request */
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSubmitSecurityQuestions), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudSubmitSecurityQuestions(notificationReponseObject:)), name: Notification.Name(kNotificationNameForSubmitSecurityQuestions), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_SUBMIT_SECURITY_QUESTIONS, parameters: parameters, viewController: self, notificationName: kNotificationNameForSubmitSecurityQuestions)
    }
    
    //MARK: Submitted Answer Response
    @objc func responseFromCloudSubmitSecurityQuestions(notificationReponseObject : Notification) -> Void {
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        let responseTempPassword = convertToDictionary(text: responseMessage) as! Dictionary<String, String>
        
        print("Temp password" , responseTempPassword["tempPassword"]!)
        print("Session key" , responseTempPassword["sessionKey"]!)
        
        UserDefaults.standard.set(responseTempPassword["sessionKey"]!, forKey: KConstant_Temp_UserID_Key)
        UserDefaults.standard.set(txtFieldUsername.text!, forKey: KConstant_UserName_key)
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        appDelegate.menuViewController.lblUserName.isHidden = false
        appDelegate.menuViewController.lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
        self.createChangePasswordView(tempPassword: responseTempPassword["tempPassword"]!)
    }
    
    func createChangePasswordView(tempPassword : String) -> Void{
        let loginViewWidth : CGFloat = UIScreen.main.bounds.size.width
        let loginViewHeight : CGFloat = UIScreen.main.bounds.size.height
        let storyboard = UIStoryboard(name: "CloudSync", bundle: nil)
        objChangePasswordViewController = storyboard.instantiateViewController(withIdentifier: "changePasswordViewController") as? ChangePasswordViewController
        objChangePasswordViewController.isComingFromForgotPassword = true
        objChangePasswordViewController.delegate = self as ChangePasswordDelegate
        objChangePasswordViewController.tempPasswordRetrieved = tempPassword
        objChangePasswordViewController.view.frame = CGRect(x: 0 , y: 0 , width: loginViewWidth, height: loginViewHeight)
        objChangePasswordViewController.view.layoutIfNeeded()
        
        self.view.addSubview(objChangePasswordViewController.view)
        UIView.transition(with: self.view,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: {(completion) -> Void in
        })
    }
    
    //MARK Button Back Clicked
    @IBAction func btnBackClicked(_ sender: Any) {
        self.delegate.btnBackClicked()
    }
    
    func createViewConstraint(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withTopSpaceConstraint YCordinate: CGFloat,respectedTopView topView : UIView, withRespectTo Respectedview: UIView?) {
        
        Respectedview?.addSubview(viewToCreate!)
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0))
        
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .top, relatedBy: .equal, toItem: topView, attribute: .top, multiplier: CGFloat(YCordinate), constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: 0))
        viewToCreate?.layoutIfNeeded()
    }
}


// MARK: Text Field Delegate
extension RecoverPasswordViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension RecoverPasswordViewController : ChangePasswordDelegate{
    func changePasswordBackClicked() {
        self.delegate.btnBackClicked()
    }
    
    func changePasswordSuccessful() {
        self.delegate.btnBackClicked()
        
    }
}
