/**
 ******************************************************************************
 * @file    LoginSignupManager.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    14-June-2018
 * @brief   Class to handle sign-up operation.
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

protocol LoginAndSignUpDelegate {
    func removeLoginClicked()
    func loginSuccessful()
    func signupSuccessful()
    
}

class LoginSignUpManager: NSObject {
    var backBlurView = UIView()
    var objLoginPageViewController : LoginPageViewController!
    var objSignUpPageViewController : SignUpPageViewController!
    var objRecoveredPasswordViewController : RecoverPasswordViewController!
    let loginViewWidth : CGFloat = UIScreen.main.bounds.size.width
    let loginViewHeight : CGFloat =  UIScreen.main.bounds.size.height
    var loginView : UIView!
    var signUp : UIView!
    let isComingFromSideMenu : Bool! = false
    var delegate : LoginAndSignUpDelegate!
    var alertHeightConstraint : NSLayoutConstraint!
    var alertYPositionConstraint : NSLayoutConstraint!
    
    static let sharedInstance : LoginSignUpManager = {
        let instance = LoginSignUpManager()
        return instance
    }()
    
    @objc func screenRotated() -> Void{
        if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown){
            
            alertYPositionConstraint.constant = UIApplication.shared.statusBarFrame.size.height
        }
        else if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight){
            
            alertYPositionConstraint.constant = 0
        }
    }
    
    func createLoginPage(callingClassDelegate : UIViewController) -> Void {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.delegate = callingClassDelegate as? LoginAndSignUpDelegate
        self.backBlurView.frame = (appDelegate.window?.frame)!
        self.backBlurView.backgroundColor = UIColor.lightGray
        self.backBlurView.alpha = 0.75
        
        
        let storyboard = UIStoryboard(name: "CloudSync", bundle: nil)
        objLoginPageViewController = storyboard.instantiateViewController(withIdentifier: "LoginPageViewController") as? LoginPageViewController
        objLoginPageViewController.delegate = self
        
        
        loginView = UIView()
        (UIApplication.shared.delegate as! AppDelegate).window?.addSubview(loginView)
        
        //        callingClassDelegate.view.addSubview(loginView)
        self.createViewWithConstraint(loginView, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: (UIApplication.shared.delegate as! AppDelegate).window)
        
        loginView.layoutIfNeeded()
        
        loginView.addSubview(objLoginPageViewController.view)
        self.createUpperView(objLoginPageViewController.view, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: loginView)
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {() -> Void in
            self.alertYPositionConstraint.constant = UIApplication.shared.statusBarFrame.size.height
            
        }) {
            (completion) -> Void in
            self.loginView.layoutIfNeeded()
            
        }
    }
    
    @objc func removeLoginView()  {
        backBlurView.removeFromSuperview()
        loginView.removeFromSuperview()
        if self.delegate != nil{
            self.delegate.removeLoginClicked()
        }
    }
    
    func createUpperView(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withYCordinateMultiplier YCordinate: CGFloat, withRespectTo Respectedview: UIView?) {
        Respectedview?.addSubview(viewToCreate!)
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0))
        
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: 0))
        viewToCreate?.layoutIfNeeded()
    }
    
    func createViewWithConstraint(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withYCordinateMultiplier YCordinate: CGFloat, withRespectTo Respectedview: UIView?) {
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        alertHeightConstraint = NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0)
        let alertWidthConstraint = NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0) as NSLayoutConstraint
        
        Respectedview?.addConstraint(alertWidthConstraint)
        Respectedview?.addConstraint(alertHeightConstraint)
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        
        let YPositionValue = -CGFloat(100) - (appDelegate.window?.frame.size.height)! - UIApplication.shared.statusBarFrame.size.height
        alertYPositionConstraint = NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: YPositionValue)
        Respectedview?.addConstraint(alertYPositionConstraint)
        
        viewToCreate?.layoutIfNeeded()
    }
}


//  MARK: VIEW CONTROLLER EXTENSIONS
extension LoginSignUpManager : loginPageDelegate {
    func closeLoginController() {
        self.removeLoginView()
    }
    
    func forgotPassWordClicked() {
        let storyboard = UIStoryboard(name: "CloudSync", bundle: nil)
        objRecoveredPasswordViewController = storyboard.instantiateViewController(withIdentifier: "recoverPasswordID") as? RecoverPasswordViewController
        //        objRecoveredPasswordViewController.view.frame = CGRect(x: 0, y: 0, width: loginViewWidth, height: loginViewHeight)
        objRecoveredPasswordViewController.delegate = self
        
        loginView.addSubview(objRecoveredPasswordViewController.view)
        self.createUpperView(objRecoveredPasswordViewController.view, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: loginView)
        UIView.transition(with: self.loginView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: {(completion) -> Void in
        })
        
    }
    
    func loginSuccessfullyCompleted() {
        
        if self.delegate != nil{
            self.delegate.loginSuccessful()
        }
        self.delegate = nil
        
        self.removeLoginView()
        
        
    }
    
    func signUpClicked() ->  Void{
        let storyboard = UIStoryboard(name: "CloudSync", bundle: nil)
        objSignUpPageViewController = storyboard.instantiateViewController(withIdentifier: "SignUpPageViewController") as? SignUpPageViewController
        objSignUpPageViewController.delegate = self
        //        objSignUpPageViewController.view.frame = CGRect(x: 0, y: 0, width: loginViewWidth, height: loginViewHeight)
        loginView.addSubview(objSignUpPageViewController.view)
        self.createUpperView(objSignUpPageViewController.view, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: loginView)
        UIView.transition(with: self.loginView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: {(completion) -> Void in
        })
    }
    
}

extension LoginSignUpManager : signUpDelegate {
    func signUpSuccessfullyCompleted() {
        
        if self.delegate != nil{
            self.delegate.signupSuccessful()
        }
        self.delegate = nil
        
        if isComingFromSideMenu{
            
        }
        self.removeLoginView()
        
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


extension LoginSignUpManager : RecoverPasswordDelegate{
    func retrievedPasswordCompleted() {
        
    }
    
    func btnBackClicked() {
        loginView.addSubview(objLoginPageViewController.view)
        UIView.transition(with: self.loginView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: {(completion) -> Void in
                            
        })
    }
}
