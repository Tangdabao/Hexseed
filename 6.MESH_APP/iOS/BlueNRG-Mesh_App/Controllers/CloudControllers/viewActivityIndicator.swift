/**
 ******************************************************************************
 * @file    viewActivityIndicator.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    06-July-2018
 * @brief   View Class for indicating "cloud operations" activity.
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

class viewActivityIndicator: UIView {
    
    class func addSTActivityIndicator(onViewController : UIViewController) -> (blurView: UIView , activityIndicator : UIView) {
        
        let viewBG = UIView()
        viewBG.backgroundColor = UIColor.hexStringToUIColor(hex: "E0E9ED")
        viewBG.alpha = 0.75
        
        onViewController.view.addSubview(viewBG)
        createUpperView(viewBG, withWidthMultiplier: 1.0, withHeightMultiplier: 1.0, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: onViewController.view)
        viewBG.layoutIfNeeded()
        
        
        let viewInnerBG = UIView()
        viewBG.addSubview(viewInnerBG)
        createUpperView(viewInnerBG, withWidthMultiplier: 0.5, withHeightMultiplier: 0.2, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.0, withRespectTo: viewBG)
        viewInnerBG.backgroundColor = UIColor.black
        viewInnerBG.layer.cornerRadius = 10.0
        viewInnerBG.alpha = 1.0
        viewInnerBG.layer.shadowOffset = CGSize(width: 1, height: 1.25)
        viewInnerBG.layer.shadowColor = UIColor.darkGray.cgColor
        viewInnerBG.layer.shadowRadius = 1.0
        viewInnerBG.layer.shadowOpacity = 0.2
        viewInnerBG.layoutIfNeeded()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        viewInnerBG.addSubview(activityIndicator)
        createUpperView(activityIndicator, withWidthMultiplier: 0.1, withHeightMultiplier: 0.1, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 0.8, withRespectTo: viewInnerBG)
        activityIndicator.startAnimating()
        
        
        let lblLoadingMessage = UILabel()
        viewInnerBG.addSubview(lblLoadingMessage)
        createUpperView(lblLoadingMessage, withWidthMultiplier: 1.0, withHeightMultiplier: 0.3, withXCoordinateMultilper: 1.0, withYCordinateMultiplier: 1.5, withRespectTo: viewInnerBG)
        lblLoadingMessage.text = "Fetching from server"
        lblLoadingMessage.textAlignment = .center
        lblLoadingMessage.textColor = UIColor.white
        lblLoadingMessage.adjustsFontSizeToFitWidth = true
        lblLoadingMessage.font = UIFont.boldSystemFont(ofSize: 15.0)
        animateMessages(lblLoadingMessage: lblLoadingMessage)
        
        viewBG.layoutIfNeeded()
        viewInnerBG.layoutIfNeeded()
        activityIndicator.layoutIfNeeded()
        lblLoadingMessage.layoutIfNeeded()
        
        
        return (viewBG , viewInnerBG)
    }
    
    class func createUpperView(_ viewToCreate: UIView?, withWidthMultiplier width: CGFloat, withHeightMultiplier height: CGFloat, withXCoordinateMultilper XCordinate: CGFloat, withYCordinateMultiplier YCordinate: CGFloat, withRespectTo Respectedview: UIView?) {
        viewToCreate?.translatesAutoresizingMaskIntoConstraints = false
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .width, relatedBy: .equal, toItem: Respectedview, attribute: .width, multiplier: width, constant: 0))
        
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .height, relatedBy: .equal, toItem: Respectedview, attribute: .height, multiplier: height, constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerX, relatedBy: .equal, toItem: Respectedview, attribute: .centerX, multiplier: CGFloat(XCordinate), constant: 0))
        Respectedview?.addConstraint(NSLayoutConstraint(item: viewToCreate!, attribute: .centerY, relatedBy: .equal, toItem: Respectedview, attribute: .centerY, multiplier: CGFloat(YCordinate), constant: 0))
        viewToCreate?.layoutIfNeeded()
    }
    
    class func animateMessages (lblLoadingMessage : UILabel) -> Void{
        UIView.animate(withDuration: 1.0, animations: {
            lblLoadingMessage.alpha = 0.0
        }) { (finished) in
            UIView.animate(withDuration: 1.0, animations: {
                lblLoadingMessage.alpha = 1.0
            }) { (finished) in
                animateMessages(lblLoadingMessage: lblLoadingMessage)
            }
        }
    }
    
    class func removeSTActivityIndicator(blurBG : UIView , innerBG : UIView ){
        blurBG.removeFromSuperview()
        innerBG.removeFromSuperview()
        
    }
}
