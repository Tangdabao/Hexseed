/**
 ******************************************************************************
 * @file    STMeshBaseViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    28-May-2018
 * @brief   Common base class for tab screens
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
let KConstantPrivatePolicyViewTagNumber = 20000

class STMeshBaseViewController: UIViewController {
    var objCurrentAlertView : commonAlertView!
    var objLogoutAlertView : commonAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"hamburger-menu-icon-1"), style: .plain, target: MenuViewIntializer.sharedInstance, action: #selector(MenuViewIntializer.handleMenuView))
        
        appDelegate.menuViewController.delegate = self as MenuViewControllerDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(didRotateDevice), name:.UIDeviceOrientationDidChange, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        
        
        appDelegate.menuViewController.delegate = self as MenuViewControllerDelegate
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didRotateDevice(){
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            if (UIScreen.main.bounds.size.width * 0.75 != appDelegate.menuViewController.view.frame.size.width){
                UIView.animate(withDuration: 0.25, animations: {
                    appDelegate.viewMenuVC.frame = CGRect(x:-applicationWindow.frame.size.width, y: 0, width:applicationWindow.frame.size.width , height: applicationWindow.frame.size.height)
                    appDelegate.sideMenuBlurView.alpha = 0.0
                })
                self.closeViewPrivacyPolicy()
            }
            
        case .portrait , .portraitUpsideDown:
            if (Int(UIScreen.main.bounds.size.width * 0.75) != Int(appDelegate.menuViewController.view.frame.size.width)){
                UIView.animate(withDuration: 0.25, animations: {
                    appDelegate.viewMenuVC.frame = CGRect(x:-applicationWindow.frame.size.width, y: 0, width:applicationWindow.frame.size.width , height: applicationWindow.frame.size.height)
                    appDelegate.sideMenuBlurView.alpha = 0.0
                })
                self.closeViewPrivacyPolicy()
            }
        default:
            print("")
        }
    }
}


extension STMeshBaseViewController : MenuViewControllerDelegate{
    func menuLoggerButtonClicked() {
        STLogReceiver.shareInstence.openLogScreen(viewController: self.tabBarController ?? CommonUtils.getTopNavigationController().viewControllers[0])
        
    }
    
    func createPrivacypolicyView(){
        self.closeViewPrivacyPolicy()
        let viewPrivacyPolicy = UIView(frame:CGRect(x: self.view.frame.size.width/6, y: self.view.frame.size.height/3, width: self.view.frame.size.width/1.5, height: self.view.frame.size.height/3))
        viewPrivacyPolicy.layer.cornerRadius = 5.0
        viewPrivacyPolicy.backgroundColor = UIColor.white
        viewPrivacyPolicy.layer.borderColor = UIColor.darkGray.cgColor
        viewPrivacyPolicy.layer.borderWidth = 1.0
        viewPrivacyPolicy.tag = KConstantPrivatePolicyViewTagNumber
        viewPrivacyPolicy.clipsToBounds = true
        
        let lblPolicyView = UILabel.init(frame: CGRect(x: 0, y: 0, width: viewPrivacyPolicy.frame.size.width, height: viewPrivacyPolicy.frame.size.height * 0.2))
        lblPolicyView.textColor = UIColor.white
        lblPolicyView.backgroundColor = UIColor.gray
        lblPolicyView.text = "Policy"
        lblPolicyView.font = UIFont.boldSystemFont(ofSize: 22)
        lblPolicyView.isUserInteractionEnabled = true
        lblPolicyView.textAlignment = .center
        viewPrivacyPolicy.addSubview(lblPolicyView)
        
        let lblStrip = UILabel.init(frame: CGRect(x: 0, y: viewPrivacyPolicy.frame.size.height * 0.2, width: viewPrivacyPolicy.frame.size.width, height:1))
        lblStrip.backgroundColor = UIColor.darkGray
        viewPrivacyPolicy.addSubview(lblStrip)
        
        let closeButton = UIButton.init(frame: CGRect(x: lblPolicyView.frame.size.width - lblPolicyView.frame.size.height , y: 2, width: lblPolicyView.frame.size.height - 4, height: lblPolicyView.frame.size.height - 4))
        closeButton.addTarget(self, action: #selector(closeViewPrivacyPolicy), for: .touchUpInside)
        closeButton.setImage(UIImage(named: "closeIcon"), for: .normal)
        closeButton.layer.cornerRadius = 2
        closeButton.clipsToBounds = true
        lblPolicyView.addSubview(closeButton)
        
        
        let policy = UIButton.init(frame: CGRect(x: 10 , y: viewPrivacyPolicy.frame.size.height * 0.28, width: viewPrivacyPolicy.frame.size.width - 20 , height: viewPrivacyPolicy.frame.size.height / 4))
        policy.setTitle("Privacy Policy", for: .normal)
        policy.layer.cornerRadius = 5.0
        // policy.addTarget(self, action: #selector(btnPrivacyPolicyClicked(_:)), for: .touchUpInside)
        policy.backgroundColor = UIColor.hexStringToUIColor(hex:"EBEBF1")
        policy.setTitleColor(UIColor.hexStringToUIColor(hex:"002052"), for:.normal)
        policy.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        policy.setTitleColor(UIColor.hexStringToUIColor(hex: "051652"), for: .normal)
        
        viewPrivacyPolicy.addSubview(policy)
        
        let exercise = UIButton.init(frame: CGRect(x: 10 , y: viewPrivacyPolicy.frame.size.height * 0.275 + viewPrivacyPolicy.frame.size.height / 4 + 20, width: viewPrivacyPolicy.frame.size.width - 20 , height: viewPrivacyPolicy.frame.size.height / 4))
        exercise.setTitle("Exercise Rights", for: .normal)
        exercise.layer.cornerRadius = 5.0
        //exercise.addTarget(self, action: #selector(btnExerciseYourRightsClicked(_:)), for: .touchUpInside)
        exercise.backgroundColor = UIColor.hexStringToUIColor(hex:"EBEBF1")
        exercise.setTitleColor(UIColor.hexStringToUIColor(hex:"002052"), for:.normal)
        exercise.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        exercise.setTitleColor(UIColor.hexStringToUIColor(hex: "051652"), for: .normal)
        
        viewPrivacyPolicy.addSubview(exercise)
        
        self.tabBarController?.viewControllers![(self.tabBarController?.selectedIndex)!].view.addSubview(viewPrivacyPolicy)
    }
    
    @objc func closeViewPrivacyPolicy(){
        if self.tabBarController != nil {
            for subV in (self.tabBarController?.viewControllers![(self.tabBarController?.selectedIndex)!].view.subviews)!{
                if subV.tag == KConstantPrivatePolicyViewTagNumber{
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: .transitionCrossDissolve, animations: {
                        subV.alpha = 0.0
                    }) { (completion) in
                        subV.removeFromSuperview()
                        
                    }
                    break
                }
            }
        }
    }
    
    func menuAppsettingClicked() {
        let controller = UIStoryboard.loadViewController(storyBoardName: "Main", identifierVC: "applicationSettingViewController", type: ApplicationSettingViewController.self)
        let navigationController = UINavigationController.init(rootViewController: controller)
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(dismisViewController))
        controller.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        self.tabBarController?.navigationController?.present(navigationController, animated: true, completion: {
            
        })
    }
    
    func menuExchangeConfig() {
        let controller = UIStoryboard.loadViewController(storyBoardName: "CloudSync", identifierVC: "ImportExportConfigController", type: ImportExportConfigController.self)
        
        controller.delegate = self as? ImportConfigDelegate
        
        let navigationController = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(dismisViewController))
        controller.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        
        self.tabBarController?.navigationController?.present(navigationController, animated: true, completion: {
        })
    }
    
    func menuLoginClicked(sender : Any) {
        
        if (UserDefaults.standard.value(forKey: KConstant_UserID_key) == nil && ((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Login") == .orderedSame){
            LoginSignUpManager.sharedInstance.createLoginPage(callingClassDelegate: self)
            
        }
        else if (((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Logout") == .orderedSame){ // sign Out
            
            
            let logoutButtonAction = { () ->Void in
                SignOutOperation.sharedInstance.signOutProcess(viewController: self)
            }
            
            let cancelButtonAction = { ()-> Void in
            }
            objLogoutAlertView = commonAlertView()
            objLogoutAlertView.setUpGUIAlertView(title: "", message: "Do you really want to Logout?", viewController: (tabBarController?.selectedViewController)!, firstButtonTitle: "Logout", reqSecondButton: true, secondButtonText: "Cancel", firstButtonAction: logoutButtonAction, secondButtonAction: cancelButtonAction)
        }
    }
    
    func menuPrivacyPolicyClicked() {
        
        let btnPrivacyPolicyAction = {() ->Void in
            // UIApplication.shared.open(URL.init(string: "http://www.st.com/content/st_com/en/common/privacy-policy.html")!, options: [:]) { (completion) in
            self.btnPrivacyPolicyClicked()
            //}
        }
        let btnExerciseYourRightsAction = {() ->Void in
            self.btnExerciseYourRightsClicked()
        }
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(removePrivacyAlertController(tapGesture:)))
        
        
        (((tabBarController?.selectedViewController)! as! UINavigationController).viewControllers[0]).view.addGestureRecognizer(tapGesture)
        objCurrentAlertView = commonAlertView()
        objCurrentAlertView.setUpGUIActionSheetView(title: "Policy", message: "", viewController:  (((tabBarController?.selectedViewController)! as! UINavigationController).viewControllers[0]), firstButtonTitle: "Privacy Policy", secondButtonText: "Exercise Rights", firstButtonAction: btnPrivacyPolicyAction, secondButtonAction: btnExerciseYourRightsAction)
    }
    
    @objc func removePrivacyAlertController (tapGesture : UITapGestureRecognizer){
        UIView.animate(withDuration: 0.2, animations: {
            if (self.objCurrentAlertView != nil){
                self.objCurrentAlertView.alpha = 0.0
            }
        }) { (completion) in
            if (self.objCurrentAlertView != nil){
                self.objCurrentAlertView.removeAlertView()
                self.view.removeGestureRecognizer(tapGesture)
                self.objCurrentAlertView = nil
            }
            
        }
    }
    
    func menuHelpButtonClicked() {
        let controller = UIStoryboard.loadViewController(storyBoardName: "About", identifierVC: "licenseViewController", type: LicenseViewController.self)
        controller.strPDFName = "HelpGuide"
        let navigationController = UINavigationController.init(rootViewController: controller)
        
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(dismisViewController))
        self.tabBarController?.navigationController?.present(navigationController, animated: true, completion: {
        })
    }
    
    func menuAboutButtonClicked() {
        let controller = UIStoryboard.loadViewController(storyBoardName: "About", identifierVC: "aboutView", type: AboutViewController.self)
        let navigationController = UINavigationController.init(rootViewController: controller)
        
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(dismisViewController))
        controller.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        
        self.tabBarController?.navigationController?.present(navigationController, animated: true, completion: {
            
        })
    }
    
    @objc func dismisViewController() {
        self.tabBarController?.navigationController?.dismiss(animated: true, completion: {
            
        })
        
    }
    
    func btnExerciseYourRightsClicked() {
        
        
        let controller = UIStoryboard.loadViewController(storyBoardName:"About", identifierVC: "PrivacyPolicyViewController", type: PrivacyPolicyViewController.self)
        controller.isPrivacyPage = false
        CommonUtils.getTopNavigationController().pushViewController(controller, animated: true)
        closeViewPrivacyPolicy()
    }
    
    func btnPrivacyPolicyClicked() {
        let controller = UIStoryboard.loadViewController(storyBoardName:"About", identifierVC: "PrivacyPolicyViewController", type: PrivacyPolicyViewController.self)
        controller.isPrivacyPage = true
        CommonUtils.getTopNavigationController().pushViewController(controller, animated: true)
        closeViewPrivacyPolicy()
        
    }
}


extension STMeshBaseViewController : ImportConfigDelegate{
    
    func didImportNewConfig() {
        (self.tabBarController as? STMeshTabBarController)?.updateImportData()
    }
}


extension STMeshBaseViewController : LoginAndSignUpDelegate{
    
    func removeLoginClicked() {
    }
    
    func loginSuccessful() {
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        appDelegate.menuViewController.lblUserName.isHidden = false
        appDelegate.menuViewController.lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
    }
    
    func signupSuccessful() {
        self.loginSuccessful()
    }
}


extension STMeshBaseViewController : SignOutOperationDelegate{
    
    func signOutSuccessful() {
        appDelegate.menuViewController.btnLoginIn.setTitle("Login", for: .normal)
        UIView.transition(with: appDelegate.menuViewController.btnLoginIn, duration: 0.3, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
}
