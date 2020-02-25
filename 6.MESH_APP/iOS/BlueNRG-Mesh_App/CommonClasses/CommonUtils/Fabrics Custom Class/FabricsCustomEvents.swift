/**
 ******************************************************************************
 * @file    FabricsCustomEvents.swift.c
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    01-Feb-2018
 * @brief   File to manage fabric custom events 
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
import Crashlytics
let KConstantEventThresholdTime :Double = 8
let KConstantEventThresholdTimeForConfig :Double = 18

class STCustomEventLogClass: NSObject {
    
    static let sharedInstance =  STCustomEventLogClass()
    private override init() {
        super.init()
    }
    
    var timeStarted : Double = 0
    var provisioningStarted : Bool = false
    func STEvent_ProvisioningStartEvent() -> Void {
        timeStarted = CFAbsoluteTimeGetCurrent()
        
        // checking if the provisioning started bool is true then there was a provisioning failed scenario in past, which we are posting it now.
        self.STEvent_ProvisioningFailed()
        provisioningStarted = true
    }
    
    func STEvent_ProvisioningEndEvent() -> Void {
        var timeInterval : Double = 0
        provisioningStarted = false
        timeInterval = CFAbsoluteTimeGetCurrent() - timeStarted
        Answers.logCustomEvent(withName: "Provisioning Time Taken",
                               customAttributes: [
                                "Time Taken in sec": timeInterval])

    }
    
    
    func STEvent_ConfigurationTimeStartEvent() -> Void {
        timeStarted = 0
        timeStarted = CFAbsoluteTimeGetCurrent()
        
    }
    
    func STEvent_ConfigurationTimeTakenEvent() -> Void {
        var timeInterval : Double = 0
        timeInterval = CFAbsoluteTimeGetCurrent() - timeStarted
        
        Answers.logCustomEvent(withName: "Configuration Time Taken",
                               customAttributes: [
                                "Time Taken in Sec": timeInterval])

        timeStarted = 0
        
    }
    
    func STEvent_CompositionPageCompanyIdentifier(companyIdentifier : UInt16) -> Void {
        
        let companyNameFromIdentifier = CompanyIdentifiers.init().humanReadableNameFromIdentifier(companyIdentifier)
        Answers.logCustomEvent(withName: "Company Identifier ", customAttributes: ["Company name is": companyNameFromIdentifier ?? "Unknown"])
    }
    
    func STEvent_ProvisioningFailed() -> Void {
        if provisioningStarted {
            Answers.logCustomEvent(withName: "Provisioning Failed",
                                   customAttributes: [
                                    "Failed after secs": CFAbsoluteTimeGetCurrent() - timeStarted , "Failure reason" :  ""])
        }
    }
}


