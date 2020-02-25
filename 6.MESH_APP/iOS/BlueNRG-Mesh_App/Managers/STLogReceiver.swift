/**
 ******************************************************************************
 * @file    STLogReceiver.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    01-Oct-2018
 * @brief   Class to receive logs.
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

protocol logReceiverDelegate :class{
    func didReceivedNewLogObject(newLogObject:STLogModels)
}
final class STLogReceiver:NSObject{
    
    var logModelsArray:[STLogModels] = [STLogModels]()
    var delegate:logReceiverDelegate?
    static let shareInstence:STLogReceiver = {
        let instance = STLogReceiver()
        return instance
    }()
    
    private override init()
    {
        
    }
    
    /* open new view controller and setting LogReceiver Delegate to logController */
    func openLogScreen(viewController:UIViewController){
        let logViewController = UIStoryboard.loadViewController(storyBoardName:"Main", identifierVC:"LogViewController", type:LogViewController.self)
        logViewController.logModelsArray = self.logModelsArray
        self.delegate = logViewController
        
        viewController.navigationController?.pushViewController(logViewController, animated:true)
        //present(logViewController, animated:true, completion:nil)
    }
    
    /* Max Log messages at a time 250, if it already has 250 message, remove message from from index 0  */
    func removeLogMessageFromFirstIndex(){
        if logModelsArray.count == 250{
            logModelsArray.remove(at:0)
        }
    }
    
}
extension STLogReceiver:STMeshLoggerDelegate{
    func didReceivedLoggerMessage(_ message: String!, direction: LogerDirection, logTime timeInterval: TimeInterval, logModule: LogModuleIDs, isErrorLog isErrorMessage: Bool, data: Data!) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        let logMessageTime = dateFormatter.string(from:Date.init(timeIntervalSince1970:timeInterval))
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let logMessageDate = dateFormatter.string(from:Date.init(timeIntervalSince1970:timeInterval))
        
        let newLogModelObject = STLogModels(logDirection:direction, logTime:logMessageTime, logDate:logMessageDate , logModulesId:logModule, logMessage:message, dataPacketString: "", isErrorLog:isErrorMessage)
        logModelsArray.append(newLogModelObject)
        self.delegate?.didReceivedNewLogObject(newLogObject:newLogModelObject)
    }
}


struct STLogModels
{
    var logDirection:LogerDirection!
    var logTime:String!
    var logDate:String
    var logModulesId:LogModuleIDs!
    var logMessage:String!
    var dataPacketString:String?
    var isErrorLog:Bool = false
    
    init(logDirection:LogerDirection, logTime:String,logDate:String, logModulesId :LogModuleIDs, logMessage:String, dataPacketString:String, isErrorLog:Bool) {
        self.logDirection = logDirection
        self.logTime = logTime
        self.logDate = logDate
        self.logModulesId = logModulesId
        self.logMessage = logMessage
        self.dataPacketString = dataPacketString
        self.isErrorLog = isErrorLog
    }
}
