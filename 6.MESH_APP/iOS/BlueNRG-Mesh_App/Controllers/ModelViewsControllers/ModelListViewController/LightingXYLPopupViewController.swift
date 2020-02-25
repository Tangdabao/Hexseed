/**
 ******************************************************************************
 * @file    LightingXYLPopupViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    14-Sep-2018
 * @brief   Cell class for "Lighting XYL Popup" View.
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

enum xylEnum:Int{
    case XYL = 0
    case X
    case Y
}
class LightingXYLPopupViewController: UIViewController {
    
    @IBOutlet weak var xylSegment: UISegmentedControl!
    
    
    @IBOutlet weak var xylView: UIView!
    @IBOutlet weak var xyl_XValueSlider: UISlider!
    @IBOutlet weak var xyl_XValueLbl: UILabel!
    @IBOutlet weak var xyl_YValueSlider: UISlider!
    @IBOutlet weak var xyl_YValueLbl: UILabel!
    @IBOutlet weak var xyl_LightnessValueSlider: UISlider!
    @IBOutlet weak var xyl_LightnessValueLbl: UILabel!
    
    @IBOutlet weak var yView: UIView!
    @IBOutlet weak var ySliderValueLbl: UILabel!
    @IBOutlet weak var ySlider: UISlider!
    
    @IBOutlet weak var xView: UIView!
    @IBOutlet weak var xslider: UISlider!
    @IBOutlet weak var xSliderValueLbl: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func x_sliderAction(_ sender: UISlider) {
        xSliderValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func y_sliderAction(_ sender: UISlider) {
        ySliderValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    @IBAction func sengmentAction(_ sender: UISegmentedControl) {
        changeXYLSengment(selected:xylEnum(rawValue: sender.selectedSegmentIndex)!)
    }
    
    
    @IBAction func xyl_XValueSliderAction(_ sender: UISlider) {
        xyl_XValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    @IBAction func xyl_YValueSliderAction(_ sender: UISlider) {
        xyl_YValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func xyl_LightnessValueSliderAction(_ sender: UISlider) {
        xyl_LightnessValueLbl.text = NSString(format:"%i", Int(sender.value)) as String + "%"
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated:false, completion:nil)
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
    }
    
    
    
    func changeXYLSengment(selected:xylEnum){
        
        switch selected {
        case .XYL:
            xylView.isHidden = false
            xView.isHidden = true
            yView.isHidden = true
            break
        case .X:
            xylView.isHidden = true
            xView.isHidden = false
            yView.isHidden = true
            break
        case .Y:
            xylView.isHidden = true
            xView.isHidden = true
            yView.isHidden = false
            break
            
        }
    }
}
