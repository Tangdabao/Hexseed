/**
 ******************************************************************************
 * @file    AboutViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    17-Nov-2017
 * @brief   ViewController for the "About" View.
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
class AboutViewController: UIViewController {
    
    
    @IBOutlet var version: UILabel!
    
    @IBOutlet var softwareComponentButton: UIButton!
    
    
    // MARK: Life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        /* The title of back button on this view controller */
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
    func initialSetup(){
        self.title = "About"
        var versionValue =  String()
        var buildValue =  String()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? NSString {
            versionValue = String(format: "%.2f", version.floatValue)
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? NSString {
            buildValue = String(format: "%.3d", build.integerValue)
        }
        self.version.text = versionValue + "." + buildValue
        
        softwareComponentButton.layer.cornerRadius = 10
        softwareComponentButton.clipsToBounds = true
        
    }
    
    func tapResponse(recognizer: UITapGestureRecognizer) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.ST_DarkBlue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ImportExportViewSegue"{
            return true
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ImportExportViewSegue"{
            let destinationVC = segue.destination as! ImportExportConfigController
            if let nagigationController  = self.tabBarController?.viewControllers?.first as? UINavigationController{
                if let viewController = nagigationController.viewControllers.first as? MeshNodeListViewController{
                    destinationVC.delegate = viewController
                    
                }
            }
        }
        if segue.identifier == "LicenceSegueIdentifier"{
            let destinationVC = segue.destination as! LicenseViewController
            destinationVC.strPDFName = "LicenseAgreement"
            destinationVC.strTitleMessage = "License Agreement "
        }
        else if segue.identifier == "HelpSegueIdentifier"{
            let destinationVC = segue.destination as! LicenseViewController
            destinationVC.strPDFName = "HelpGuide"
            destinationVC.strTitleMessage = "Help Guide"
        }
    }
}

