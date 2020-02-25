/**
 ******************************************************************************
 * @file    MenuViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    30-May-2018
 * @brief   ViewController for the side menu.
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

protocol MenuViewControllerDelegate {
    func menuAboutButtonClicked()
    func menuHelpButtonClicked()
    func menuPrivacyPolicyClicked()
    func menuLoginClicked(sender : Any)
    func menuExchangeConfig()
    func menuAppsettingClicked()
    func menuLoggerButtonClicked()
}
class MenuViewController: UIViewController {
    
    
    @IBOutlet weak var viewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var switchproxyUsingNodeIdentity: UISwitch!
    @IBOutlet weak var switchUseReliableMessages: UISwitch!
    @IBOutlet weak var switcgDefaultVendorModel: UISwitch!
    @IBOutlet weak var btnLoginIn: UIButton!
    @IBOutlet weak var btnExchangeMeshConfiguration: UIButton!
    @IBOutlet weak var btnAbout: UIButton!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var btnAppSettings: UIButton!
    var delegate : MenuViewControllerDelegate!
    @IBOutlet weak var scrollViewInnerViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        /* User Name */
        lblUserName.isHidden = true
        if ((UserDefaults.standard.value(forKey: KConstant_UserID_key)) != nil ){
            
            if let userName = UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String {
                lblUserName.isHidden = false
                lblUserName.text = String(format: "Welcome  " + "\"" + userName + "\"")
                lblUserName.isHidden = false
                self.btnLoginIn.setTitle("Logout", for: .normal)
                
            }
            
        }
        else{
            self.btnLoginIn.setTitle("Login", for: .normal)
        }
        
        /* Setting the last value stored in user default for Proxy connection Node Identity Command */
        
        if UserDefaults.standard.bool(forKey: KConstantReliableModeKey){
            switchUseReliableMessages.isOn = true
        }
        else{
            switchUseReliableMessages.isOn = false
        }
        if UserDefaults.standard.bool(forKey: KConstantProxyConnectionNodeIdentityModeKey){
            switchproxyUsingNodeIdentity.isOn = false
        }
        else{
            switchproxyUsingNodeIdentity.isOn = true
        }
        
        if UserDefaults.standard.bool(forKey: KConstantModeKey){
            switcgDefaultVendorModel.isOn = true
        }
        else{
            switcgDefaultVendorModel.isOn = false
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnLoginIn.imageView?.contentMode = .scaleAspectFit
        btnLoginIn.titleEdgeInsets = UIEdgeInsetsMake(0, -btnLoginIn.frame.size.width / 4, 0, 0)
        btnLoginIn.imageEdgeInsets = UIEdgeInsetsMake(0, -btnLoginIn.frame.size.width/2, 0, 0)
        viewHeightConst.constant  = screenHeight > 736 ? screenHeight-20:736
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Did rotate on changing the orientation of current device */
    var didRotate: (Notification ) -> Void = { notification in
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            
            MenuViewIntializer.init().handleGesture(tapGesture: UITapGestureRecognizer())
        case .portrait, .portraitUpsideDown:
            MenuViewIntializer.init().handleGesture(tapGesture: UITapGestureRecognizer())
        default:
            print("")
        }
    }
    @IBAction func switchNodeIdentityStateChanged(_ sender: Any) {
        if switchproxyUsingNodeIdentity.isOn{
            /* Set the Proxy Connection Node Identity */
            UserDefaults.standard.set(false, forKey: KConstantProxyConnectionNodeIdentityModeKey)
        }
        else{
            /* Unset the proxy Connection Node Identity */
            UserDefaults.standard.set(true, forKey: KConstantProxyConnectionNodeIdentityModeKey)
        }
    }
    
    
    @IBAction func vendorModelSwitchStateChanged(_ sender: Any) {
        print("switch Clicked ")
        if switcgDefaultVendorModel.isOn{
            /* Set Reliable Variable */
            UserDefaults.standard.set(true, forKey: KConstantModeKey)
        }
        else{
            /* Unset Reliable variable */
            UserDefaults.standard.set(false, forKey: KConstantModeKey)
        }
        
    }
    @IBAction func useReliableMessagesStateChanged(_ sender: Any) {
        /* If switch state is on then send the reliable commands and set the Reliable bool variable true */
        if switchUseReliableMessages.isOn{
            /* Set Reliable Variable */
            UserDefaults.standard.set(true, forKey: KConstantReliableModeKey)
        }
        else{
            /* Unset Reliable variable */
            UserDefaults.standard.set(false, forKey: KConstantReliableModeKey)
        }
    }
    
    @IBAction func btnAppSettinsClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        self.delegate.menuAppsettingClicked()
    }
    
    
    @IBAction func btnExhangeMeshConfigurationClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        self.delegate.menuExchangeConfig()
        
    }
    @IBAction func btnAboutClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        self.delegate.menuAboutButtonClicked()
    }
    @IBAction func btnHelpClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        delegate.menuHelpButtonClicked()
        
    }
    
    @IBAction func btnPrivacyPolicyClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        delegate.menuPrivacyPolicyClicked()
    }
    
    @IBAction func btnLoggerClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        delegate.menuLoggerButtonClicked()
    }
    
    //MARK: Login Clicked
    @IBAction func btnLoginClicked(_ sender: Any) {
        appDelegate.handleSideMenuGesture()
        
        self.delegate.menuLoginClicked(sender : sender)
        
    }
    
}
