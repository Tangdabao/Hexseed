/**
 ******************************************************************************
 * @file    cloudOperationController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    18-May-2018
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

class CloudWebRequestHandler: NSObject {
    var actInd = UIActivityIndicatorView()
    let viewBlurEffect = UIView()
    
    static let sharedInstance : CloudWebRequestHandler = {
        let instance = CloudWebRequestHandler()
        return instance
    }()
    
    func stWebRequest(strURL : String , parameters : Parameters , viewController : UIViewController , notificationName : String , activityLoaderOnSpecificView : UIView? = nil) -> Void {
        
        let viewComponent = viewActivityIndicator.addSTActivityIndicator(onViewController: viewController)
        
        /* Making a post request */
        request(strURL, method: .post, parameters: parameters).responseJSON
            {
                
                response in
                // removing activiity Indicator and blur view
                self.viewBlurEffect.removeFromSuperview()
                self.actInd.stopAnimating()
                self.actInd.removeFromSuperview()
                viewActivityIndicator.removeSTActivityIndicator(blurBG: viewComponent.blurView, innerBG: viewComponent.activityIndicator)
                print(response)
                
                if let result = response.result.value{
                    let jsonData = result as! NSDictionary
                    do {
                        /* Status status Code */
                        let statusCode = jsonData.value(forKey:KConstant_ErrorCode_Key) as! Int
                        /* Status Message */
                        let statusMessage : String
                        if let errorMessage = jsonData.value(forKey:KConstant_ErrorMessage_Key) as? NSObject , errorMessage.isKind(of: NSNull.self) {
                            statusMessage = ""
                            print("Null in error message")
                        }
                        else if let errorMessage = jsonData.object(forKey: KConstant_ErrorMessage_Key) as? String {
                            statusMessage = errorMessage
                        }
                        else{
                            statusMessage = ""
                        }
                        /* Response messsage */
                        let responseMessage : String
                        if let responseMessageFromServer = jsonData.value(forKey:KConstant_ResponseMessage_Key) as? NSObject , responseMessageFromServer.isKind(of: NSNull.self) {
                            responseMessage = ""
                            print("Null in response message")
                        }
                        else if let responseMessageFromServer = jsonData.object(forKey: KConstant_ResponseMessage_Key) as? String {
                            responseMessage = responseMessageFromServer
                        }
                        else{
                            responseMessage = ""
                        }
                        print("Status Code:", String(statusCode) + " \t Status Message:",statusMessage + "\t Response Message:", responseMessage)
                        print("JSON Data is ",jsonData as Any)
                        
                        /* Checking on status Code basis and response message */
                        if (statusCode == 0 && responseMessage != ""){
                            /* Posting the notification */
                            self.postNotificationWithReponse(notificationName: notificationName, responseJson: jsonData , forViewController : viewController)
                        }
                        else if (statusCode > 0 && responseMessage == ""){
                            /* Error message in case of invalid credential */
                            NotificationCenter.default.removeObserver(viewController, name: Notification.Name(notificationName), object: nil)
                            
                            /* If user key is expired then if will execute */
                            if (statusMessage.caseInsensitiveCompare("Invalid User Key") == .orderedSame){
                                UserDefaults.standard.set(nil, forKey: KConstant_UserID_key)
                                UserDefaults.standard.set(nil, forKey: KConstant_UserName_key)
                                appDelegate.menuViewController.lblUserName.text = ""
                                appDelegate.menuViewController.btnLoginIn.setTitle("Login", for: .normal)
                                CommonUtils.showAlertTostMessage(title: "OOPS!", message: "Login session is expired" , controller: viewController, success: { (response) in
                                })
                            }
                            else{
                                CommonUtils.showAlertTostMessage(title: "OOPS!", message: statusMessage , controller: viewController, success: { (response) in
                                })
                                commonViewErrorHandling.createGenricErrorIn(viewcontroller: viewController, forClassType: UITextField.self , statusLabel:nil , StatusLabelText: "" )
                            }
                        }
                    }
                }
                else
                {
                    /* Error message in case of server not responding */
                    CommonUtils.showAlertTostMessage(title: "OOPS!", message: "Might be internet or server problem." , controller: viewController, success: { (completion) in
                    })
                    commonViewErrorHandling.createGenricErrorIn(viewcontroller: viewController, forClassType: UITextField.self , statusLabel:nil , StatusLabelText: KConstant_Message_ServerError )
                }
        }
    }
    
    func postNotificationWithReponse(notificationName : String , responseJson : NSDictionary , forViewController : UIViewController) -> Void {
        NotificationCenter.default.post(name: Notification.Name(notificationName) , object: responseJson)
        NotificationCenter.default.removeObserver(forViewController, name: Notification.Name(notificationName), object: nil)
    }
    
    func addActivityIndicatorOn(view : UIView) -> Void{
        /* Adding the blur effect */
        viewBlurEffect.frame = view.frame
        viewBlurEffect.addBlurEffect()
        viewBlurEffect.alpha = 0.5
        view.addSubview(viewBlurEffect)
        
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(actInd)
        actInd.startAnimating()
    }
}
