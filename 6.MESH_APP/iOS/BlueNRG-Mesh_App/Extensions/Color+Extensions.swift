/**
 ******************************************************************************
 * @file    Color+Extensions.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    30-Sep-2018
 * @brief   Define standard colors for the UI.
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

import Foundation
import UIKit

extension UIColor
{
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
    class var ST_DarkBlue :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_DarkBlue")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#002052")
            }
        }
    }
    
    class var ST_DarkGray :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_DarkGray")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#4F5251")
            }
        }
    }
    
    class var ST_Gray :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_Gray")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#90989E")
                
            }
        }
    }
    
    class var ST_Green :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_Green")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#003D14")
            }
        }
    }
    
    class var ST_LightBlue :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_LightBlue")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#39A9DC")
            }
        }
    }
    
    class var ST_LightGray :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_LightGray")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#B9C4CA")
            }
        }
    }
    
    class var ST_LimeGreen :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_LimeGreen")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#BBCC00")
            }
        }
    }
    
    class var ST_Magenta :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_DarkBlue")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#D4007A")
            }
        }
    }
    
    class var ST_Maroon :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_Maroon")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#5C0915")
            }
        }
    }
    
    class var ST_Yellow :UIColor{
        get{
            if #available(iOS 11.0, *) {
                return  UIColor(named:"ST_Yellow")!
            } else {
                return UIColor.hexStringToUIColor(hex:"#FFD300")
            }
        }
    }
}
