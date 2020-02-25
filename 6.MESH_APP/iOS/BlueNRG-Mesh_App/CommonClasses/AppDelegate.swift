/**
 ******************************************************************************
 * @file    AppDelegate.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    10-Jul-2017
 * @brief   App delegate class
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
import CoreData
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let sideMenuBlurView = UIView()
    let viewMenuVC = UIView()
    var menuViewController : MenuViewController!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /* Fabric initialization */
        Fabric.with([Crashlytics.self])
        
        //self.addSideMenuButton(application: application)
        self.creatingSideMenu()
        return true
    }
    
    func creatingSideMenu(){
        viewMenuVC.frame = CGRect(x: -applicationWindow.frame.size.width, y: 0, width:applicationWindow.frame.size.width * 0.75 , height: applicationWindow.frame.size.height)
        
        sideMenuBlurView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height, width:self.window!.frame.size.width  , height: self.window!.frame.size.height)
        sideMenuBlurView.addBlurEffect(style: .dark)
        sideMenuBlurView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleSideMenuGesture)))
        self.window!.addSubview(sideMenuBlurView)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        menuViewController = storyboard.instantiateViewController(withIdentifier :"menuViewController") as? MenuViewController
        menuViewController.view.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height, width:applicationWindow.frame.size.width * 0.75 , height: applicationWindow.frame.size.height)
        menuViewController.view.isUserInteractionEnabled = true
        viewMenuVC.addSubview(menuViewController.view)
        self.window!.addSubview(viewMenuVC)
    }
    
    @objc func handleSideMenuGesture() -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            appDelegate.viewMenuVC.frame = CGRect(x:-applicationWindow.frame.size.width, y: 0, width:applicationWindow.frame.size.width * 0.75, height: applicationWindow.frame.size.height)
            appDelegate.sideMenuBlurView.alpha = 0.0
        }) { (completion) in
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.st.bluenrg-mesh-App.notifications.will_enter_background"),
                                        object: nil, userInfo: nil)
        
        if UIApplication.topViewController() != nil {
            //do sth with root view controller
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "com.st.bluenrg-mesh-App.notifications.became_active"),
                                        object: nil, userInfo: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        let meshManager = STMeshManager.getInstance(nil)
        meshManager?.stopNetwork()
        
        UserDefaults.standard.set(nil, forKey: kConstantSensorModel_AccelerometerValue)
        UserDefaults.standard.set(nil, forKey: kConstantSensorModel_PressureValue)
        UserDefaults.standard.set(nil, forKey: kConstantSensorModel_TemperatureValue)

         STCustomEventLogClass.sharedInstance.STEvent_ProvisioningFailed()
        
    }
    
}


extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

