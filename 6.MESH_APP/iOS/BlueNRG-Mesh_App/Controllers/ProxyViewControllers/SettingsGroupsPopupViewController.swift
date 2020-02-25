/**
 ******************************************************************************
 * @file    SettingsGroupsPopupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    13-Nov-2017
 * @brief   ViewController for "Group settings pop-up" View.
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

class SettingsGroupsPopupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    @IBOutlet var groupsTableView: UITableView!
    var node: STMeshNode!
    weak var settingsVC: NodeSettingViewController!
    var delegate: GroupSettingsPopupDelegate? = nil
    var didAddMember: Bool!
    
    //MARK: Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        groupsTableView.dataSource = self
        groupsTableView.delegate = self
        self.groupsTableView.center = (self.groupsTableView.superview?.center)!;
        groupsTableView.frame.size.height = CGFloat((currentNetworkDataManager.currentNetworkData.groups.count * 40) + 10)
        groupsTableView.layer.cornerRadius = 20
        groupsTableView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.groupsTableView!.reloadData()
        }
    }
    
    /* Dismiss viewController when clicked outside the tableView */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}//class end


extension SettingsGroupsPopupViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groups = currentNetworkDataManager.currentNetworkData.groups {
            return groups.count - 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsListPopup", for: indexPath) as! SettingsGroupsPopupTableViewCell
        if let groups = currentNetworkDataManager.currentNetworkData.groups as? [STMeshGroup] {
            cell.groupName.text = groups[indexPath.row + 1].groupName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groups = (currentNetworkDataManager.currentNetworkData.groups as? [STMeshGroup]){
            let group = groups[indexPath.row + 1]
            CommonUtils.showAlertTostMessage(title:"Processing", message: "Group \"\(group.groupName!)\" is being assigned to \"Node \(node.nodeName!)\".", controller: self, success: { (response) in
                self.didAddMember = true
                self.dismiss(animated: true, completion: nil)
                self.settingsVC.viewWillAppear(true)
            })
        }
    }
}
