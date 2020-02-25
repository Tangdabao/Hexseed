/**
 ******************************************************************************
 * @file    CommonAlertView.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    21-June-2018
 * @brief   Class defines the common Alert View used in App
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

class commonAlertView: UIView {
    var btnRect : CGRect!
    var alertHeight : CGFloat!
    var viewAlert : commonAlertView!
    let viewBlur = UIView()
    @IBOutlet weak var viewUpperBlack: UIView!
    @IBOutlet weak var lblAlertTitle: UILabel!
    @IBOutlet weak var lblAlertMessage: UILabel!
    @IBOutlet weak var btnFirst: UIButton!
    @IBOutlet weak var btnSecond: UIButton!
    @IBOutlet weak var layoutBtnFirstWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutAlertMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var layoutBtnSecondTrailing: NSLayoutConstraint!
    @IBOutlet weak var layoutBtnSecondWidth: NSLayoutConstraint!
    @IBOutlet weak var layoutLowerBlackViewTop: NSLayoutConstraint!
    @IBOutlet weak var viewLowerBlack: UIView!
    @IBOutlet weak var layoutBtnFirstHeight: NSLayoutConstraint!
    @IBOutlet weak var layoutUpperBlackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var layoutBtnFirstTopSpace: NSLayoutConstraint!
    @IBOutlet weak var layoutBtnSecondBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var layoutBtnFirstLeadingSpace: NSLayoutConstraint!
    var btnFirstButtonAction : btnActionClosure!
    var btnSecondButtonAction :btnActionClosure!
    var viewControllerCurrentInstance : UIViewController!
    var alertWidthConstraint : NSLayoutConstraint!
    var alertHeightConstraint : NSLayoutConstraint!
    var isActionSheetTypeAlert : Bool = false
    var isRequireSecondButtonInAlertView : Bool = false
    
    
    init(){
        
        super.init(frame: CGRect(x: screenWidth * 0.2 , y:  screenHeight / 3 , width: screenWidth * 0.6, height: screenHeight / 2.5))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @objc func screenRotated() -> Void{
        if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown){
            alertWidthConstraint.constant = 0.0
            alertHeightConstraint.constant = 0.0
            if !isRequireSecondButtonInAlertView && !isActionSheetTypeAlert {
                viewAlert.layoutBtnFirstWidth.constant = viewControllerCurrentInstance.view.frame.size.width * 0.3
                
            }
            
            
            if (isActionSheetTypeAlert){
                viewAlert.layoutBtnSecondTrailing.constant = 10
                viewAlert.layoutBtnFirstLeadingSpace.constant = 10
            }
        }
        else if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight){
            
            if (alertWidthConstraint.constant != -self.viewAlert.frame.size.width * 0.2){
                
                alertWidthConstraint.constant = -self.viewAlert.frame.size.width * 0.2
                alertHeightConstraint.constant = self.viewAlert.frame.size.width * 0.2
                if !isRequireSecondButtonInAlertView && !isActionSheetTypeAlert{
                    viewAlert.layoutBtnFirstWidth.constant = viewControllerCurrentInstance.view.frame.size.width * 0.25
                    
                }
                if (isActionSheetTypeAlert){
                    viewAlert.layoutBtnSecondTrailing.constant = (viewAlert.frame.size.width - viewAlert.btnFirst.frame.size.width) / 2
                    viewAlert.layoutBtnFirstLeadingSpace.constant = (viewAlert.frame.size.width - viewAlert.btnFirst.frame.size.width) / 2
                }
            }
        }
    }
    func setUpGUIAlertView( title : String , message : String, viewController : UIViewController, firstButtonTitle: String, reqSecondButton : Bool, secondButtonText : String, firstButtonAction : @escaping btnActionClosure, secondButtonAction : @escaping btnActionClosure) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        viewControllerCurrentInstance = viewController
        /* Preserving Actions */
        btnFirstButtonAction = firstButtonAction
        btnSecondButtonAction = secondButtonAction
        self.layoutIfNeeded()
        
        viewController.view.addSubview(self)
        viewController.view.bringSubview(toFront: self)
        self.createViewWithConstraint(self, withWidthMultiplier: 0.6, withHeightMultiplier: 0.3, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: viewController.view)
        
        /* Intiating xib */
        
        viewAlert = (Bundle.main.loadNibNamed("GUIAlertView", owner: self, options: nil)?.last as! commonAlertView)
        
        
        self.addSubview(viewAlert)
        self.createUpperView(viewAlert, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: self)
        
        /* Title handling */
        if (title.caseInsensitiveCompare("") == .orderedSame){
            viewAlert.lblAlertTitle.text = ""
        }
        else{
            viewAlert.lblAlertTitle.text = title as String
        }
        /* Message handling */
        if (message.caseInsensitiveCompare("") == .orderedSame){
            viewAlert.lblAlertMessage.text = ""
            viewAlert.layoutAlertMessageHeight.constant = -viewAlert.lblAlertMessage.frame.size.height
        }
        else{
            viewAlert.lblAlertMessage.text = message as String
        }
        
        if reqSecondButton {
            isRequireSecondButtonInAlertView = true
            viewAlert.btnSecond.setTitle(secondButtonText, for: .normal)
            viewAlert.btnFirst.setTitle(firstButtonTitle, for: .normal)
            viewAlert.btnSecond.addTarget(self, action: #selector(self.btnSecondClicked), for: .touchUpInside)
            viewAlert.btnFirst.addTarget(self, action: #selector(self.btnFirstClicked), for: .touchUpInside)
            viewAlert.btnFirst.titleLabel?.textAlignment = .center
            viewAlert.btnSecond.titleLabel?.textAlignment = .center
            
        }
        else{
            viewAlert.btnFirst.layoutIfNeeded()
            viewAlert.layoutBtnFirstWidth.constant = self.viewAlert.frame.size.width * 0.5
            viewAlert.btnFirst.setTitle(firstButtonTitle, for: .normal)
            viewAlert.btnFirst.addTarget(self, action: #selector(self.btnFirstClicked), for: .touchUpInside)
            viewAlert.btnSecond.isHidden =  true
            viewAlert.btnFirst.contentHorizontalAlignment = .center
        }
    }
    func setUpGUIActionSheetView( title : NSString , message : String,viewController : UIViewController, firstButtonTitle: String , secondButtonText : String , firstButtonAction : @escaping btnActionClosure , secondButtonAction : @escaping btnActionClosure){
        viewControllerCurrentInstance = viewController
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        isActionSheetTypeAlert = true
        
        /* Preserving Actions */
        btnFirstButtonAction = firstButtonAction
        btnSecondButtonAction = secondButtonAction
        
        viewController.view.addSubview(viewBlur)
        self.createUpperView(viewBlur, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: viewController.view)
        viewBlur.backgroundColor = UIColor.lightGray
        viewBlur.alpha = 0.5
        
        
        self.layoutIfNeeded()
        
        viewController.view.addSubview(self)
        self.createViewWithConstraint(self, withWidthMultiplier: 0.6, withHeightMultiplier: 0.3, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: viewController.view)
        viewController.view.bringSubview(toFront: self)
        
        
        
        self.layoutIfNeeded()
        // Intiating xib
        viewAlert = (Bundle.main.loadNibNamed("GUIAlertView", owner: self, options: nil)?.last as! commonAlertView)
        self.addSubview(viewAlert)
        self.createUpperView(viewAlert, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: self)
        
        
        if (title.caseInsensitiveCompare("") == .orderedSame){
            viewAlert.lblAlertTitle.text = ""
        }
        else{
            viewAlert.lblAlertTitle.text = title as String
        }
        
        if (message.caseInsensitiveCompare("") == .orderedSame){
            viewAlert.lblAlertMessage.text = ""
            viewAlert.layoutAlertMessageHeight.constant = -viewAlert.lblAlertMessage.frame.size.height
            viewAlert.layoutBtnFirstTopSpace.constant = self.frame.size.height * 0.06
            viewAlert.layoutBtnSecondBottomSpace.constant = self.frame.size.height * 0.06
            viewAlert.layoutBtnFirstWidth.constant = viewAlert.btnFirst.frame.size.width - 20
            viewAlert.layoutLowerBlackViewTop.constant = viewAlert.btnFirst.frame.size.height * 2 - self.frame.size.height * 0.06
            viewAlert.layoutBtnSecondTrailing.constant = 10
            viewAlert.layoutBtnFirstLeadingSpace.constant = 10
        }
        else{
            viewAlert.lblAlertMessage.text = message as String
            viewAlert.layoutAlertMessageHeight.constant = -viewAlert.btnFirst.frame.size.height * 1.0
            viewAlert.layoutBtnFirstWidth.constant = viewAlert.btnFirst.frame.size.width - 20
            viewAlert.layoutBtnFirstHeight.constant = -viewAlert.btnFirst.frame.size.height * 0.3
            viewAlert.viewUpperBlack.layoutIfNeeded()
            viewAlert.layoutUpperBlackViewHeight.constant = -10
            viewAlert.btnFirst.layoutIfNeeded()
            viewAlert.layoutLowerBlackViewTop.constant = viewAlert.btnFirst.frame.size.height + 5
            viewAlert.layoutBtnFirstLeadingSpace.constant = 10
            viewAlert.layoutBtnSecondTrailing.constant = 11
            viewAlert.layoutBtnFirstTopSpace.constant = 0
        }
        
        viewAlert.btnFirst.layer.cornerRadius = 5.0
        viewAlert.btnSecond.layer.cornerRadius = 5.0
        viewAlert.btnSecond.setTitle(secondButtonText, for: .normal)
        viewAlert.btnFirst.setTitle(firstButtonTitle, for: .normal)
        viewAlert.btnSecond.addTarget(self, action: #selector(self.btnSecondClicked), for: .touchUpInside)
        viewAlert.btnFirst.addTarget(self, action: #selector(self.btnFirstClicked), for: .touchUpInside)
        viewAlert.btnFirst.contentHorizontalAlignment = .center
        viewAlert.btnSecond.contentHorizontalAlignment = .center
        
    }
    @objc func btnFirstClicked() -> Void {
        btnFirstButtonAction()
        self.removeAlertView()
        
    }
    @objc func btnSecondClicked() ->Void {
        btnSecondButtonAction()
        self.removeAlertView()
    }
    func removeAlertView() -> Void {
        UIView.animate(withDuration: 0.2, animations: {
            self.viewAlert.alpha = 0.0
            self.viewBlur.alpha = 0.0
            
            
        }, completion: { (finished) in
            self.viewAlert.removeFromSuperview()
            self.removeBlurEffect()
            self.viewBlur.removeFromSuperview()
            self.removeFromSuperview()
            self.removeFromSuperview()
            
            
        })
    }
    
    
    func createUpperView(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withYCordinateMultiplier YCordinate: CGFloat, withRespectTo Respectedview: UIView?) {
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: 0))
        viewToCreate?.layoutIfNeeded()
    }
    
    func createViewWithConstraint(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withYCordinateMultiplier YCordinate: CGFloat, withRespectTo Respectedview: UIView?) {
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        alertHeightConstraint = NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0)
        alertWidthConstraint = NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0)
        Respectedview?.addConstraint(alertWidthConstraint)
        Respectedview?.addConstraint(alertHeightConstraint)
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: 0))
        viewToCreate?.layoutIfNeeded()
    }
}
