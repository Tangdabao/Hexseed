/**
 ******************************************************************************
 * @file    NodeInformationViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    09-Oct-2018
 * @brief   ViewController for "Node Information" View.
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

class NodeInformationViewController: UIViewController {
    
    var nodeDetails:STMeshNode!
    @IBOutlet weak var nodeNameLbl: UILabel!
    @IBOutlet weak var nodeFeatureLbl: UILabel!
    @IBOutlet weak var nodeUUIDLbl: UILabel!
    @IBOutlet weak var nodeUnicastAddressLbl: UILabel!
    
    @IBOutlet weak var versionIdLbl: UILabel!
    @IBOutlet weak var productIDLbl: UILabel!
    @IBOutlet weak var companyIdLbl: UILabel!
    @IBOutlet weak var companyNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Node Information"
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
    }
    
    func setData(){
        nodeNameLbl.text = nodeDetails.nodeName ?? "NA"
        nodeUUIDLbl.text = nodeDetails.nodeUUID ?? "NA"
        nodeUnicastAddressLbl.text = "\(String(describing: nodeDetails!.unicastAddress))"
        nodeNameLbl.text = nodeDetails.nodeName ?? "NA"
        nodeFeatureLbl.text = getFeatureTextString()
        productIDLbl.text = nodeDetails.pid ?? "NA"
        versionIdLbl.text = nodeDetails.vid ?? "NA"
        companyIdLbl.text =  nodeDetails.cid != nil ? NSString(format:"0x%04x",UInt16(nodeDetails.cid) ?? 0) as String : "NA"
        companyNameLbl.text =  nodeDetails.cid != nil ?  CompanyIdentifiers().humanReadableNameFromIdentifier(UInt16(nodeDetails.cid) ?? 00) : "NA"
    }
    
    func getFeatureTextString()-> String
    {
        var featuretextString = ""
        if nodeDetails.features.proxy == 1{
            featuretextString  = featuretextString + "Proxy"
        }
        if nodeDetails.features.relay == 1{
            if featuretextString.count > 0 {
                featuretextString  = featuretextString + ", "  + "Relay"
            }else{
                featuretextString  = featuretextString   + "Relay"
            }
        }
        if nodeDetails.features.friendFeature == 1{
            if featuretextString.count > 0 {
                featuretextString  = featuretextString + ", "  + "Friend"
            }else{
                featuretextString  = featuretextString   + "Friend"
            }
        }
        if nodeDetails.features.lowPower == 1{
            if featuretextString.count > 0 {
                featuretextString  = featuretextString + ", "  + "Low Power"
            }else{
                featuretextString  = featuretextString   + "Low Power"
            }
        }
        return featuretextString.count > 0  ?  featuretextString : "NA"
    }
}
