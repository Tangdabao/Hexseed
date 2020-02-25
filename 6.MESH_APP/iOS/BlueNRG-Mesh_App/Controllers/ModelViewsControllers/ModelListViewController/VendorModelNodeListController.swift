/**
 ******************************************************************************
 * @file    VendorModelNodeListController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    04-June-2018
 * @brief   ViewController for Vendor Model view
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

class VendorModelNodeListController: STMeshBaseViewController {
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    
    @IBOutlet var vendorModelTableView: UITableView!
    var didGetVersionResponse = true
    let lblNew = UILabel()
    
    var manager:STMeshManager!
    var vendorModelsNode:[STMeshNode] = [STMeshNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Vendor Model"
        /* Back button */
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"model_selection"), style: .done, target: self, action: #selector(handleModelSelectionButton))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        UserDefaults.standard.set("Vendor", forKey:KConstantSelectedModelScreen)
        manager = STMeshManager.getInstance(self)
        manager.getVendorModel().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vendorModelsNode = [STMeshNode]()
        getAllVendorModelNode()
        setUpMyLabel()
        vendorModelTableView.reloadData()
        manager?.startNetwork(0)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if(!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForVendorModelListViewController)){
            DispatchQueue.main.asyncAfter(deadline:.now()+1)
            {
                if self.vendorModelsNode.count > 0{
                    UserHelperScreenManager.HelpScreenForVendorModelViewController(objVendorModelListViewController: self)
                }
            }
        }
    }
    @objc func handleModelSelectionButton(){
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelListViewController", type:ModelListViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getAllVendorModelNode()
    {
        
        for node in  currentNetworkDataManager.currentNetworkData.nodes{
            var isVendorModel = false
            for elements in ((node as? STMeshNode)?.elementList)!{
                for model in ((elements as? STMeshElement)?.modelList)!{
                    
                    if ((model as? STMeshModel)?.modelId)! == 0x10030 {
                        isVendorModel = true
                    }
                }
            }
            if isVendorModel{
                vendorModelsNode.append((node as? STMeshNode)!)
            }
        }
    }
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return didGetVersionResponse
    }
    func setUpMyLabel() {
        
        lblNew.backgroundColor = UIColor.white
        lblNew.text = "There are no nodes in your network that support vendor model. please add nodes by tapping add button in device tab"
        lblNew.textColor = UIColor.black
        lblNew.numberOfLines = 3
        lblNew.textAlignment = .center
        lblNew.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblNew)
        
        let widthConstraint = NSLayoutConstraint(item: lblNew, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth-40)
        let heightConstraint = NSLayoutConstraint(item: lblNew, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70)
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        /* Center vertically */
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
    }
    
}

extension VendorModelNodeListController :UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lblNew.isHidden = vendorModelsNode.count > 0 ? true :false
        return vendorModelsNode.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"VendorModelListTableCell", for:indexPath) as? VendorModelListTableCell
        cell!.configureCell(node:vendorModelsNode[indexPath.row] )
        cell!.delegate = self
        cell!.indexPath = indexPath
        //  SwiftProgressLoader.show(title:nil, currentView:cell!, animated: true)
        
        cell?.loaderView.isHidden = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let addressString = (vendorModelsNode[indexPath.row] ).nodeUUID {
            let size = CGSize(width:screenWidth - 173 , height: 50)
            let attributes = [kCTFontAttributeName:UIFont.systemFont(ofSize:15)]
            let estimatedFrame = NSString(string:addressString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context:nil)
            let elementCount = (vendorModelsNode[indexPath.row] ).elementList.count ;
            
            return (estimatedFrame.height +  45 + 64 * CGFloat(elementCount))
        }
        return (1.78 * 39.5)
    }
}

extension VendorModelNodeListController :STMeshManagerDelegate{
    
}

extension VendorModelNodeListController :STMeshVendorModelDelegate{
    
    func vendorModel(_ vendorModel: STMeshVendorModel!, didReceiveResponseFromAddress peerAddress: UInt16, usingOpcode opcode: UInt8, recvData data: Data!) {
        
        if opcode == 2  && data != nil && CommonUtils.getVendorModelsSubCommand(data:data!) == 2  && data.count >= 6{
            let version  = "\(data[2])" + "." + "\(data[4])" + "." + "\(data[6])"
            print("byte array = ",version)
            let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelControlPopUpController", type:ModelControlPopUpController.self)
            controller.isVersionPage = true
            controller.versiontext = version
            self.tabBarController?.navigationController?.present(controller, animated:false, completion: nil)
        }
    }
}
extension VendorModelNodeListController:IntensityDelegate{
    func IntensitySliderChangeValue(slider: UISlider, address: UInt16) {
        LEDControlManager.setLEDIntensityWithVendor(address:address, sender:slider, manager:manager)
    }
}
extension VendorModelNodeListController : vendorControlDelegate{
    
