/**
 ******************************************************************************
 * @file    LightingCTLPopupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    29-June-2018
 * @brief   ViewController for Lighting Model CTL pop-up View.
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

protocol ctlPopDelegate {
    func didCTLValueChanges(DeltaUVValue:Float,tempValue:Float, lightnessValue:Float,address :UInt16)
    func didTemperatureValuesChange(tempValue:Float,DeltaUVValue:Float,address :UInt16)
}

extension ctlPopDelegate{
    func didCTLValueChanges(DeltaUVValue:Float,tempValue:Float, lightnessValue:Float,address :UInt16){
        
    }
    func didTemperatureValuesChange(tempValue:Float,DeltaUVValue:Float,address :UInt16){
        
    }
}

class LightingCTLPopupViewController: UIViewController {
    
    @IBOutlet weak var ctlColorSlider: UISlider!
    @IBOutlet weak var ctlLightSlider: UISlider!
    @IBOutlet weak var ctlTemperatureSlider: UISlider!
    
    @IBOutlet weak var tempDeltaUVSlider: UISlider!
    @IBOutlet weak var tempTemperatureSlider: UISlider!
    
    @IBOutlet weak var tempValueLbl: UILabel!
    @IBOutlet weak var colorValueLbl: UILabel!
    @IBOutlet weak var lightnessValueLbl: UILabel!
    
    @IBOutlet weak var TempDeltaUVValueLbl: UILabel!
    @IBOutlet weak var temptemperatureValueLbl: UILabel!
    
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var ctlView: UIView!
    var isCTL = true
    var delegate:ctlPopDelegate?
    var address :UInt16?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCTL{
            tempView.isHidden = true
            ctlView.isHidden = false
        }else{
            tempView.isHidden = false
            ctlView.isHidden = true
        }
    }
    
    
    @IBAction func sendButtionAction(_ sender: UIButton) {
        //self.dismiss(animated:true, completion:nil)
        delegate?.didCTLValueChanges(DeltaUVValue:(Float(String(format:"%.2f",ctlColorSlider.value)))! * (32767), tempValue:ctlTemperatureSlider.value, lightnessValue: ((Float(String(format:"%.0f",ctlLightSlider.value)))! * (65535/100)), address: address!)
    }
    
    @IBAction func closeButtionAction(_ sender: UIButton) {
        self.dismiss(animated:true, completion:nil)
    }
    
    @IBAction func tempDeltaUVSlider(_ sender: UISlider) {
        TempDeltaUVValueLbl.text = String(format:"%.2f",sender.value) as String
    }
    
    @IBAction func tempTemperatureSlider(_ sender: UISlider) {
        temptemperatureValueLbl.text = String(format:"%i K", Int(sender.value)) as String
        
    }
    
    @IBAction func tempSendButtonAction(_ sender: UIButton) {
        delegate?.didTemperatureValuesChange(tempValue:(tempTemperatureSlider.value), DeltaUVValue:((Float(String(format:"%.0f",tempDeltaUVSlider.value)))! * 32767), address: address!)
    }
    
    @IBAction func colorSliderAction(_ sender: UISlider) {
        colorValueLbl.text = NSString(format:"%.2f", sender.value) as String
    }
    
    @IBAction func tempSliderAction(_ sender: UISlider) {
        tempValueLbl.text = NSString(format:"%i K", Int(sender.value)) as String
    }
    
    @IBAction func LightnessSliderAction(_ sender: UISlider) {
        lightnessValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func ctlSegmentAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            tempView.isHidden = true
            ctlView.isHidden = false
        }else{
            tempView.isHidden = false
            ctlView.isHidden = true
        }
    }
    
    
}
