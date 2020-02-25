/**
 ******************************************************************************
 * @file    Extensions.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    19-Jan-2018
 * @brief   UI Extensions 
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


@IBDesignable extension UIView{
    
    @IBInspectable var borderColor:UIColor{
        set{
            self.layer.borderColor = (newValue as UIColor).cgColor
        }
        get{
            let color  = self.layer.borderColor
            return UIColor(cgColor: color!)
        }
    }
    
    @IBInspectable var borderWidth:CGFloat{
        set{
            self.layer.borderWidth = newValue
        }
        get{
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat{
        set{
            self.layer.cornerRadius = newValue
        }
        get{
            return self.layer.cornerRadius
        }
    }
    @IBInspectable var shadowColor:UIColor{
        set{
            self.layer.shadowColor = (newValue as UIColor).cgColor
        }
        get{
            let  color = self.layer.shadowColor
            return UIColor(cgColor: color!)
        }
    }
    @IBInspectable var shadownOffset: CGSize{
        set {
            self.layer.shadowOffset = newValue
        }
        get{
            return self.layer.shadowOffset
        }
    }
    @IBInspectable var shadowRadius: CGFloat{
        set {
            self.layer.shadowRadius = newValue
        }
        get{
            return self.layer.shadowRadius
        }
    }
    @IBInspectable var shadowOpacity: Float{
        set {
            self.layer.shadowOpacity = newValue
        }
        get{
            return self.layer.shadowOpacity
        }
    }
    
    func setShadowOnView(color: CGColor) {
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 20, height: 20)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 2.0
        self.clipsToBounds = true
    }
    
    
    
}


extension UIStoryboard{
    
    class func loadViewController<T:UIViewController>(storyBoardName:String,identifierVC:String,type:T.Type) -> T
    {
        let storyboard = UIStoryboard(name: storyBoardName, bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: identifierVC) as! T
        return controller
    }
}



extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}



extension NSData {
    var uint8: UInt8 {
        get {
            var number: UInt8 = 0
            self.getBytes(&number, length: UInt8.bitWidth)
            return number
        }
    }
    var uint16: UInt16 {
        get {
            var number: UInt16 = 0
            self.getBytes(&number, length: UInt16.bitWidth)
            return number
        }
    }
    var uint32: UInt32 {
        get {
            var number: UInt32 = 0
            self.getBytes(&number, length:UInt32.bitWidth)
            return number
        }
    }
    
    var stringUTF8: String? {
        get {
            return NSString(data: self as Data, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }
    
    var uuid: NSUUID? {
        get {
            var bytes = [UInt8](repeating: 0, count: self.length)
            self.getBytes(&bytes, length: self.length * UInt8.bitWidth)
            return NSUUID(uuidBytes: bytes)
        }
    }
    
    var stringASCII: String? {
        get {
            return NSString(data: self as Data, encoding: String.Encoding.ascii.rawValue) as String?
        }
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
}


