/**
 ******************************************************************************
 * @file    PrivacyPolicyViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    17-jan-2018
 * @brief   ViewController for the "About-> Software Components" View.
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

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    var isPrivacyPage = true
    
    @IBOutlet var activityLoader: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPrivacyPage{
            webView.loadRequest(URLRequest(url: URL(string: "http://www.st.com/content/st_com/en/common/privacy-policy.html")!))
            self.navigationItem.title = "Privacy Policy"
            activityLoader.isHidden = false
            activityLoader.startAnimating()
        }else{
            webView.loadRequest(URLRequest(url: URL(string: "https://app-de.onetrust.com/app/#/webform/2b87200d-4023-4588-9df7-ab0cdea1a67e")!))
            self.navigationItem.title = "Exercise Rights"
            activityLoader.isHidden = false
            activityLoader.startAnimating()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension PrivacyPolicyViewController:UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityLoader.isHidden = true
        activityLoader.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityLoader.isHidden = true
        activityLoader.stopAnimating()
    }
}
