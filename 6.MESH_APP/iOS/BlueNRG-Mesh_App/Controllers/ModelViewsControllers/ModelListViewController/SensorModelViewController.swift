/**
 ******************************************************************************
 * @file    SensorModelViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    05-Oct-2018
 * @brief   ViewController for "SensorModel" View.
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

// Sensor ID
let KConstantSensorModel_Model_ID = 0x1100 ;

// User Defaults
let kConstantSensorModelUserDefaultKey = "Sensor"


let kConstantSensorModel_TemperatureValue = "Temperature Value for Current Session"
let kConstantSensorModel_PressureValue = "Pressure Value for Current Session"
let kConstantSensorModel_AccelerometerValue = "Accolerometer Value for Current Session"


// Images Constants
let kImageSensoreModel_TemperatureEnabledImageName  = "temperature_Enabled"
let kImageSensoreModel_TemperatureDisabledImageName  = "temperature_Disabled"
let kImageSensoreModel_PressureEnabledImageName  = "pressure_Enabled"
let kImageSensoreModel_PressureDisabledImageName  = "pressure_Disabled"
let kImageSensoreModel_AccelerometerEnabledImageName  = "accelerometer_Enabled"
let kImageSensoreModel_AccelerometerDisabledImageName  = "accelerometer_Disabled"
let KSensorModel_SensorModelListTableCellIdentifier = "SensorModelListTableCell"



class SensorModelViewController: STMeshBaseViewController {
    var didGetVersionResponse = true
    let lblSensorModelNodesStatus = UILabel()
    var sensorModelNodes:[STMeshNode] = [STMeshNode]()
    var meshManager : STMeshManager?
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var objSensorModel : STMeshSensorModel?
    @IBOutlet weak var tblViewSensorModel: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sensor Model"
        /* Back button */
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"model_selection"), style: .done, target: self, action: #selector(handleModelSelectionButton))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        UserDefaults.standard.set(kConstantSensorModelUserDefaultKey, forKey:KConstantSelectedModelScreen)
        meshManager = STMeshManager.getInstance(self)
        objSensorModel =  meshManager?.getSensorModel()
        objSensorModel!.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sensorModelNodes = [STMeshNode]()
        getAllSensorModelNodes()
        setUpMyLabel()
        tblViewSensorModel.reloadData()
        meshManager?.startNetwork(0)
    }
    
    // MARK: Handle Model Selection Button
    @objc func handleModelSelectionButton(){
        let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"ModelListViewController", type:ModelListViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getAllSensorModelNodes()
    {
        
        for node in  currentNetworkDataManager.currentNetworkData.nodes{
            var isSensorModelTrue = false
            for elements in ((node as? STMeshNode)?.elementList)!{
                for model in ((elements as? STMeshElement)?.modelList)!{
                    
                    if ((model as? STMeshModel)?.modelId)! == KConstantSensorModel_Model_ID {
                        isSensorModelTrue = true
                    }
                }
            }
            if isSensorModelTrue{
                sensorModelNodes.append((node as? STMeshNode)!)
            }
        }
    }
    func setUpMyLabel() {
        
        lblSensorModelNodesStatus.backgroundColor = UIColor.white
        lblSensorModelNodesStatus.text = "There are no nodes in your network that support Sensor model. please add nodes by tapping add button in device tab"
        lblSensorModelNodesStatus.textColor = UIColor.black
        lblSensorModelNodesStatus.numberOfLines = 3
        lblSensorModelNodesStatus.textAlignment = .center
        lblSensorModelNodesStatus.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblSensorModelNodesStatus)
        
        let widthConstraint = NSLayoutConstraint(item: lblSensorModelNodesStatus, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth-40)
        let heightConstraint = NSLayoutConstraint(item: lblSensorModelNodesStatus, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70)
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: nil,
            views: ["superview":view, "label":lblSensorModelNodesStatus])
        view.addConstraints(constraints)
        
        /* Center vertically */
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":view, "label":lblSensorModelNodesStatus])
        
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
    }
    
    
    
}

