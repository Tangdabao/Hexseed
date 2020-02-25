/**
 ******************************************************************************
 * @file    GenericModelNodeListController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    04-June-2018
 * @brief   ViewController for Generic Model view
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

class GenericModelNodeListController: STMeshBaseViewController {
    // private let
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var genericModelsNode:[STMeshNode]  = [STMeshNode]()
    let lblNew = UILabel()
    
    @IBOutlet var genericModelTableView: UITableView!
    var manager:STMeshManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Do additional setup after loading the view. */
        self.navigationItem.title = "Generic Model"
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"model_selection"), style: .plain, target: self, action: #selector(handleModelSelectionButton))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        UserDefaults.standard.set("Generic", forKey:KConstantSelectedModelScreen)
        manager = STMeshManager.getInstance(self)
        manager.getGenericModel().delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        genericModelsNode = [STMeshNode]()
        getAllGenericModelNode()
        setUpMyLabel()
        genericModelTableView.reloadData()
        manager?.startNetwork(0)
        if(!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForGenricModelListViewController)){
            DispatchQueue.main.asyncAfter(deadline:.now()+1)
            {
                if self.genericModelsNode.count > 0 {
                    UserHelperScreenManager.HelpScreenForGenricModelViewController(objGenericModelNodeListController: self)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* Action after clicking model button at Top */
    @objc func handleModelSelectionButton(){
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelListViewController", type:ModelListViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    
    /* This Method return all nodes thats support generic model*/
    func getAllGenericModelNode()
    {
        for node in  currentNetworkDataManager.currentNetworkData.nodes{
            var isGenericModel = false
            for elements in ((node as? STMeshNode)?.elementList)!{
                for model in ((elements as? STMeshElement)?.modelList)!{
                    
                    if ((model as? STMeshModel)?.modelId)! >= 0x1000 && ((model as? STMeshModel)?.modelId)! <= 0x1015{
                        isGenericModel = true
                    }
                }
            }
            if isGenericModel{
                genericModelsNode.append((node as? STMeshNode)!)
            }
        }
    }
    
    /* This Method set message on screen when there is node that support generic Model*/
    func setUpMyLabel() {
        lblNew.backgroundColor = UIColor.white
        lblNew.text = "There are no nodes in your network that support generic model. please add nodes by tapping add button in device tab "
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


extension GenericModelNodeListController :UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lblNew.isHidden = genericModelsNode.count > 0 ? true  : false
        return genericModelsNode.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"GenericModelListTableCell", for:indexPath) as? GenericModelListTableCell
        cell?.indexPath = indexPath
        cell?.configureCell(node: (genericModelsNode[indexPath.row]) )
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let addressString = (genericModelsNode[indexPath.row] ).nodeUUID {
            let size = CGSize(width:screenWidth - 173 , height: 50)
            let attributes = [kCTFontAttributeName:UIFont.systemFont(ofSize:15)]
            let estimatedFrame = NSString(string:addressString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context:nil)
            let elementCount = (genericModelsNode[indexPath.row] ).elementList.count ;
            
            return (estimatedFrame.height +  45 + 64 * CGFloat(elementCount))
        }
        return (1.78 * 39.5)
    }
}


extension GenericModelNodeListController :STMeshManagerDelegate{
    
}

extension GenericModelNodeListController :STMeshGenericModelDelegate{
    func genericModel(_ genericModel: STMeshGenericModel!, didReceiveOnOffStatusFromAddress peerAddress: UInt16, presentOnOff presentState: UInt8, targetOnOff targetState: UInt8, remainingTime time: UInt8, isTargetStatePresent stateFlag: Bool) {
    }
}
// MARK:Intensity Delegate
extension GenericModelNodeListController:IntensityDelegate{
    
    func IntensitySliderChangeValue(slider:UISlider,address:UInt16){
        manager?.getGenericModel().setGenericLevel(address, level:Int16((Float(String(format:"%.0f",slider.value)))! * ((Float(INT16_MAX))/100)), isUnacknowledged:UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
        
    }
}

// MARK:Generic Control Delegate
extension GenericModelNodeListController :GenericControlDelegate{
    
    func didBatteryButtonClick(element: STMeshElement) {
        
    }
    
    func didLevelButtonClick(element: STMeshElement) {
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelControlPopUpController", type:ModelControlPopUpController.self)
        controller.isVersionPage = false
        controller.delegate = self
        controller.address = element.unicastAddress
        self.tabBarController?.navigationController?.present(controller, animated:false, completion: nil)
    }
    
    func didSwitchButtonToggle(element:STMeshElement, index:IndexPath, isOn:Bool){
        manager.getGenericModel().setGenericOnOff(element.unicastAddress, isOn: isOn, isUnacknowledged: UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
    }
}


// MARK: Generic Control Protocol
protocol GenericControlDelegate {
    
    func didLevelButtonClick(element:STMeshElement)
    func didBatteryButtonClick(element:STMeshElement)
    func didSwitchButtonToggle(element:STMeshElement, index:IndexPath, isOn:Bool)
}


class GenericModelListTableCell: UITableViewCell {
    
    @IBOutlet var nodeNameLbl: UILabel!
    @IBOutlet var nodeUuidLbl: UILabel!
    @IBOutlet var elementTableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var loaderView: UIView!
    
    var delegate :GenericControlDelegate?
    var meshNode: STMeshNode!
    var indexPath:IndexPath?
    
    func configureCell(node: STMeshNode) -> Void {
        self.meshNode = node;
        self.elementTableView.reloadData()
        self.nodeNameLbl.text = meshNode.nodeName
        self.nodeUuidLbl.text = meshNode.nodeUUID.uppercased()
    }
    
    // MARK: Button Action
    @objc func didLevelButtonClick(_ sender:UIButton){
        delegate?.didLevelButtonClick(element:meshNode.elementList![sender.tag] as! STMeshElement)
    }
    
    @objc func didBatteryButtonClick(_ sender:UIButton){
        delegate?.didBatteryButtonClick(element:meshNode.elementList![sender.tag] as! STMeshElement)
    }
    
    @objc func didElementSwitchButtonToggle( _ sender:UISwitch){
        delegate?.didSwitchButtonToggle(element:meshNode.elementList![sender.tag] as! STMeshElement, index: indexPath!, isOn: sender.isOn)
    }
    
}
// MARK: Table View Delegates
extension GenericModelListTableCell :UITableViewDelegate,UITableViewDataSource{
    
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
        cell.batteryButton.addTarget(self, action: #selector(self.didBatteryButtonClick(_:)), for:.touchUpInside)
        cell.switchElement.addTarget(self, action:#selector(self.didElementSwitchButtonToggle(_:) ), for:.valueChanged)
        return cell;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
}

// MARK: User Helper Screen Delegate
extension GenericModelNodeListController : UserHelperScreenDelegate{
    func helperScreenClosed() {
        print("Genric Model helper screem is closed!!")
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForGenricModelListViewController)
        
    }
    
}
