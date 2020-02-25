/**
 ******************************************************************************
 * @file    STMeshTabBarController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    05-June-2018
 * @brief   View Controller for Tab View
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

class STMeshTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.selectedIndex = 1
        tabBar.barTintColor = UIColor.hexStringToUIColor(hex:"39A9DC")
        tabBar.unselectedItemTintColor = UIColor.hexStringToUIColor(hex:"002052")
        if (UserDefaults.standard.string(forKey: KConstantSelectedModelScreen) != nil){
            
            if let savedScreen = UserDefaults.standard.string(forKey: KConstantSelectedModelScreen){
                switch savedScreen{
                case "Generic":
                    let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"GenericModelNodeListController", type:GenericModelNodeListController.self)
                    (self.viewControllers![3] as? UINavigationController)?.setViewControllers([controller], animated:true)
                case "Vendor":
                    let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"VendorModelNodeListController", type:VendorModelNodeListController.self)
                    (self.viewControllers![3] as? UINavigationController)?.setViewControllers([controller], animated:true)
                case "Lighting":
                    let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"LightingModelNodeListController", type:LightingModelNodeListController.self)
                    (self.viewControllers![3] as? UINavigationController)?.setViewControllers([controller], animated:true)
                case kConstantSensorModelUserDefaultKey:
                    let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"SensorModelViewControllerID", type:SensorModelViewController.self)
                    (self.viewControllers![3] as? UINavigationController)?.setViewControllers([controller], animated:true)
                default:
                    break
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
        let indexValue = (selectedIndex + 1 )
        switch indexValue {
        case 1 :
            let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! MeshDeviceListViewController
            if (controller.objCurrentAlertView != nil){
                controller.objCurrentAlertView.removeAlertView()
                
            }
            
        case 2:
            let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! MeshNodeListViewController
            if (controller.objCurrentAlertView != nil){
                controller.objCurrentAlertView.removeAlertView()
                
            }
        case 3:
            let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! GroupsCollectionViewController
            if (controller.objCurrentAlertView != nil){
                controller.objCurrentAlertView.removeAlertView()
            }
        case 4:
            if (UserDefaults.standard.string(forKey: KConstantSelectedModelScreen) != nil){
                
                if let savedScreen = UserDefaults.standard.string(forKey: KConstantSelectedModelScreen){
                    switch savedScreen{
                    case "Generic":
                        let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! GenericModelNodeListController
                        if (controller.objCurrentAlertView != nil){
                            controller.objCurrentAlertView.removeAlertView()
                            
                        }
                    case "Vendor":
                        let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! VendorModelNodeListController
                        if (controller.objCurrentAlertView != nil){
                            controller.objCurrentAlertView.removeAlertView()
                            
                        }
                    case "Lighting":
                        let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! LightingModelNodeListController
                        if (controller.objCurrentAlertView != nil){
                            controller.objCurrentAlertView.removeAlertView()
                            
                        }
                    case kConstantSensorModelUserDefaultKey:
                        let controller = (self.viewControllers?[selectedIndex] as? UINavigationController)?.viewControllers[0] as! SensorModelViewController
                        if (controller.objCurrentAlertView != nil){
                            controller.objCurrentAlertView.removeAlertView()
                            
                        }
                    default:
                        break
                    }
                }
            }
            
        default:
            print("Tab Selected Index is %d", selectedIndex)
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func  updateImportData()
    {
        if let controller =  (self.viewControllers![1] as? UINavigationController)?.topViewController as? MeshNodeListViewController {
            controller.currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
            if  let node = CommonUtils.getCurrentProvisioner()
            {
                controller.manager?.createNetwork(node)
            }else{
                controller.manager?.createNetwork(10000)
            }
            
            controller.manager?.setNetworkData(controller.currentNetworkDataManager.currentNetworkData)
            controller.manager?.startNetwork(0)
        }
    }
}
