/**
 ******************************************************************************
 * @file    MenuViewIntializer.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    31-May-2018
 * @brief   Setup code for the side menu
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
let applicationWindow = ((UIApplication.shared.delegate as! AppDelegate).window)!
let windowTagNumber = 10000
class MenuViewIntializer: NSObject {
    var xCordinateCnstraint = NSLayoutConstraint()
    static let sharedInstance: MenuViewIntializer = {
        let instance = MenuViewIntializer()
        
        return instance
    }()
    
    
    
    @objc func handleMenuView(barButtonItem : UIBarButtonItem)-> Void{
        applicationWindow.bringSubview(toFront: appDelegate.sideMenuBlurView)
        applicationWindow.bringSubview(toFront: appDelegate.viewMenuVC)
        appDelegate.sideMenuBlurView.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.size.height, width:applicationWindow.frame.size.width  , height: applicationWindow.frame.size.height)
        appDelegate.sideMenuBlurView.alpha = 1.0
        
        UIView.animate(withDuration: 0.25, animations: {
            appDelegate.viewMenuVC.frame = CGRect(x:0, y:0, width:applicationWindow.frame.size.width * 0.75, height: applicationWindow.frame.size.height)
        }) { (completion) in
            
        }
    }
    
    @objc func handleGesture(tapGesture : UITapGestureRecognizer) -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            appDelegate.viewMenuVC.frame = CGRect(x:-applicationWindow.frame.size.width, y: 0, width:applicationWindow.frame.size.width , height: applicationWindow.frame.size.height)
            appDelegate.sideMenuBlurView.alpha = 0.0
        }) { (completion) in
        }
    }
    
    func removeAllSubview(WithTagNumber: Int) -> Void {
        let subViewArray = appDelegate.window?.subviews
        for obj in subViewArray!
        {
            if (obj.tag == WithTagNumber){
                obj.removeFromSuperview()
                
            }
        }
    }
    func removeAllSubviewFromWindow() -> Void {
        
        for subWindow in UIApplication.shared.windows {
            
            let subViewArray = subWindow.subviews
            for obj in subViewArray
            {
                
                if (obj.frame.origin.x == -applicationWindow.frame.size.width && obj.frame.size.width == applicationWindow.frame.size.width * 0.75){
                    
                    let view = obj as UIView
                    view.removeFromSuperview()
                }
            }
        }
    }
}



