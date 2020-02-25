/**
 ******************************************************************************
 * @file    ProvisionedElementsTableViewCell.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.06.000
 * @date    01-Mar-2018
 * @brief   ViewCell class for ProvisionedElementsTable.
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
protocol ElementCellProtocol {
    func elementSwitchStateChanged(tableViewIndex: IndexPath , state: Bool) -> Bool;
}

class ProvisionedElementsTableViewCell: UITableViewCell {
    
    
    @IBOutlet var collectionViewWidth: NSLayoutConstraint!
    var element :STMeshElement!
    
    var delegate : ElementCellProtocol?
    
    @IBOutlet weak var switchElement: UISwitch!
    @IBOutlet weak var lblElementName: UILabel!
    @IBOutlet var modelCollectionView: UICollectionView!
    @IBOutlet weak var btnElementSetting: UIButton!
    @IBOutlet var modelView: UIView!
    
    @IBOutlet var toggleView: UIView!
    @IBOutlet var versionView: UIView!
    @IBOutlet var intensityView: UIView!
    @IBOutlet var intensityButton: UIButton!
    @IBOutlet var versionButton: UIButton!
    @IBOutlet var toggleButton: UIButton!
    
    @IBOutlet var battaryControlView: UIView!
    @IBOutlet var levelButton: UIButton!
    @IBOutlet var batteryButton: UIButton!
    @IBOutlet var levelControlView: UIView!
    @IBOutlet weak var hslControlView: UIView!
    @IBOutlet weak var hslControlButton: UIButton!
    
    
    
    
    // Sensor Model Outlets
    @IBOutlet weak var viewAccelerometer: UIView!
    @IBOutlet weak var viewTemperature: UIView!
    @IBOutlet weak var viewPressure: UIView!
    
    @IBOutlet weak var imgViewPressureIcon: UIImageView!
    @IBOutlet weak var imgViewTemeratureIcon: UIImageView!
    @IBOutlet weak var imgViewAccelerometerIcon: UIImageView!
    
    
    @IBOutlet weak var lblPressureValue: UILabel!
    @IBOutlet weak var lblTemperatureValue: UILabel!
    @IBOutlet weak var lblAccelerometerValue: UILabel!
    @IBOutlet weak var btnRefreshSensorModel: UIButton!
    
    @IBOutlet weak var btnPressureValue: UIButton!
    @IBOutlet weak var btnTemperatureValue: UIButton!
    
    var indexPath : IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func cofigureElementForNode(meshNode: STMeshNode) -> Void {
        let element = meshNode.elementList[(indexPath?.row)!] as! STMeshElement
        self.element = element
        self.lblElementName.text = element.elementName
        self.switchElement.setOn(false, animated: false)
        self.switchElement.onTintColor = UIColor .green
        self.switchElement.tintColor = UIColor .lightGray
        self.switchElement.layer.cornerRadius = 16
        self.switchElement.backgroundColor = UIColor .lightGray
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    @IBAction func intensityButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func toggleButtonAction(_ sender: Any) {
    }
    
    @IBAction func versionButtonAction(_ sender: Any) {
    }
    
    
    func initialModelUI(){
        collectionViewWidth.constant = CGFloat( ((CommonModel.getModelGroup(element: element)).count * 30)  > 120  ? 120 : ((CommonModel.getModelGroup(element: element)).count * 31))
    }
    
    // MARK : Switch Elements Value Changed
    @IBAction func switchElementValueChanged(_ sender: Any) {
        
        let Result =  self.delegate?.elementSwitchStateChanged(tableViewIndex: indexPath! , state: switchElement.isOn);
        print(Result ?? true)
    }
    
    override func prepareForReuse() {
        if collectionViewWidth != nil {
            collectionViewWidth.constant = 105
            modelCollectionView.dataSource = self
            modelCollectionView.delegate = self
            modelCollectionView.reloadData()
        }
    }
    
    @objc func didClick(_ sendor:UIButton){
        let controller = UIStoryboard.loadViewController(storyBoardName: "Main", identifierVC: "InfoViewController", type: InfoViewController.self)
        controller.ElementInfo = element
        controller.selectedIndex = sendor.tag
        CommonUtils.getTopNavigationController().present(controller, animated:true , completion: nil)
    }
}

/*MARK:  Collection View Detegate */
extension ProvisionedElementsTableViewCell :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  (CommonModel.getModelGroup(element: element)).count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 28, height:28)
    }
    
    /* This determines the value of labels and buttons on each cell */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModelCollectionViewCell", for: indexPath) as! ModelCollectionViewCell
        var groupName = (CommonModel.getModelGroup(element: element))
        let charEntered = (groupName[indexPath.item] as String)
        cell.modelButton.tag = indexPath.item
        cell.modelButton.addTarget(self, action: #selector(self.didClick(_:)), for: .touchUpInside)
        cell.modelButton.setTitle(String(charEntered[0] as Character).uppercased(), for: .normal)
        return cell
    }
}


class ModelCollectionViewCell :UICollectionViewCell{
    @IBOutlet var modelButton: UIButton!
    
    override func prepareForReuse() {
    }
}
