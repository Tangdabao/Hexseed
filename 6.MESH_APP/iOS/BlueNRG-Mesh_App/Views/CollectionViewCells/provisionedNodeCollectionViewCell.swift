/**
 ******************************************************************************
 * @file    ProvisionedNodeCollectionViewCell.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.04.000
 * @date    12-Dec-2017
 * @brief   Cell class for ProvisionedNodeCollectionViewCell.
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

protocol ProvisionedNodeCellProtocol {
    
    func switchStateDidChange(index: IndexPath, switchState:Bool) -> Bool
    func heartbeatInfoButtonClicked(indexPathSection : Int) -> Void
    func healthModelFaultsWarningButtonClicked(indexPathSection : Int) -> Void
    
}


/* Contents of cell of the provisioned Nodes Collection View. */
class provisionedNodeCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet var loaderView: UIView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var uuidLabel: UILabel!
    @IBOutlet var mainSwitch: UISwitch!
    @IBOutlet var nodeSettings: UIButton!
    @IBOutlet var nodeName: UILabel!
    @IBOutlet weak var viewNodeInCell: UIView!
    
    @IBOutlet var proxyButton: UIButton!
    @IBOutlet var realyNode: UIButton!
    @IBOutlet var lowPowerButton: UIButton!
    @IBOutlet var friendButton: UIButton!
    
    
    @IBOutlet var lowPowerWidth: NSLayoutConstraint!
    @IBOutlet var friendWidth: NSLayoutConstraint!
    @IBOutlet var realyWidth: NSLayoutConstraint!
    @IBOutlet var proxyWidth: NSLayoutConstraint!
    
    @IBOutlet weak var btnHeartbeatInfo: UIButton!
    var meshNode: STMeshNode!
    var indexPath:IndexPath?
    @IBOutlet weak var tblViewElements: UITableView!
    @IBOutlet weak var btnHealthFaultsWarning: UIButton!
    
    var delegate: ProvisionedNodeCellProtocol?
    
    // MARK: Class Methods
    func configureCell(node: STMeshNode) -> Void {
        self.meshNode = node;
        self.nodeName.text = node.nodeName;
        self.uuidLabel.text = node.nodeUUID.uppercased();
        self.mainSwitch.isOn = node.switchState
        self.mainSwitch.onTintColor = UIColor .green
        self.mainSwitch.tintColor = UIColor .red
        self.mainSwitch.layer.cornerRadius = 16
        self.mainSwitch.backgroundColor = UIColor .red
        self.tblViewElements.delegate = self
        self.tblViewElements.dataSource = self
        self.tblViewElements.reloadData()
        
        loaderView.isHidden = true
        loader.stopAnimating()
        // }
        proxyButton.backgroundColor = .white
        proxyButton.setTitleColor(UIColor.black, for:.normal)
        realyNode.backgroundColor = .white
        realyNode.setTitleColor(UIColor.black, for:.normal)
        lowPowerButton.backgroundColor = .white
        lowPowerButton.setTitleColor(UIColor.black, for:.normal)
        friendButton.backgroundColor = .white
        friendButton.setTitleColor(UIColor.black, for:.normal)
        if node.features != nil{
            friendWidth.constant = node.features.friendFeature == 1 ? 36.5 : 0
            friendButton.isHidden = node.features.friendFeature == 1 ? false : true
            
            proxyWidth.constant = node.features.proxy == 1 ? 36.5 : 0
            proxyButton.isHidden = node.features.proxy == 1 ? false : true
            
            lowPowerWidth.constant = node.features.lowPower == 1 ? 36.5 : 0
            lowPowerButton.isHidden = node.features.lowPower == 1 ? false : true
            
            realyWidth.constant = node.features.relay == 1 ? 36.5 : 0
            realyNode.isHidden = node.features.relay == 1 ? false : true
        }
        
    }
    func setEnabled(isEnabled: Bool) -> Void{
        
        if isEnabled == true {
            self.mainSwitch.isEnabled = true
            self.nodeSettings.isEnabled = true
            self.mainSwitch.alpha = 1
            self.nodeSettings.alpha = 1
            self.nodeName.alpha = 1
            // self.nodeDesc.alpha = 1
        }
        else {
            self.mainSwitch.isEnabled = false
            self.mainSwitch.alpha = 0.4
            self.nodeSettings.isEnabled = false
            self.nodeSettings.alpha = 0.4
            self.nodeName.alpha = 0.4

        }
    }
    
    
    /* Change only if required, return true if update is done */
    func setProxyIndication(isEnabled: Bool) -> Bool {
        
        return false

    }
    
    // MARK: selector
    @IBAction func switchValUpdated(_ sender: Any) {
        
        let main = sender as! UISwitch
        let  result = self.delegate?.switchStateDidChange(index: indexPath ?? IndexPath.init(row:0, section:0), switchState: mainSwitch.isOn)
        if result!
        {
            // normal on / off
        }
        else
        {
            let aSelector : Selector = #selector(switchValUpdated(_:))
            self.mainSwitch .removeTarget(self, action:aSelector, for:.valueChanged)
            self.mainSwitch.setOn(!main.isOn, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.mainSwitch.addTarget(self, action: aSelector, for: .valueChanged)
            }
        }
    }
    @IBAction func btnHeartbeatButtonInfoClicked(_ sender: Any) {
        self.delegate?.heartbeatInfoButtonClicked(indexPathSection: (self.indexPath?.section)!)
    }
    @IBAction func btnHealthFaultsWarningClicked(_ sender: Any) {
        self.delegate?.healthModelFaultsWarningButtonClicked(indexPathSection: (self.indexPath?.section)!)
    }
}

// MARK: Table View Delegates

extension provisionedNodeCollectionViewCell : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.meshNode.elementList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElementCell", for: indexPath) as! ProvisionedElementsTableViewCell
        cell.bringSubview(toFront: self.viewNodeInCell)
        cell.indexPath = indexPath
        cell .cofigureElementForNode(meshNode: self.meshNode)
        cell.initialModelUI()
        cell.delegate = self as ElementCellProtocol
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
}

// MARK: Element Cell Delegates
extension provisionedNodeCollectionViewCell: ElementCellProtocol{
    
    func elementSwitchStateChanged(tableViewIndex: IndexPath, state: Bool) -> Bool {
        
        let  result = self.delegate?.switchStateDidChange(index: IndexPath.init(row:tableViewIndex.row, section:(indexPath?.row)!), switchState: state)
        print("Result of switch is : ",result ?? true)
        return true;
    }
    
    
}







