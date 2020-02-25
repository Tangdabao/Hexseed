/**
 ******************************************************************************
 * @file    ProvisioningPopUpController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    12-Dec-2017
 * @brief   ViewController for "Provisioning pop-up" View.
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
protocol ProvisioningPopUpControllerDelegate {
    func ProvisioningPopUpController(didUserRequestCancellation:Bool)
}

/* Main Screen -> Add Button -> Unprovisioned Nodes -> Add Button on any node -> Provisioning Progress PopUp */
class ProvisioningPopUpController: UIViewController {
    
    
    @IBOutlet var popupView: UIView!
    @IBOutlet var name: UILabel!
    @IBOutlet var provisioningProgress: UIProgressView!
    @IBOutlet var provisioningPercentage: UILabel!
    
    var delegate:ProvisioningPopUpControllerDelegate?
    
    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* To give rounded edge to the popup */
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        self.name.text = "Provisioning..."
        self.provisioningPercentage.text = "0 %"
        self.provisioningProgress.setProgress(0, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  self.tabBarController?.tabBar.isHidden  =  true
    }
    
    // MARK: custom methods
    func updateProgress(percent: Int, message:String, isError: Bool) -> Void {
        
        provisioningProgress.setProgress(Float(percent) / 100.0, animated: false)
        provisioningPercentage.text = "\(percent) %"
        if(isError) {
            self.name.text = "Error"
            return
        }
        if(percent == 100) {
            self.name.text = "Complete"
            self.dismiss(animated: true, completion: nil)
            delegate?.ProvisioningPopUpController(didUserRequestCancellation:false)
        }
        else {
            self.name.text = message
        }
    }
    
    // MARK:selectors

    @IBAction func closePopup(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        dismiss(animated: true, completion: nil)
    }
}//class ends
