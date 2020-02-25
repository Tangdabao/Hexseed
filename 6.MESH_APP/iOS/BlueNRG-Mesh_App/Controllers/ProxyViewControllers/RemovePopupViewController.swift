/**
 ******************************************************************************
 * @file    RemovePopupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    08-Jan-2018
 * @brief   ViewController for "Remove Node" View.
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

protocol RemoveDelegate {
    func confirmDelete(isDeleteConfirmed: Bool)
}


/* Any Provisioned Node -> Settings -> Remove Button -> RemovePopUp */
class RemovePopupViewController: UIViewController {
    var delegate : RemoveDelegate? = nil
    @IBOutlet var removeSurePopup: UIView!
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        removeSurePopup.layer.cornerRadius = 20
        removeSurePopup.layer.masksToBounds = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: selector
    @IBAction func noRemove(_ sender: Any) {
        /* Action of "No" Button */
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesRemove(_ sender: Any) {
        /* Action of "Yes" Button */
        self.delegate?.confirmDelete(isDeleteConfirmed: true)
        dismiss(animated: true, completion: nil)
    }
}//class ends
