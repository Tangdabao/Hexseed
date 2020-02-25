/**
 ******************************************************************************
 * @file    CommonUtils.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.02.000
 * @date    22-Jan-2018
 * @brief   Common utilities 
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

class CommonUtils
{
    /* Common  method for show Alert with OK Button */
    class func showAlertWith(title: String, message: String, presentedOnViewController: UIViewController?) {
        var presentedOnViewController = presentedOnViewController
        
        if (presentedOnViewController == nil) {
            presentedOnViewController = appDelegate.window?.rootViewController
        }
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
        }
        alert.addAction(defaultAction)
        presentedOnViewController!.present(alert, animated: true) { () -> Void in
        }
    }
    

    class  func getCurrentProvisioner()->UInt16? {
        
        var currentNetworkMangager:NetworkConfigDataManager = NetworkConfigDataManager.sharedInstance
        if currentNetworkMangager.currentNetworkData.nodes.count > 0{
            if (!ProvisionerAdditionController.sharedInstance.checkIfProvisionerExist()){
                ProvisionerAdditionController.sharedInstance.createProvisionerDataFieldValues()
            }
        }
        currentNetworkMangager = NetworkConfigDataManager.sharedInstance
        for objProvisioner in (currentNetworkMangager.currentNetworkData.provisionerDataArray)! as! [STMeshProvisionerData] {
            let allocatedUnicastRange = objProvisioner.marrProvisionerAllocatedUnicastRange[0]
            let unicastLowRange = (allocatedUnicastRange as AnyObject).value(forKey: STMesh_Provisioner_AddressLowRange_Key) as! String
            //let unicastHighRange = (allocatedUnicastRange as AnyObject).value(forKey: STMesh_Provisioner_AddressHighRange_Key) as! String
            
            let allocatedUnicastLowAddressIntValue = UInt16(unicastLowRange, radix: 16)!
            let  strProvUUID = (UIDevice.current.identifierForVendor?.uuidString)!
            
            if ((objProvisioner.provisionerUUID as String).caseInsensitiveCompare(strProvUUID) == .orderedSame ){
                _ = objProvisioner
                return allocatedUnicastLowAddressIntValue
            }
        }
        
        return nil;
    }
    
    /* Common method for getting Top navigation  controller */
    class func getTopNavigationController() -> UINavigationController{
        let navController = appDelegate.window!.rootViewController as! UINavigationController
        return navController
    }
    
    class func getVendorModelsStatus(data:Data) -> UInt8{
        let statusValue = data[0] >> 5
        return  statusValue
    }
    
    class func getVendorModelsSubCommand
        (data:Data) -> UInt8{
        let statusValue = data[0] & 31 // 1F
        return  statusValue
    }
    
    /* Call for managing scroll view inset when keyboard open */
    class func showKeyBoard(notification: NSNotification, scrollView:UIScrollView) {
        
        var userInfo =  notification.userInfo!
        let size: AnyObject? = userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject?
        let keyboardSize = size!.cgRectValue.size
        var contentInsets:UIEdgeInsets;
        if (UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)){
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
        }else{
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.width, 0.0);
        }
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    /* Call for managing scroll view inset when keyboard hide */
    class func hideKeyBoard(scrollView:UIScrollView) {
        
        scrollView.contentInset = UIEdgeInsets.zero;
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero;
    }
    
    /* Called for show Alert with attributed message */
    class func showAlertTostMessage(title:String, message:String, controller:UIViewController,success:@escaping (_ completed:Bool)->Void){
        let attributedString = NSAttributedString(string: title, attributes: [
            (kCTFontAttributeName as NSAttributedStringKey) : UIFont.systemFont(ofSize: 20),
            NSAttributedStringKey.foregroundColor as NSAttributedStringKey : UIColor.red
            ])
        let alertController = UIAlertController(title: "" , message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.setValue(attributedString, forKey: "attributedTitle")
        controller.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            success(true)
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    
    class func showAlertToastWithColor(title:String, message:String, controller:UIViewController, color: UIColor = .black, fontSize : CGFloat = 15.0 ,success:@escaping (_ completed:Bool)->Void){
        
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20),
            NSAttributedStringKey.foregroundColor as NSAttributedStringKey : color
            ])
        let attributedMessageString = NSAttributedString(string: message, attributes: [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor as NSAttributedStringKey : color
            ])
        let alertController = UIAlertController(title: "" , message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.setValue(attributedString, forKey: "attributedTitle")
        alertController.setValue(attributedMessageString, forKey: "attributedMessage")
        controller.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            success(true)
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    
    class func showAlertToastWithColor(title:String, message:String, controller:UIViewController, titleColor: UIColor = .black, messsageColor: UIColor = .black, titleFontSize : CGFloat = 20.0 , messageFontSize : CGFloat = 18.0 ,success:@escaping (_ completed:Bool)->Void){
        
        let attributedString = NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: titleFontSize),
            NSAttributedStringKey.foregroundColor as NSAttributedStringKey : titleColor
            ])
        let attributedMessageString = NSAttributedString(string: message, attributes: [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: messageFontSize),
            NSAttributedStringKey.foregroundColor as NSAttributedStringKey : messsageColor
            ])
        let alertController = UIAlertController(title: "" , message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.setValue(attributedString, forKey: "attributedTitle")
        alertController.setValue(attributedMessageString, forKey: "attributedMessage")
        controller.present(alertController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            success(true)
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    
    class func showAlertWithOptionMessage(message:String, continueBtnTitle:String, cancelBtnTitle:String,controller:UIViewController, callBack:@escaping (Bool)->Void){
        let errorAlert = UIAlertController(title:AppTitle, message:message , preferredStyle: UIAlertControllerStyle.alert)
        let continueBtn = UIAlertAction(title:continueBtnTitle, style:.default) { (alertAction) in
            callBack(true)
        }
        let retryBtn = UIAlertAction(title:cancelBtnTitle, style:.cancel) { (alertAction) in
        }
        errorAlert.addAction(continueBtn)
        errorAlert.addAction(retryBtn)
        controller.present(errorAlert, animated: true, completion: nil)
    }
    
}

extension UIView{
    
    func addBlurEffect(style : UIBlurEffectStyle = .light)
    {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffect()
    {
        for subview in self.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
    func createGenricViewError() -> Void {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
        self.viewQuakeGenricAnimation()
    }
    
    func removeGenricViewError() -> Void {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.viewQuakeGenricAnimation()
    }
    
    func viewQuakeGenricAnimation() -> Void {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}


final class CommonTostAlrt
{
    var alertController:UIAlertController!
    
    // MARK: Shared Instance
    static let sharedInstance: CommonTostAlrt = {
        let instance = CommonTostAlrt()
        /* Setup code */
        return instance
    }()
    
    // Can't init singleton
    private init() { }
    
    
    func showAlertTostMessage(title:String, message:String, controller:UIViewController)
    {
        let attributedString = NSAttributedString(string: title, attributes: [
            (kCTFontAttributeName as NSAttributedStringKey) : UIFont.systemFont(ofSize: 20),
            NSAttributedStringKey.foregroundColor as NSAttributedStringKey : UIColor.hexStringToUIColor(hex:"#228B22")
            ])
        alertController = UIAlertController(title: "" , message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController?.setValue(attributedString, forKey: "attributedTitle")
        controller.present(alertController!, animated: true, completion: nil)
    }
    
    
    func hideAlertTostMessage()
    {
        if alertController != nil{
            alertController.dismiss(animated: false, completion: nil)
        }
    }
}


final class ViewConstraintHandling {
    
    class func createUpperView(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withYCordinateMultiplier YCordinate: CGFloat, withRespectTo Respectedview: UIView?) {
        Respectedview?.addSubview(viewToCreate!)
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0))
        
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: 0))
        viewToCreate?.layoutIfNeeded()
    }
}


final class commonViewErrorHandling
{
    class func createGenricErrorIn(viewcontroller:UIViewController , forClassType:AnyClass , statusLabel: UILabel? ,StatusLabelText:String?) -> Void {
        for anyObject in viewcontroller.view.subviews {
            if (anyObject.isKind(of: forClassType.self)){
                anyObject.layer.borderWidth = 1.0
                anyObject.layer.borderColor = UIColor.red.cgColor
                anyObject.viewQuakeGenricAnimation()
            }
        }
        if (StatusLabelText != nil){
            statusLabel?.alpha = 1.0
            statusLabel?.text = StatusLabelText
            statusLabel?.textColor = UIColor.red
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(int_fast64_t(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
            if (StatusLabelText != nil){
                self.removeGenricErrorIn(viewcontroller: viewcontroller, forClassType: forClassType, statusLabel: statusLabel, StatusLabelText: StatusLabelText!)
            }
            else{
                self.removeGenricErrorIn(viewcontroller: viewcontroller, forClassType: forClassType)
            }
        })
    }
    
    class func removeGenricErrorIn(viewcontroller:UIViewController , forClassType:AnyClass , statusLabel: UILabel? = nil ,StatusLabelText:String = "") -> Void {
        for allSubviews in viewcontroller.view.subviews {
            if (allSubviews.isKind(of: forClassType.self)){
                let textField = allSubviews as! UITextField
                textField.layer.borderWidth = 0.0
            }
            if (statusLabel != nil && StatusLabelText != ""){
                statusLabel?.alpha = 0.0
                statusLabel?.text = ""
            }
        }
    }
}

