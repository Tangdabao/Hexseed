/**
 ******************************************************************************
 * @file    LightingModelNodeListController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    26-June-2018
 * @brief   ViewController for Lighting Model list View.
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

class LightingModelNodeListController: STMeshBaseViewController {
    
    var manager :STMeshManager!
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var lightingModelsNode:[STMeshNode] = [STMeshNode]()
    let lblNew = UILabel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Lighting Model"
        manager = STMeshManager.getInstance(self)
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"model_selection"), style: .done, target: self, action: #selector(handleModelSelectionButton))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        UserDefaults.standard.set("Lighting", forKey:KConstantSelectedModelScreen)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lightingModelsNode = [STMeshNode]()
        getAllLighttingModelNode()
        setUpMyLabel()
        tableView.reloadData()
        manager?.startNetwork(0)
        if(!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForLightingModelListViewController)){
            DispatchQueue.main.asyncAfter(deadline:.now()+0.25)
            {
                if self.lightingModelsNode.count > 0{
                    
                    UserHelperScreenManager.HelpScreenForLightingModelViewController(objLightingModelListViewController: self)
                }
            }
        }
    }
    
    func getAllLighttingModelNode()
    {
        for node in  currentNetworkDataManager.currentNetworkData.nodes{
            var isLightingModel = false
            for elements in ((node as? STMeshNode)?.elementList)!{
                for model in ((elements as? STMeshElement)?.modelList)!{
                    if ((model as? STMeshModel)?.modelId)! >= 0x1300 && ((model as? STMeshModel)?.modelId)! <= 0x1311{
                        isLightingModel = true
                    }
                }
            }
            if isLightingModel{
                lightingModelsNode.append((node as? STMeshNode)!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleModelSelectionButton(){
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelListViewController", type:ModelListViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension LightingModelNodeListController :UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lblNew.isHidden = lightingModelsNode.count > 0 ? true  : false
        return lightingModelsNode.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"LightingModelListTableCell", for:indexPath) as? LightingModelListTableCell
        cell?.indexPath = indexPath
        cell?.configureCell(node: (lightingModelsNode[indexPath.row]) )
        cell?.delegate = self
        cell?.selectionStyle = .none
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if lightingModelsNode.count > 0 ,let addressString = (lightingModelsNode[indexPath.row] ).nodeUUID {
            let size = CGSize(width:screenWidth - 173 , height: 50)
            let attributes = [kCTFontAttributeName:UIFont.systemFont(ofSize:15)]
            let estimatedFrame = NSString(string:addressString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context:nil)
            let elementCount = (lightingModelsNode[indexPath.row] ).elementList.count ;
            return (estimatedFrame.height +  45 + 64 * CGFloat(elementCount))
        }
        return lightingModelsNode.count > 0 ? (1.78 * 39.5) :0
        
    }
    
    func setUpMyLabel() {
        
        lblNew.backgroundColor = UIColor.white
        lblNew.text = "There are no nodes in your network that support lighting model. please add nodes by tapping add button in device tab"
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
        
        // Center vertically
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
    }
}


extension LightingModelNodeListController :STMeshManagerDelegate{
    
}

extension LightingModelNodeListController :STMeshGenericModelDelegate{
    func genericModel(_ genericModel: STMeshGenericModel!, didReceiveOnOffStatusFromAddress peerAddress: UInt16, presentOnOff presentState: UInt8, targetOnOff targetState: UInt8, remainingTime time: UInt8, isTargetStatePresent stateFlag: Bool) {
    }
}

extension LightingModelNodeListController:ctlPopDelegate{
    
    func didTemperatureValuesChange(tempValue:Float,DeltaUVValue:Float,address:UInt16){
        manager.getLightingModel().setLightingCTLTemperature(address, temperatureValue: UInt16(tempValue), deltaUVValue: Int16(DeltaUVValue), transatimnTime: 10, withDelay: 10, isUnacknowledged: UserDefaults.standard.bool(forKey: KConstantReliableModeKey))
    }
    
    func didCTLValueChanges(DeltaUVValue: Float, tempValue: Float, lightnessValue: Float,address:UInt16) {
        manager.getLightingModel().setLightingCTL(address, lightnessValue: UInt16(lightnessValue), temperatureValue: UInt16(tempValue), deltaUVValue: Int16(DeltaUVValue), transatimnTime: 0, withDelay: 0, isUnacknowledged: UserDefaults.standard.bool(forKey: KConstantReliableModeKey))
    }
}

extension LightingModelNodeListController:IntensityDelegate{
    
    func IntensitySliderChangeValue(slider:UISlider,address:UInt16){
        manager.getLightingModel().setLightingLightness(address, lightnessValue: UInt16((Float(String(format:"%.0f",slider.value)))! * (65534/100)), isUnacknowledged: UserDefaults.standard.bool(forKey: KConstantReliableModeKey))
    }
}

extension LightingModelNodeListController :LightingControlDelegate{
    
    func didCTLButtonClicked(element: STMeshElement) {
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"LightingCTLPopupViewController", type:LightingCTLPopupViewController.self)
        controller.delegate = self
        controller.address = element.unicastAddress
        self.tabBarController?.navigationController?.present(controller, animated:false, completion: nil)
    }
    
    func didLevelButtonClick(element: STMeshElement) {
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelControlPopUpController", type:ModelControlPopUpController.self)
        controller.isVersionPage = false
        controller.delegate = self
        controller.address = element.unicastAddress
        controller.levelTitle = "Lighting"
        self.tabBarController?.navigationController?.present(controller, animated:false, completion: nil)
    }
    
    func didHSLButtonClick(elements element: STMeshElement) {
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"LightingHSLPopupViewController", type: LightingHSLPopupViewController.self)
        controller.address = element.unicastAddress
        self.tabBarController?.navigationController?.present(controller, animated:true, completion:nil)
    }
    
    func didSwitchButtonToggle(element:STMeshElement, index:IndexPath, isOn:Bool){
        manager.getGenericModel().setGenericOnOff(element.unicastAddress, isOn: isOn, isUnacknowledged: UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
    }
}

protocol LightingControlDelegate {
    
    func didLevelButtonClick(element:STMeshElement)
    func didCTLButtonClicked(element:STMeshElement)
    func didHSLButtonClick(elements:STMeshElement)
    func didSwitchButtonToggle(element:STMeshElement, index:IndexPath, isOn:Bool)
}

class LightingModelListTableCell: UITableViewCell {
    
    @IBOutlet var nodeNameLbl: UILabel!
    @IBOutlet var nodeUuidLbl: UILabel!
    @IBOutlet var elementTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var loaderView: UIView!
    
    var delegate :LightingControlDelegate?
    var meshNode: STMeshNode!
    var indexPath:IndexPath?
    
    func configureCell(node: STMeshNode) -> Void {
        self.meshNode = node;
        self.elementTableView.reloadData()
        self.nodeNameLbl.text = meshNode.nodeName
        self.nodeUuidLbl.text = meshNode.nodeUUID.uppercased()
    }
    
    @objc func didLevelButtonClick(_ sender:UIButton){
        delegate?.didLevelButtonClick(element:meshNode.elementList![sender.tag] as! STMeshElement)
    }
    
    @objc func didCTLButtonClick(_ sender:UIButton){
        delegate?.didCTLButtonClicked(element:meshNode.elementList![sender.tag] as! STMeshElement)
    }
    
    @objc func didHSLButtonClick(_ sender:UIButton){
        delegate?.didHSLButtonClick(elements:meshNode.elementList![sender.tag] as! STMeshElement)
    }
    
    @objc func didElementSwitchButtonToggle( _ sender:UISwitch){
        delegate?.didSwitchButtonToggle(element:meshNode.elementList![sender.tag] as! STMeshElement, index: indexPath!, isOn: sender.isOn)
    }
}

extension LightingModelListTableCell :UITableViewDelegate,UITableViewDataSource{
    // MARK: Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  meshNode != nil ? meshNode.elementList.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElementCell", for: indexPath) as! ProvisionedElementsTableViewCell
        
        cell.indexPath = indexPath
        cell .cofigureElementForNode(meshNode: meshNode)
        cell.levelButton.tag = indexPath.row
        cell.batteryButton.tag = indexPath.row
        cell.switchElement.tag = indexPath.row
        
        cell.levelButton.addTarget(self, action:#selector(self.didLevelButtonClick(_:)), for: .touchUpInside)
        cell.batteryButton.addTarget(self, action: #selector(self.didCTLButtonClick(_:)), for:.touchUpInside)
        cell.switchElement.addTarget(self, action:#selector(self.didElementSwitchButtonToggle(_:) ), for:.valueChanged)
        cell.hslControlButton.addTarget(self, action:#selector(self.didHSLButtonClick(_:) ), for:.touchUpInside)
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
}

extension LightingModelNodeListController : UserHelperScreenDelegate{
    func helperScreenClosed() {
        print("Lightning Model Help screen is closed")
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForLightingModelListViewController)
    }
    
}