    func didClickVersionButton(element:STMeshElement){
        
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 2)
        var sendData :Data = Data(count:1)
        sendData[0] = (UInt8)(AppliGroupDeviceInfoCmdLibVersion)
        sendData.append(data as Data)
        manager.getVendorModel().readDeviceVersionData(element.unicastAddress, usingOpcode: UInt8(AppliGroupDeviceInfo), send:sendData)
    }
    
    func didClickIntersityButton(element:STMeshElement){
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelControlPopUpController", type:ModelControlPopUpController.self)
        controller.isVersionPage = false
        controller.delegate = self
        controller.address = element.unicastAddress
        controller.levelTitle = "Intensity"
        self.tabBarController?.navigationController?.present(controller, animated:false, completion: nil)
    }
    
    func didClickToggleButton(element:STMeshElement){
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 2)
        var sendData :Data = Data(count:1)
        sendData[0] = (UInt8)(AppliGroupLEDControlCmdToggle)
        sendData.append(data as Data)
        manager.getVendorModel().setRemoteData(element.unicastAddress, usingOpcode: AppliGroupLEDControl, send: sendData , isResponseNeeded:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
    }
    
    func didSwitchButtonToggle(element:STMeshElement, index:IndexPath, isOn:Bool){
        let data = NSData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07] as [UInt8], length: 2)
        var sendData :Data = Data(count:1)
        sendData[0] = (UInt8)(isOn ? AppliGroupLEDControlCmdOn :AppliGroupLEDControlCmdOff)
        sendData.append(data as Data)
        manager.getVendorModel().setRemoteData(element.unicastAddress, usingOpcode: AppliGroupLEDControl, send: sendData , isResponseNeeded:  UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
    }
}

protocol vendorControlDelegate {
    func didClickVersionButton(element:STMeshElement)
    func didClickIntersityButton(element:STMeshElement)
    func didClickToggleButton(element:STMeshElement)
    func didSwitchButtonToggle(element:STMeshElement, index:IndexPath, isOn:Bool)
    
}
class VendorModelListTableCell: UITableViewCell {
    
    @IBOutlet var loaderView: UIView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var tblViewElement: UITableView!
    @IBOutlet var nodeNameLbl: UILabel!
    @IBOutlet var uuidLbl: UILabel!
    
    var meshNode: STMeshNode!
    var indexPath:IndexPath?
    var delegate: vendorControlDelegate?
    
    func configureCell(node: STMeshNode) -> Void {
        self.meshNode = node;
        self.nodeNameLbl.text = node.nodeName
        self.uuidLbl.text = node.nodeUUID.uppercased()
        
        tblViewElement.reloadData()
    }
    
    @objc func  versionButtonClick(_ sendor :UIButton) {
        delegate?.didClickVersionButton(element:meshNode.elementList![sendor.tag] as! STMeshElement)
    }
    
    @objc func didToggleButtonClick(_ sendor:UIButton){
        delegate?.didClickToggleButton(element:meshNode.elementList![sendor.tag] as! STMeshElement)
    }
    
    @objc func didIntensityButtonClick(_ sendor: UIButton){
        delegate?.didClickIntersityButton(element:meshNode.elementList![sendor.tag] as! STMeshElement)
    }
    
    @objc func didSwitchButtonStatusChange(_ sendor:UISwitch){
        delegate?.didSwitchButtonToggle(element:meshNode.elementList![sendor.tag] as! STMeshElement, index: indexPath!, isOn: sendor.isOn)
    }
}
extension VendorModelListTableCell :UITableViewDelegate,UITableViewDataSource{
    // MARK: Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meshNode != nil ?  meshNode.elementList.count:0 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElementCell", for: indexPath) as! ProvisionedElementsTableViewCell
        cell.indexPath = indexPath
        cell .cofigureElementForNode(meshNode: meshNode)
        cell.versionButton.tag = indexPath.row
        cell.toggleButton.tag = indexPath.row
        cell.intensityButton.tag = indexPath.row
        cell.switchElement.tag = indexPath.row
        
        cell.versionButton.addTarget(self, action: #selector(self.versionButtonClick(_:)), for:.touchUpInside)
        cell.toggleButton.addTarget(self, action:#selector(self.didToggleButtonClick(_:)), for: .touchUpInside)
        cell.intensityButton.addTarget(self, action:#selector(self.didIntensityButtonClick(_:)), for: .touchUpInside)
        cell.switchElement.addTarget(self, action: #selector(self.didSwitchButtonStatusChange(_:)), for:.valueChanged)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
}

extension VendorModelNodeListController : UserHelperScreenDelegate{
    func helperScreenClosed() {
        print("Vendor Model helper screem is closed!!")
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForVendorModelListViewController)
    }
    
}




