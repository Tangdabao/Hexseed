/**
 ******************************************************************************
 * @file    UserHelperScreen.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    19-Jan-2018
 * @brief   View for user help screen
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


var indexValue = 0

let xScaleRatio = screenWidth / 768.0
let yScaleRatio = screenHeight / 1024.0


import UIKit

protocol UserHelperScreenDelegate {
    func helperScreenClosed() -> Void
}
class UserHelperScreen: UIView {
    
    var ElementUserManual = UIButton()
    var imgViewArrow = UIImageView()
    var lblMsg = UILabel()
    var strMsg = NSString()
    var btnClose = UIButton()
    var delegate : UserHelperScreenDelegate?
    var boolStopClicked : Bool = false
    
    /* Initialization Code */
    
    override init(frame: CGRect) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height))
        
        self.makeBlurEffectWithView()
        
        
        btnClose.frame =  CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        btnClose.backgroundColor = UIColor.clear
        btnClose.addTarget(self, action: #selector(self.removeSelf), for: .touchUpInside)
        self.addSubview(btnClose)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func removeSelf(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.boolStopClicked = true
            sender.removeFromSuperview()
            self.alpha = 0
        }, completion: {(_ b: Bool) -> Void in
            self.removeFromSuperview()
            self.delegate?.helperScreenClosed()
        })
    }
    
    //MARK: Blur Effect
    func makeBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
    func makeBlurEffectWithView() -> Void {
        let viewBlur = UIView.init(frame: self.frame)
        viewBlur.backgroundColor = UIColor.black
        viewBlur.alpha = 0.8
        self.addSubview(viewBlur)
    }
    
    //MARK: HELP FOR DEFINED ELEMENTS
    func showHelpForElements(marrElements : NSMutableArray)
    {
        /* Still there is element in the array to show help */
        if marrElements.count != 0 && !self.boolStopClicked
        {
            var mdictButtonForCurrentElement : NSMutableDictionary
            mdictButtonForCurrentElement = marrElements.object(at: indexValue) as! NSMutableDictionary
            
            
            strMsg = mdictButtonForCurrentElement[KConstantHelpMessageKey] as! NSString
            var rectOfButtonInSelf = CGRect(x: 0, y: 0, width: 0, height: 0)
            var imageOnButton = UIImage()
            
            /* if object for KConstantHelpElementKey is UIButton Type */
            if (mdictButtonForCurrentElement[KConstantHelpElementKey] is UIButton)
            {
                let btnTemp = mdictButtonForCurrentElement[KConstantHelpElementKey] as! UIButton
                rectOfButtonInSelf = convert(btnTemp.frame , from: btnTemp.superview)
                //imageOnButton = image(with: btnTemp!)
                
                let extraHeightFactor = ((delegate as! UIViewController).navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                if (rectOfButtonInSelf.origin.y < extraHeightFactor || rectOfButtonInSelf.origin.y < 2 * extraHeightFactor){
                    rectOfButtonInSelf = CGRect(x: rectOfButtonInSelf.origin.x, y: rectOfButtonInSelf.origin.y + extraHeightFactor, width: rectOfButtonInSelf.size.width, height: rectOfButtonInSelf.size.height)
                }
                
                if ((btnTemp.image(for: .normal)) != nil)
                {
                    imageOnButton = (btnTemp.image(for: .normal))!
                }
                else if (btnTemp.backgroundImage(for: .normal) != nil )
                {
                    imageOnButton = (btnTemp.backgroundImage(for: .normal))!
                    
                }
                else
                {
                    imageOnButton = imageWithView(inView: btnTemp)!
                }
            }
                
            else if (mdictButtonForCurrentElement[KConstantHelpElementKey] is UISwitch)
            {
                let switchInstance = mdictButtonForCurrentElement[KConstantHelpElementKey] as! UISwitch
                rectOfButtonInSelf = convert(switchInstance.frame , from: switchInstance.superview)
                imageOnButton = imageWithView(inView: switchInstance as UIView)!
                rectOfButtonInSelf = CGRect(x: rectOfButtonInSelf.origin.x, y: rectOfButtonInSelf.origin.y, width: rectOfButtonInSelf.size.width, height: rectOfButtonInSelf.size.height)
                
                let extraHeightFactor = ((delegate as! UIViewController).navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                if (rectOfButtonInSelf.origin.y < extraHeightFactor || rectOfButtonInSelf.origin.y < 2 * extraHeightFactor){
                    rectOfButtonInSelf = CGRect(x: rectOfButtonInSelf.origin.x, y: rectOfButtonInSelf.origin.y + extraHeightFactor, width: rectOfButtonInSelf.size.width, height: rectOfButtonInSelf.size.height)
                }
                
                // print("Switch Type Image")
                
            }
            else if (mdictButtonForCurrentElement[KConstantHelpElementKey] is UICollectionViewCell){
                let viewTemp = mdictButtonForCurrentElement[KConstantHelpElementKey] as? UICollectionViewCell
                rectOfButtonInSelf = convert(viewTemp?.frame ?? CGRect.zero, to: (delegate as! UIViewController).view)
                let extraHeightFactor = ((delegate as! UIViewController).navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                rectOfButtonInSelf = CGRect(x: (viewTemp?.frame.origin.x)!, y: extraHeightFactor + (viewTemp?.frame.origin.y)!, width: (viewTemp?.frame.size.width)!, height: (viewTemp?.frame.size.height)!)
                imageOnButton = imageWithView(inView: viewTemp!)!
            }
                
                
            else if (mdictButtonForCurrentElement[KConstantHelpElementKey] is UITabBarItem)// if object for KConstantHelpElementKey is UITabBar Type
            {
                let tabBarItemInstance = mdictButtonForCurrentElement[KConstantHelpElementKey] as! UITabBarItem
                let viewTemp = tabBarItemInstance.value(forKey: "view") as? UIView
                rectOfButtonInSelf = CGRect(x: (viewTemp?.frame.origin.x)!, y: ((delegate as! UIViewController).tabBarController?.tabBar.frame.origin.y)! + (viewTemp?.frame.origin.y)!, width: (viewTemp?.frame.size.width)!, height: (viewTemp?.frame.size.height)!)
                
                imageOnButton = image(with: viewTemp!)
            }
            else if (mdictButtonForCurrentElement[KConstantHelpElementKey] is UIBarButtonItem){
                let barButtonItem = mdictButtonForCurrentElement[KConstantHelpElementKey] as? UIBarButtonItem
                let viewTemp = barButtonItem?.value(forKey: "view") as? UIView
                
                rectOfButtonInSelf = convert(viewTemp?.frame ?? CGRect.zero, from: viewTemp?.superview)
                imageOnButton = imageWithView(inView: viewTemp!)!
            }
            else if (mdictButtonForCurrentElement[KConstantHelpElementKey] is UIView)  // if object for KConstantHelpElementKey is UIView Type
            {
                let viewTemp = mdictButtonForCurrentElement[KConstantHelpElementKey] as? UIView
                rectOfButtonInSelf = convert(viewTemp?.frame ?? CGRect.zero, from: viewTemp?.superview)
                
                let extraHeightFactor = ((delegate as! UIViewController).navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
                if (rectOfButtonInSelf.origin.y < extraHeightFactor || rectOfButtonInSelf.origin.y < 2 * extraHeightFactor){
                    rectOfButtonInSelf = CGRect(x: rectOfButtonInSelf.origin.x, y: rectOfButtonInSelf.origin.y + extraHeightFactor, width: rectOfButtonInSelf.size.width, height: rectOfButtonInSelf.size.height)
                }
                imageOnButton = imageWithView(inView: viewTemp!)!
            }
            rectOfButtonInSelf = CGRect(x: rectOfButtonInSelf.origin.x, y: rectOfButtonInSelf.origin.y , width: rectOfButtonInSelf.size.width, height: rectOfButtonInSelf.size.height)
            /* Put Button */
            ElementUserManual = UIButton(frame: rectOfButtonInSelf)
            ElementUserManual.setBackgroundImage(imageOnButton, for: .normal)
            ElementUserManual.alpha = 1
            ElementUserManual.isUserInteractionEnabled = false
            ElementUserManual.backgroundColor = UIColor.clear
            self.addSubview(ElementUserManual)
            
            /* Calling for Arrow position. */
            self.ChoosingBestArrowPosition(rectOfButtonInSelf: rectOfButtonInSelf, marrElementsHelp: marrElements)
            
            
        }
        else /* stop iterating now */
        {
            
        }
    }
    
    /* Converting View to UIImage */
    func imageWithView(inView: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(inView.bounds.size, inView.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            inView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    // MARK: - CONVERT UIVIEW TO UIIMAGE
    func image(with view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        //    UIGraphicsbeginima
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let snapshotImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage ?? UIImage()
    }
    
    //MARK : CHOOSE BEST ARROW FOR ELEMENT
    func ChoosingBestArrowPosition(rectOfButtonInSelf: CGRect ,marrElementsHelp: NSMutableArray) {
        
        var imgArrow = UIImage()
        var arrowPos = CGPoint.zero
        
        if rectOfButtonInSelf.origin.x < screenWidth / 2 && rectOfButtonInSelf.origin.y <= screenHeight / 2 {
            imgArrow = UIImage(named: "left_down")!
            arrowPos = CGPoint(x: rectOfButtonInSelf.origin.x + rectOfButtonInSelf.size.width, y: ElementUserManual.center.y - (imgArrow.size.height / 2) * yScaleRatio)
        }
        else if rectOfButtonInSelf.origin.x > screenWidth / 2 && rectOfButtonInSelf.origin.y <= screenHeight / 2 {
            imgArrow = UIImage(named: "right_down")!
            arrowPos = CGPoint(x: rectOfButtonInSelf.origin.x - imgArrow.size.width * xScaleRatio, y: ElementUserManual.center.y - (imgArrow.size.height / 2) * yScaleRatio)
        }
        else if rectOfButtonInSelf.origin.x < screenWidth / 2 && rectOfButtonInSelf.origin.y >= screenHeight / 2 {
            imgArrow = UIImage(named: "left_up")!
            arrowPos = CGPoint(x: rectOfButtonInSelf.origin.x + rectOfButtonInSelf.size.width, y: ElementUserManual.center.y - (imgArrow.size.height / 2) * yScaleRatio)
        }
        else if rectOfButtonInSelf.origin.x > screenWidth / 2 && rectOfButtonInSelf.origin.y >= screenHeight / 2 {
            imgArrow = UIImage(named: "right_up")!
            arrowPos = CGPoint(x: rectOfButtonInSelf.origin.x - imgArrow.size.width * xScaleRatio, y: ElementUserManual.center.y - (imgArrow.size.height / 2) * yScaleRatio)
        }
        
        
        if rectOfButtonInSelf.contains(CGPoint(x: screenWidth / 2, y: rectOfButtonInSelf.origin.y)) {
            if rectOfButtonInSelf.origin.y > screenHeight / 2 {
                imgArrow = UIImage(named: "down")!
                arrowPos = CGPoint(x: ElementUserManual.center.x - (imgArrow.size.width / 2) * xScaleRatio, y: rectOfButtonInSelf.origin.y - 10 * yScaleRatio - imgArrow.size.height * yScaleRatio)
            }
            else {
                imgArrow = UIImage(named: "up")!
                arrowPos = CGPoint(x: ElementUserManual.center.x - (imgArrow.size.width / 2) * xScaleRatio, y: rectOfButtonInSelf.origin.y + rectOfButtonInSelf.size.height + 10 * yScaleRatio)
            }
        }
        imgViewArrow = UIImageView(frame: CGRect(x: arrowPos.x, y: arrowPos.y
            , width: imgArrow.size.width * xScaleRatio, height: imgArrow.size.height * yScaleRatio))
        imgViewArrow.image = imgArrow
        imgViewArrow.alpha = 0
        self.addSubview(imgViewArrow)
        
        
        /* Calling for Message position. */
        self.ChoosingBestHelpMessagePosition(rectOfButtonInSelf: rectOfButtonInSelf, marrElementsHelp: marrElementsHelp)
    }
    
    func ChoosingBestHelpMessagePosition(rectOfButtonInSelf : CGRect ,marrElementsHelp: NSMutableArray)
    {
        lblMsg = UILabel()
        lblMsg.text = strMsg as String
        lblMsg.font = UIFont(name: "Carter one", size: 20 * xScaleRatio)
        lblMsg.numberOfLines = 0
        lblMsg.textColor = UIColor.white
        var labelFrame: CGRect = lblMsg.frame
        labelFrame.size.width = 350 * xScaleRatio
        lblMsg.frame = labelFrame
        lblMsg.textAlignment = .center
        lblMsg.sizeToFit()
        lblMsg.adjustsFontSizeToFitWidth = true
        
        var lblPos = CGPoint.zero
        
        if rectOfButtonInSelf.origin.x <= screenWidth / 2 && rectOfButtonInSelf.origin.y <= screenHeight / 2 { //  first Quadrant
            lblPos = CGPoint(x: imgViewArrow.frame.origin.x + imgViewArrow.frame.size.width - lblMsg.frame.size.width / 2, y: imgViewArrow.frame.origin.y + imgViewArrow.frame.size.height * yScaleRatio + 20 * yScaleRatio)
        }
        else if rectOfButtonInSelf.origin.x > screenWidth / 2 && rectOfButtonInSelf.origin.y <= screenHeight / 2{ // forth Quadrant
            lblPos = CGPoint(x: imgViewArrow.frame.origin.x - lblMsg.frame.size.width / 2, y: imgViewArrow.frame.origin.y + imgViewArrow.frame.size.height * yScaleRatio + 20 * yScaleRatio)
        }
        else if rectOfButtonInSelf.origin.x <= screenWidth / 2 && rectOfButtonInSelf.origin.y > screenHeight / 2 { // second quadrant
            lblPos = CGPoint(x: imgViewArrow.frame.origin.x + imgViewArrow.frame.size.width * xScaleRatio - lblMsg.frame.size.width / 2, y: imgViewArrow.frame.origin.y - lblMsg.frame.size.height - 20 * yScaleRatio)
        }
        else if rectOfButtonInSelf.origin.x > screenWidth / 2 && rectOfButtonInSelf.origin.y >= screenHeight / 2 { // third quadrant
            lblPos = CGPoint(x: imgViewArrow.frame.origin.x - lblMsg.frame.size.width / 2, y: imgViewArrow.frame.origin.y - lblMsg.frame.size.height - 20 * yScaleRatio)
        }
        
        if rectOfButtonInSelf.contains(CGPoint(x: screenWidth / 2, y: rectOfButtonInSelf.origin.y)) {
            if rectOfButtonInSelf.origin.y > screenHeight / 2 {
                lblPos = CGPoint(x: imgViewArrow.center.x - lblMsg.frame.size.width / 2, y: imgViewArrow.frame.origin.y - lblMsg.frame.size.height - 10 * yScaleRatio)
            }
            else {
                lblPos = CGPoint(x: imgViewArrow.center.x - lblMsg.frame.size.width / 2, y: imgViewArrow.frame.origin.y + imgViewArrow.frame.size.height + 10 * yScaleRatio)
            }
        }
        lblMsg.frame = CGRect(x: lblPos.x, y: lblPos.y + 15 * yScaleRatio, width: lblMsg.frame.size.width, height: lblMsg.frame.size.height)
        lblMsg.alpha = 0
        
        if (lblMsg.frame.size.width + lblMsg.frame.origin.x > self.frame.size.width){
            let outFromScreenFactor = abs(self.frame.size.width - (lblMsg.frame.size.width + lblMsg.frame.origin.x))
            lblMsg.frame = CGRect(x: lblMsg.frame.origin.x - outFromScreenFactor, y: lblMsg.frame.origin.y, width: lblMsg.frame.size.width , height: lblMsg.frame.size.height * 2)
        }
        else if (lblPos.x < 0){
            lblMsg.frame = CGRect(x: -lblMsg.frame.origin.x, y: lblMsg.frame.origin.y, width: lblMsg.frame.size.width , height: lblMsg.frame.size.height * 2)
            
        }
        self.addSubview(lblMsg)
        
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.ElementUserManual.alpha = 1
            self.imgViewArrow.alpha = 1
        }, completion: {(_ b: Bool) -> Void in
            UIView.animate(withDuration: 1.0, animations: {() -> Void in
                self.lblMsg.alpha = 1.0
            }, completion: {(_ b: Bool) -> Void in
                
                marrElementsHelp.removeObject(at: indexValue)
                if (marrElementsHelp.count == 0)
                {
                    // closing things need to be here
                    UIView.animate(withDuration: 0.5, animations: {() -> Void in
                        self.btnClose.removeFromSuperview()
                        self.alpha = 0
                    }, completion: {(_ b: Bool) -> Void in
                        self.removeFromSuperview()
                        
                        self.delegate?.helperScreenClosed()
                    })
                    
                }
                else // iterating it for next element
                {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(int_fast64_t(1.75 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                        UIView.animate(withDuration: 1.0, animations: {() -> Void in
                            self.ElementUserManual.alpha = 0
                            self.imgViewArrow.alpha = 0
                            self.lblMsg.alpha = 0
                        }, completion: {(_ b: Bool) -> Void in
                            self.ElementUserManual.removeFromSuperview()
                            self.imgViewArrow.removeFromSuperview()
                            self.lblMsg.removeFromSuperview()
                            
                            //PREPARE FOR NEXT BUTTON
                            self.showHelpForElements(marrElements: marrElementsHelp)
                        })
                    })
                    
                    
                }
            })
        })
        
    }
}
