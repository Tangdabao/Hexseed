/**
 ******************************************************************************
 * @file    GroupsCollectionViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    22-Nov-2017
 * @brief   ViewController for "Groups" View.
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

class GroupsCollectionViewController:STMeshBaseViewController, IntensityDelegate{
    
    @IBOutlet var networkGroupView: UICollectionView!
    
    var manager: STMeshManager?
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    
    // MARK: Life cycle Methods
    /* This function executes only when the view is loaded */
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.networkGroupView.dataSource = self
        self.networkGroupView.delegate = self
        self.navigationItem.title = "Groups"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"hamburger-menu-icon-1"), style: .plain, target: MenuViewIntializer.sharedInstance, action: #selector(MenuViewIntializer.handleMenuView))
        
    }
    
    /* This function will execute each time the view appears */
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        DispatchQueue.main.async {
            self.networkGroupView.reloadData()
        }
        currentNetworkDataManager.saveNetworkConfigToStorage()
        manager?.startNetwork(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (objCurrentAlertView != nil){
            objCurrentAlertView.removeAlertView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if networkGroupView != nil{
            UIView.performWithoutAnimation {
                networkGroupView.reloadData()
            }
        }
    }
    
    // MARK: Navigation Methods
    /* Sync the value of label name of diff view controllers */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "groupSettingsSegue"{
            let destinationVC = segue.destination as! GroupSettingsViewController
            let button = sender as! UIButton
            var cell = button.superview as? GroupsCollectionViewCell
            
            if(cell == nil)
            {
                cell = button.superview?.superview as? GroupsCollectionViewCell
            }
            if(cell != nil)
            {
                let indexPath = cell!.indexPath
                let group = currentNetworkDataManager.currentNetworkData.groups[indexPath!.row] as! STMeshGroup
                destinationVC.group = group
                destinationVC.delegate = self
                destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
            }
        }
        else if segue.identifier == "addGroupSegue"{
            let destinationVC = segue.destination as! AddGroupViewController
            destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
        }
    }
    
    func setLEDState(addr:UInt16, cmd:Bool,data:Data?)
    {
        var sendData :Data = Data(count:1)
        sendData[0] = (UInt8)(cmd ? AppliGroupLEDControlCmdOn :AppliGroupLEDControlCmdOff)
        sendData.append(data!)
        if let savedScreen = UserDefaults.standard.string(forKey: KConstantSelectedModelScreen){
            switch savedScreen{
            case "Generic":
                manager?.getGenericModel().setGenericOnOff(addr, isOn:cmd, isUnacknowledged:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
            case "Vendor":
                manager?.getVendorModel().setRemoteData(addr, usingOpcode: AppliGroupLEDControl, send: sendData , isResponseNeeded:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
            default:
                manager?.getGenericModel().setGenericOnOff(addr, isOn:cmd,isUnacknowledged:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
                break
            }
        }else{
            manager?.getGenericModel().setGenericOnOff(addr, isOn:cmd, isUnacknowledged:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
        }
        
    }
    
    @objc func intensityButtonClick( _ sender :UIButton)
    {
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelControlPopUpController", type:ModelControlPopUpController.self)
        controller.isVersionPage = false
        controller.delegate = self
        controller.address = ((currentNetworkDataManager.currentNetworkData.groups[sender.tag] as? STMeshGroup)?.groupAddress)!
        self.tabBarController?.navigationController?.present(controller, animated:false, completion: nil)
    }
    
    func IntensitySliderChangeValue(slider:UISlider,address:UInt16){
        if let savedScreen = UserDefaults.standard.string(forKey: KConstantSelectedModelScreen){
            
            switch savedScreen{
            case "Generic":
                manager?.getGenericModel().setGenericLevel(address, level:Int16((Float(String(format:"%.0f",slider.value)))! * ((Float(INT16_MAX))/100)), isUnacknowledged:UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
                break
            case "Vendor":
                LEDControlManager.setLEDIntensityWithVendor(address: address, sender:slider, manager:manager!)
                break
            case "Lighting":
                manager?.getGenericModel().setGenericLevel(address, level:Int16((Float(String(format:"%.0f",slider.value)))! * ((Float(INT16_MAX))/100)), isUnacknowledged:UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
                break
            default:
                
                break
            }
        }else{
            manager?.getGenericModel().setGenericLevel(address, level:Int16((Float(String(format:"%.0f",slider.value)))! * ((Float(INT16_MAX))/100)), isUnacknowledged:UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
        }
        
    }
}//class end


extension GroupsCollectionViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDelegate,UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width*0.95, height: 70)
    }
    
    //this function returns the no. of cells in collectionview
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let groups = currentNetworkDataManager.currentNetworkData.groups {
            return groups.count
        }
        return 0
    }
    /* This determines the value of labels and buttons on each cell */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath) as! GroupsCollectionViewCell
        _ = indexPath.row
        let ishidden: Bool
        cell.itensityButton.tag = indexPath.row
        cell.itensityButton.addTarget(self, action:#selector(self.intensityButtonClick(_:)), for:.touchUpInside)
        if(indexPath.row == 0){
            ishidden = true
        }
        else{
            ishidden = false
        }
        if let groups = (currentNetworkDataManager.currentNetworkData.groups as? [STMeshGroup]){
            cell.indexPath = indexPath
            cell.hideButton = ishidden
            cell.delegate = self
            cell.configureCell(group: groups[indexPath.row])
        }
        return cell
    }
}

extension GroupsCollectionViewController: GroupCellProtocol{
    func switchStateDidChange(index: IndexPath, switchState: Bool) -> Bool {
        let group = currentNetworkDataManager.currentNetworkData.groups[index.row] as! STMeshGroup
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 7)
        self.setLEDState(addr:group.groupAddress, cmd: switchState, data: data as Data)
        return true
    }
}

extension GroupsCollectionViewController: GroupSettingsDelegate{
    
    func updateGroupName(groupUpdated: STMeshGroup, newName: String) -> Bool {
        groupUpdated.groupName = newName
        for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
            let node = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
            for a in 0..<node.subscribedGroups.count{
                let group = node.subscribedGroups[a] as! STMeshGroup
                if(group.groupAddress == groupUpdated.groupAddress){
                    group.groupName = newName
                    break;
                }
            }
        }
        currentNetworkDataManager.saveNetworkConfigToStorage()
        return true
    }
    
    func updateSwitchStatus(groupUpdated: STMeshGroup, status: Bool) {
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 7)
        self.setLEDState(addr:groupUpdated.groupAddress, cmd: status, data: data as Data)
    }
}



