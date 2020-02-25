/**
 ******************************************************************************
 * @file    NodeFeatureViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    09-Oct-2018
 * @brief   ViewController for "Node Feature" View.
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

class NodeFeatureViewController: UIViewController {
    
    @IBOutlet weak var proxyRefreshButton: UIButton!
    @IBOutlet weak var proxySwitch: UISwitch!
    @IBOutlet weak var relaySwitch: UISwitch!
    @IBOutlet weak var friendSwitch: UISwitch!
    @IBOutlet weak var relayRefreshButton: UIButton!
    @IBOutlet weak var friendRefreshButton: UIButton!
    @IBOutlet weak var friendStatusLbl: UILabel!
    @IBOutlet weak var relayStatusLbl: UILabel!
    @IBOutlet weak var proxyLblStatus: UILabel!
    @IBOutlet weak var lowPowerStatusLbl: UILabel!
    var node:STMeshNode!
    var configManager :ConfigModelManager = ConfigModelManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configManager.initialSetup(currrentNewworkData:NetworkConfigDataManager.sharedInstance, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNodeFeatures()
        self.navigationItem.title = "Node Features"
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func setNodeFeatures(){
        proxySwitch.isHidden = node.features.proxy == 1 ? false : true
        proxyRefreshButton.isHidden = node.features.proxy == 1 ? false : true
        proxyLblStatus.isHidden = node.features.proxy == 1 ? true : false
        
        relaySwitch.isHidden = node.features.relay == 1 ? false : true
        relayRefreshButton.isHidden = node.features.relay == 1 ? false : true
        relayStatusLbl.isHidden = node.features.relay == 1 ? true : false
        
        friendSwitch.isHidden = node.features.friendFeature == 1 ? false : true
        friendRefreshButton.isHidden = node.features.friendFeature == 1 ? false : true
        friendStatusLbl.isHidden = node.features.friendFeature == 1 ? true : false
        
        lowPowerStatusLbl.text = node.features.lowPower == 1 ? "Supported" : "Not Supported"
        friendStatusLbl.text = node.features.friendFeature == 1 ? "Supported" : "Not Supported"
        relayStatusLbl.text = node.features.relay == 1 ? "Supported" : "Not Supported"
        proxyLblStatus.text = node.features.proxy == 1 ? "Supported" : "Not Supported"
    }
    
    @IBAction func relayRefreshButtonAction(_ sender: UIButton) {
        configManager.refreshRelayStatus(node:node!)
    }
    
    @IBAction func proxyRefreshButtonAction(_ sender: UIButton) {
        configManager.refreshProxyStatus(node:node!)
    }
    
    @IBAction func friendRefreshButtonAction(_ sender: UIButton) {
        configManager.refreshFriendStatus(node:node!)
    }
    
    @IBAction func proxySwitchButtonAction(_ sender: UISwitch) {
        configManager.setGATTProxyFeature(node:node!, isOn:sender.isOn)
    }
    
    @IBAction func relaySwitchButtonAction(_ sender: UISwitch) {
        configManager.setRelayFeature(node: node!, isOn:sender.isOn)
    }
    
    @IBAction func friendSwitchButtonAction(_ sender: UISwitch) {
        configManager.setFriendFeature(node: node!, isOn:sender.isOn)
    }
}

extension NodeFeatureViewController:ConfigManagerDelegate{
    func didAppKeyAssignmentSuccessfullyCompleted(completed: Bool, message: String) {
        
    }
    
    func didAdd_RemoveSubcriptionSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didAdd_RemovePublisherSuccessfullyCompleted(completed: Bool) {
        
    }
    
    func didRemoveNodeSuccessfullyCompleted(completed: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didProxyStatusReceived(status: ConfigState, address: UInt16) {
        proxySwitch.isOn = status.rawValue == 1 ? true :false
    }
    
    func didRelayStatusReceived(status: ConfigState, address: UInt16) {
        relaySwitch.isOn = status.rawValue == 1 ? true :false
    }
    
    func didFreiendStatusReceived(status: ConfigState, address: UInt16) {
        friendSwitch.isOn =  status.rawValue == 1 ? true :false
    }
}
