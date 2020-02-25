/**
 ******************************************************************************
 * @file    LogViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    02-Oct-2018
 * @brief   ViewController for the "Log" View.
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

class LogViewController: UIViewController {
    
    var logModelsArray:[STLogModels] = [STLogModels]()
    @IBOutlet weak var logListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Do any additional setup after loading the view. */
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "Logger"
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension LogViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logModelsArray.count > 0 ? logModelsArray.count:0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"LogTableViewCell", for:indexPath) as? LogTableViewCell
        cell!.setLogerData(logModelData:logModelsArray[indexPath.row])
        cell?.selectionStyle = .none
        return cell!
    }
}

extension LogViewController :logReceiverDelegate{
    func didReceivedNewLogObject(newLogObject: STLogModels) {
        logModelsArray.append(newLogObject)
        let indexpath = IndexPath(item:logModelsArray.count - 1, section:0)
        logListTableView.insertRows(at: [indexpath], with:.top)
        logListTableView.endUpdates()
    }
    
}