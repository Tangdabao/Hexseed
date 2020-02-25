/**
 ******************************************************************************
 * @file    ChangePasswordViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    26-June-2018
 * @brief   ViewController for "Password Change" View.
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

protocol ChangePasswordDelegate {
    func changePasswordBackClicked()
    func changePasswordSuccessful()
}


class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var txtFieldOldPassword: UITextField!
    @IBOutlet weak var txtFieldNewPassword: UITextField!
    @IBOutlet weak var txtFieldNewPasswordReconfirm: UITextField!
    var isComingFromForgotPassword : Bool = false
    var tempPasswordRetrieved : String!
    var delegate : ChangePasswordDelegate!
    @IBOutlet weak var btnBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (isComingFromForgotPassword){
            txtFieldOldPassword.text = tempPasswordRetrieved
            txtFieldOldPassword.isUserInteractionEnabled = false
        }
        btnChangePassword.addTarget(self, action: #selector(btnSubmitChangePasswordClicked(_:)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        delegate.changePasswordBackClicked()
    }
    
    @objc func btnSubmitChangePasswordClicked(_ sender: Any) {
        
        if (UserDefaults.standard.value(forKey: KConstant_UserID_key) == nil && tempPasswordRetrieved == nil){
            return
        }
        if (txtFieldNewPassword.text != txtFieldNewPasswordReconfirm.text){
            CommonUtils.showAlertTostMessage(title: "", message: "Password Mismatch" , controller: self, success: { (response) in
            })
            return
        }
        txtFieldOldPassword.resignFirstResponder()
        let parameters : Parameters = [
            "userKey" : UserDefaults.standard.value(forKey: KConstant_Temp_UserID_Key)! ,
            KConstant_OldPasswordKey : txtFieldOldPassword.text!,
            KConstant_NewPasswordKey : txtFieldNewPassword.text!,
            ]
        // Making post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForChangePassword), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForChangePassword(notificationReponseObject:)), name: Notification.Name(kNotificationNameForChangePassword), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_CHANGE_PASSWORD, parameters: parameters, viewController: self, notificationName: kNotificationNameForChangePassword)
        
    }
    
    //MARK: Submitted Answer Response
    @objc func responseFromCloudForChangePassword(notificationReponseObject : Notification) -> Void {

        CommonUtils.showAlertTostMessage(title: "", message: "Password is successfully changed." , controller: self, success: { (response) in
            self.view.removeFromSuperview()
            self.delegate.changePasswordSuccessful()
        })
    }
}
