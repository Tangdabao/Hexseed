/**
 ******************************************************************************
 * @file    LightingHSLPopupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    14-Sep-2018
 * @brief   Cell class for "Lighting HSL Popup" View.
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

enum HSLEnum:Int{
    case HSL = 0
    case Hue
    case Saturation
}

let hueMaxValue =  65535.0
let saturationMaxValue = 65535.0
let lightnessMaxValue = 65535.0

class LightingHSLPopupViewController: UIViewController {
    
    
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var HSLView: UIView!
    @IBOutlet weak var hsl_HueSlider: UISlider!
    @IBOutlet weak var hsl_HueSliderValueLbl: UILabel!
    @IBOutlet weak var hsl_SaturationSlider: UISlider!
    @IBOutlet weak var hsl_HueSaturationValueLbl: UILabel!
    @IBOutlet weak var hsl_LightnessSlider: UISlider!
    @IBOutlet weak var hsl_LightnessSliderValueLbl: UILabel!
    
    
    @IBOutlet weak var hueView: UIView!
    @IBOutlet weak var hueSlider: UISlider!
    @IBOutlet weak var hueSliderValueLbl: UILabel!
    
    @IBOutlet weak var saturationView: UIView!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var saturationSliderValueLbl: UILabel!
    
    
    var  address:UInt16!
    var manager:STMeshManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = STMeshManager.getInstance(self)
        manager.getLightingModel().delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hueSliderAction(_ sender: UISlider) {
        hueSliderValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func saturationSlider(_ sender: UISlider) {
        saturationSliderValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func HSLHueSliderAction(_ sender: UISlider) {
        hsl_HueSliderValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func HSSaturationSliderAction(_ sender: UISlider) {
        hsl_HueSaturationValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func HSL_LightnessSliderAction(_ sender: UISlider) {
        hsl_LightnessSliderValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated:false, completion:nil)
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        hslApiCallForLightingControll()
    }
    
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        changeHSLSengment(selected: HSLEnum(rawValue:sender.selectedSegmentIndex)!)
    }
    
    
    func changeHSLSengment(selected:HSLEnum){
        
        switch selected {
        case .HSL:
            HSLView.isHidden = false
            hueView.isHidden = true
            saturationView.isHidden = true
            break
        case .Hue:
            HSLView.isHidden = true
            hueView.isHidden = false
            saturationView.isHidden = true
            break
        case .Saturation:
            HSLView.isHidden = true
            hueView.isHidden = true
            saturationView.isHidden = false
            break
            
        }
    }
    
    
    func hslApiCallForLightingControll(){
        
        let isUnaknowledged = UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false
        switch segment.selectedSegmentIndex {
        case 0:
            let hslHueValue = UInt16(Double(hsl_HueSlider.value) * (saturationMaxValue / 100))
            let hslSaturationValue = UInt16(Double(hsl_SaturationSlider.value) * (saturationMaxValue / 100))
            let hslLightnessValue = UInt16(Double(hsl_LightnessSlider.value) * (lightnessMaxValue / 100))
            
            // manager.getLightingModel().setLightingHSL(address, lightnessValue:hslLightnessValue, hueValue: hslHueValue, saturationValue:hslSaturationValue, isUnacknowledged: isUnaknowledged)
            manager.getLightingModel().setLightingHSL(address, lightnessValue:hslLightnessValue, hueValue:hslHueValue, saturationValue:hslSaturationValue , transitionTime:10, withDelay:0, isUnacknowledged: isUnaknowledged)
            break
        case 1:
            let hueValue =  UInt16(Double(hueSlider.value) * (hueMaxValue / 100))
            self.manager.getLightingModel().setLightingHSLHue(address, hueValue:hueValue, transitionTime:10, withDelay: 0, isUnacknowledged:isUnaknowledged)
            //self.manager.getLightingModel().setLightingHSLHue(address, hueValue:hueValue, isUnacknowledged: UserDefaults.standard.bool(forKey: KConstantReliableModeKey) ? true : false)
            break
        case 2:
            let saturationValue =  UInt16(Double(saturationSlider.value) * (saturationMaxValue / 100))
            //self.manager.getLightingModel().setLightingHSLSaturation(address, saturationValue:saturationValue, isUnacknowledged: isUnaknowledged)
            self.manager.getLightingModel().setLightingHSLSaturation(address, saturationValue: saturationValue, transitionTime:10, withDelay:0, isUnacknowledged:isUnaknowledged)
            break
        default:
            break
        }
        
    }
}
extension LightingHSLPopupViewController :STMeshManagerDelegate{
    
}

extension LightingHSLPopupViewController:STMeshLightingModelDelegate{
    
    func lightingModel(_ lightingModel: STMeshLightingModel!, didReceiveHSLSaturationStatusFromAddress peerAddress: UInt16, presentSaturation: UInt16, targetSaturation: UInt16, remainingTime time: UInt16, isTargetStatePresent stateFlag: Bool) {
        
    }
    func lightingModel(_ lightingModel: STMeshLightingModel!, didReceiveHSLHueStatusFromAddress peerAddress: UInt16, presentHue: UInt16, targetHue: UInt16, remainingTime time: UInt16, isTargetStatePresent stateFlag: Bool) {
        
    }
    
    func lightingModel(_ lightingModel: STMeshLightingModel!, didReceiveHSLStatusFromAddress peerAddress: UInt16, lightnessValue lightness: UInt16, hueValue hue: UInt16, saturationValue saturation: UInt16, remainingTime: UInt8, isTargetStatePresent stateFlag: Bool) {
        
    }
    
    
    
}
