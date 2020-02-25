/**
 ******************************************************************************
 * @file    InfoViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.06.000
 * @date    17-Nov-2017
 * @brief  ViewController for "Node Information" View.
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

//Main Screen -> Click on Information Button(!) -> Information View Controller
class InfoViewController: UIViewController {
    
    @IBOutlet var popupInfoView: UIView!
    @IBOutlet var name: UILabel!
    @IBOutlet var uuid: UILabel!
    @IBOutlet var ntype: UILabel!
    @IBOutlet var uuidName: UILabel!
    @IBOutlet weak var lblDeviceTpe: UILabel!
    @IBOutlet var modeGroupName: UIButton!
    
    var infoNode:STMeshNode?
    var nodeType = "Lighting"
    var isComingFromElementView : Bool = false
    var ElementInfo : STMeshElement!
    var selectedIndex:Int!
    var modelGroupName = ""
    var index = 0
    var modelArray :[STMeshModel] = [STMeshModel]()
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        popupInfoView.layer.cornerRadius = 20
        popupInfoView.layer.masksToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (CommonModel.getModelGroup(element: ElementInfo)).count > selectedIndex-1{
            modeGroupName.setTitle((CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] + " Model Group" , for: .normal)
        }
        checkModel()
        
    }
    
    // MARK: selector
    @IBAction func popupInfoClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkModel()
    {
        for model in ElementInfo.modelList{
            
            if (CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] == "Generic" && (model as? STMeshModel)!.modelId >= 0x0FFF && ((model as? STMeshModel)?.modelId)! <= 0x1016
            {
                modelArray.append(model as! STMeshModel)
            }
            else if (CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] == "Vendor" && (model as? STMeshModel)!.modelId == 0x10030{
                
                modelArray.append(model as! STMeshModel)
            }
                
            else if (CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] == "Sensor" && (model as? STMeshModel)!.modelId >= 0x1100 && ((model as? STMeshModel)?.modelId)! <= 0x1102{
                
                modelArray.append(model as! STMeshModel)
            }
            else if (CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] == "Time & Scene" && (model as? STMeshModel)!.modelId >= 0x1200 && ((model as? STMeshModel)?.modelId)! <= 0x1208{
                
                modelArray.append(model as! STMeshModel)
            }
            else if (CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] == "Lighting" && (model as? STMeshModel)!.modelId >= 0x1300 && ((model as? STMeshModel)?.modelId)! <= 0x1311{
                
                modelArray.append(model as! STMeshModel)
            }
            else if (CommonModel.getModelGroup(element: ElementInfo))[selectedIndex] == "Configuration" && (model as? STMeshModel)!.modelId >= 0x0000 && ((model as? STMeshModel)?.modelId)! <= 0x0003{
                
                modelArray.append(model as! STMeshModel)
            }
        }
    }
    
}//class ends


extension InfoViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return modelArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell  =  tableView.dequeueReusableCell(withIdentifier:"ModelDetailsHeaderTableViewCell", for: indexPath) as? ModelDetailsHeaderTableViewCell
            
            return cell!
        }
        else{
            let cell  =  tableView.dequeueReusableCell(withIdentifier:"ModelDetailsTableViewCell", for: indexPath) as? ModelDetailsTableViewCell
            cell!.modelIdLBl.text = "0x" +  (String(modelArray[indexPath.row - 1].modelId, radix: 16)).uppercased()
            //NSString(format:"%i",modelArray[indexPath.row - 1].modelId) as String
            cell!.modelNameLbl.text = modelArray[indexPath.row - 1].modelName
            return cell!
        }
    }
    
}

class ModelDetailsTableViewCell:UITableViewCell{
    
    @IBOutlet var modelIdLBl: UILabel!
    @IBOutlet var modelNameLbl: UILabel!
}
class ModelDetailsHeaderTableViewCell:UITableViewCell{
    
}


