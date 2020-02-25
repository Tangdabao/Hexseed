/**
 ******************************************************************************
 * @file    SignOutOperation.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    16-June-2018
 * @brief   Class to handle sign-out operation.
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

protocol SignOutOperationDelegate {
    func signOutSuccessful() -> Void
}


class SignOutOperation: NSObject {
    var currentViewController : UIViewController?
    static let sharedInstance : SignOutOperation = {
        let instance = SignOutOperation()
        return instance
    }()
    var delegate : SignOutOperationDelegate!
    
    func alertBeforeSignOut(viewControllerInstance : UIViewController) -> Void {
        currentViewController = viewControllerInstance
        
        let alertControllerSignOut = UIAlertController(title: "", message: "Do you want to Logout?", preferredStyle: UIAlertControllerStyle.alert)
        let alertSignOutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) { (completion) in
            self.signOutProcess(viewController: viewControllerInstance)
            alertControllerSignOut.dismiss(animated: true, completion: nil)
        }
        let alertCancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (completion) in
            alertControllerSignOut.dismiss(animated: true, completion: nil)
        }
        alertControllerSignOut.addAction(alertSignOutAction)
        alertControllerSignOut.addAction(alertCancelAction)
        currentViewController?.present(alertControllerSignOut, animated: true, completion: nil)
    }
    
    func signOutProcess(viewController : UIViewController) -> Void {
        currentViewController = viewController
        self.delegate = (currentViewController as! SignOutOperationDelegate)
        let parameters: Parameters=[
            "userKey":UserDefaults.standard.value(forKey: KConstant_UserID_key) as! String]
        
        // Making post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSignOut), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloud(notificationReponseObject:)), name: Notification.Name(kNotificationNameForSignOut), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_USER_LOGOUT, parameters: parameters, viewController: currentViewController!, notificationName: kNotificationNameForSignOut)
    }
    
    // MARK : Sign out Response
    @objc private func responseFromCloud(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForSignOut), object: nil)
        UserDefaults.standard.setValue(nil, forKey: KConstant_UserID_key)
        UserDefaults.standard.setValue(nil, forKey: KConstant_UserName_key)
        appDelegate.menuViewController.lblUserName.text = ""
        appDelegate.menuViewController.lblUserName.isHidden = true
        appDelegate.menuViewController.btnLoginIn.setTitle("Login", for: .normal)
        self.delegate .signOutSuccessful()
        
        
        CommonUtils.showAlertToastWithColor(title: "", message: "Logout successful.", controller: currentViewController!, titleColor: KConstant_SuccessfulColorCode_Key, messsageColor: .darkText, titleFontSize: 18.0, messageFontSize: 13.0, success: { (completion) in
            
        })
    }
}