extension SensorModelViewController :UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lblSensorModelNodesStatus.isHidden = sensorModelNodes.count > 0 ? true :false
        return sensorModelNodes.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:KSensorModel_SensorModelListTableCellIdentifier, for:indexPath) as? SensorModelListTableCell
        cell!.configureCell(node:sensorModelNodes[indexPath.row] )
        cell!.delegate = self
        cell!.indexPath = indexPath
        //  SwiftProgressLoader.show(title:nil, currentView:cell!, animated: true)
        
        cell?.loaderView.isHidden = true
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let addressString = (sensorModelNodes[indexPath.row] ).nodeUUID {
            let size = CGSize(width:screenWidth - 173 , height: 50)
            let attributes = [kCTFontAttributeName:UIFont.systemFont(ofSize:15)]
            let estimatedFrame = NSString(string:addressString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context:nil)
            let elementCount = (sensorModelNodes[indexPath.row] ).elementList.count ;
            
            return (estimatedFrame.height +  45 + 64 * CGFloat(elementCount))
        }
        return (1.78 * 39.5)
    }
}

var SelectedIndexPath : IndexPath = IndexPath(item: 0, section: 0)
extension SensorModelViewController : SensorModelControlDelegate{
    func didRefreshButtonClicked(element: STMeshElement, index: IndexPath) {
        SelectedIndexPath = index
        objSensorModel?.sensorModelGetSensorsWithoutPropertyID(element.unicastAddress)
    }
    func didClickPressureButton(element:STMeshElement){
        objSensorModel?.sensorModelGetSensorsWithPropertyID(forPeer: element.unicastAddress, propertyID: UInt16(0x2A6D))

    }
    func didClickTemperatureButton(element:STMeshElement){
        
        objSensorModel?.sensorModelGetSensorsWithPropertyID(forPeer: element.unicastAddress, propertyID: UInt16(0x004F))
        
    }
}


extension SensorModelViewController : STMeshManagerDelegate{
}

extension SensorModelViewController : STMeshSensorModelDelegate{
    
    
    func sensorModel(_ SensorModel: STMeshSensorModel!, didReceiveSensorStatusFromAddressWithData peerAddress: UInt16, sensorData: NSMutableArray!) {
        // set the user Default Value for Temperature, Pressure and Accelerometer.
        var selectedSensorElement : STMeshElement?
        var selectedSensorNode : STMeshNode?
        for node in sensorModelNodes{
            
            for eachElement in node.elementList as! [STMeshElement]{
                
                if eachElement.unicastAddress == peerAddress {
                    selectedSensorElement = eachElement
                    selectedSensorNode = node
                    break
                }
            }
        }
        
        if (selectedSensorElement != nil){
            for eachSensorValue in sensorData {
                let sensorDataValue = eachSensorValue as! STMeshSensorData
                if let strSensorType = sensorDataValue.sensorName ,  (strSensorType.caseInsensitiveCompare("Temperature") == .orderedSame){
                    selectedSensorElement!.sensorModel.sensorTemperatureValue = (sensorDataValue.sensorValue).floatValue;
                }
                if let strSensorType = sensorDataValue.sensorName , (strSensorType.caseInsensitiveCompare("Pressure") == .orderedSame){
                    selectedSensorElement!.sensorModel.sensorPressureValue = (sensorDataValue.sensorValue).floatValue;
                }
                
            }
        }
        
        if (sensorData.count > 0 && selectedSensorNode != nil){
            
            let indexValue = sensorModelNodes.index(of: selectedSensorNode!)
            let selectedNodeIndex = IndexPath(item: indexValue!, section: 0)
            tblViewSensorModel.reloadRows(at: [selectedNodeIndex], with: .automatic)
        }
    }
}
//NOTE: No Need in this release
protocol SensorModelControlDelegate {
    func didClickPressureButton(element:STMeshElement)
    func didClickTemperatureButton(element:STMeshElement)
    func didClickAccelerometerButton(element:STMeshElement)
    
    func didRefreshButtonClicked(element:STMeshElement, index:IndexPath)
    
}

extension SensorModelControlDelegate{
    func didClickPressureButton(element:STMeshElement){
    }
    
    func didClickTemperatureButton(element:STMeshElement){
    }
    
//    func didClickTemperatureButton(element:STMeshElement){
//
//    }
    func didClickAccelerometerButton(element:STMeshElement){
    }
}

class SensorModelListTableCell: UITableViewCell {
    
    @IBOutlet var loaderView: UIView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var tblViewElement: UITableView!
    @IBOutlet var nodeNameLbl: UILabel!
    @IBOutlet var uuidLbl: UILabel!
    
    var meshNode: STMeshNode!
    var indexPath:IndexPath?
    var delegate: SensorModelControlDelegate?
    
    func configureCell(node: STMeshNode) -> Void {
        self.meshNode = node;
        self.nodeNameLbl.text = node.nodeName
        self.uuidLbl.text = node.nodeUUID.uppercased()
        
        tblViewElement.reloadData()
    }
    
    @objc func didSwitchButtonStatusChange(_ sendor:UISwitch){
        delegate?.didRefreshButtonClicked(element:meshNode.elementList![sendor.tag] as! STMeshElement, index: indexPath!)
    }
    @objc func didPressureIconClicked(_ sendor:UIButton){
        delegate?.didClickPressureButton(element:meshNode.elementList![sendor.tag] as! STMeshElement)
    }
    @objc func didTemperatureIconClicked(_ sendor:UIButton){
        delegate?.didClickTemperatureButton(element:meshNode.elementList![sendor.tag] as! STMeshElement)
    }
    
    
}


extension SensorModelListTableCell :UITableViewDelegate,UITableViewDataSource{
    // MARK: Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meshNode != nil ?  meshNode.elementList.count:0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ElementCell", for: indexPath) as! ProvisionedElementsTableViewCell
        
        cell.indexPath = indexPath
        let temperatureValue = abs((self.meshNode.elementList[indexPath.row] as! STMeshElement).sensorModel.sensorTemperatureValue)
        print("Mesh Node Name : ", self.meshNode.nodeName ,"And Temperature Value: ", temperatureValue)
        print("Index value: ", indexPath.row)
        
        if  abs((self.meshNode.elementList[indexPath.row] as! STMeshElement).sensorModel.sensorTemperatureValue) > 0.1 {
            cell.imgViewTemeratureIcon.image = UIImage.init(named: kImageSensoreModel_TemperatureEnabledImageName)
            let strTemmpFloatValue = String(format: "%0.2f", (self.meshNode.elementList[indexPath.row] as! STMeshElement).sensorModel.sensorTemperatureValue)
            cell.lblTemperatureValue.text = strTemmpFloatValue
        }
        else{
            cell.imgViewTemeratureIcon.image = UIImage.init(named: kImageSensoreModel_TemperatureDisabledImageName)
            cell.lblTemperatureValue.text = "Temperature"
            
        }
        if  abs((self.meshNode.elementList[indexPath.row] as! STMeshElement).sensorModel.sensorPressureValue) > 0.1 {
            cell.imgViewPressureIcon.image = UIImage.init(named: kImageSensoreModel_PressureEnabledImageName)
            let strPressureValue = String(format: "%0.2f", (self.meshNode.elementList[indexPath.row] as! STMeshElement).sensorModel.sensorPressureValue)
            cell.lblPressureValue.text = strPressureValue
        }
        else{
            cell.imgViewPressureIcon.image = UIImage.init(named: kImageSensoreModel_PressureDisabledImageName)
            cell.lblPressureValue.text = "Pressure"
            
        }
        
        cell.btnRefreshSensorModel.tag = indexPath.row
        
        // pass tag here
        cell.btnRefreshSensorModel.addTarget(self, action: #selector(self.didSwitchButtonStatusChange(_:)), for:.touchUpInside)
        cell.imgViewPressureIcon.isUserInteractionEnabled = true
        

        // Pressure Selector Setup
        cell.btnPressureValue.addTarget(self, action: #selector(self.didPressureIconClicked(_:)), for: .touchUpInside)
        cell.btnPressureValue.tag = indexPath.row

        // Temperature Selector Setup
        cell.btnTemperatureValue.addTarget(self, action: #selector(self.didTemperatureIconClicked(_:)), for: .touchUpInside)
        cell.btnTemperatureValue.tag = indexPath.row
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
}

