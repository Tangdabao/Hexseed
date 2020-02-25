/**
 ******************************************************************************
 * @file    SyncOperationController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    06-June-2018
 * @brief   Class to manage cloud sync operations.
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

class CloudOperationHandler: NSObject {
    
    private var currentControllerInstance : UIViewController!
    let currentNetworkDataMgr = NetworkConfigDataManager.sharedInstance
    
    static let sharedInstance : CloudOperationHandler = {
        let instance = CloudOperationHandler()
        
        NotificationCenter.default.removeObserver(instance, name: Notification.Name(kNotificationNameForCreateNetwork), object: nil)
        NotificationCenter.default.addObserver(instance, selector: #selector(responseFromCloudForCreateNetwork(notificationReponseObject:)), name: Notification.Name(kNotificationNameForCreateNetwork), object: nil)
        
        NotificationCenter.default.removeObserver(instance, name: Notification.Name(kNotificationNameForUpload), object: nil)
        NotificationCenter.default.addObserver(instance, selector: #selector(responseFromCloudForUploadJSON(notificationReponseObject:)), name: Notification.Name(kNotificationNameForUpload), object: nil)
        
        NotificationCenter.default.removeObserver(instance, name: Notification.Name(kNotificationNameForDownloadNetwork), object: nil)
        NotificationCenter.default.addObserver(instance, selector: #selector(responseFromCloudforDonwloadNetwork(notificationReponseObject:)), name: Notification.Name(kNotificationNameForDownloadNetwork), object: nil)
        return instance
    }()
    
    //MARK: Create Network
    func createNetwork(viewController : UIViewController) -> Void {
        currentControllerInstance = viewController
        var parameters : Parameters
        if userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You are not logged in", controller: viewController) { (completion) in
            }
            return
        }
        else{
            parameters  = [
                "userKey":userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as! String,
                "MeshUUID":currentNetworkDataMgr.currentNetworkData.meshUUID as String
            ]
        }
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_CREATE_NETWORK, parameters: parameters, viewController: viewController, notificationName: kNotificationNameForCreateNetwork)
    }
    
    @objc func responseFromCloudForCreateNetwork(notificationReponseObject : Notification) -> Void {
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        UserDefaults.standard.set(true, forKey: KConstant_UserCreatedNetworkOnCloud_Key)
        UserDefaults.standard.set(UserDefaults.standard.value(forKey: KConstant_UserName_key) as! String, forKey: KConstant_NetworkRegisteredByUsername)
        
        // Now uploading the network to cloud
        self.uploadExistingNetwork(viewController: currentControllerInstance)
    }
    
    //MARK: Upload Existing Network
    func uploadExistingNetwork(viewController : UIViewController) ->Void {
        currentControllerInstance = viewController
        let provisionerUUID = UIDevice.current.identifierForVendor?.uuidString
        
        //let JSON = ""
        
        let parameters : Parameters
        if (userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as? String ) != nil{
            parameters  = [
                "userKey":userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as! String,
                "MeshUUID":currentNetworkDataMgr.currentNetworkData.meshUUID as String ,
                "JsonString":self.getJsonString(),
                "ProvUUID":provisionerUUID!.lowercased()
            ]
        }
        else {
            return
        }
        
        /* Making post request */
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_UPLOAD_DB_TO_NETWORK, parameters: parameters, viewController: viewController, notificationName: kNotificationNameForUpload)
    }
    
    @objc private func responseFromCloudForUploadJSON(notificationReponseObject : Notification) -> Void {
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        self.donwloadNetwork(viewController: currentControllerInstance)
    }
    
    /* Mark Download Request */
    func donwloadNetwork(viewController : UIViewController) -> Void {
        
        currentControllerInstance = viewController
        /* Making post request */
        let meshUUID :String
        if (UserDefaults.standard.value(forKey: KConstant_JoinedMeshNetworkUUID) != nil){
            meshUUID = UserDefaults.standard.value(forKey: KConstant_JoinedMeshNetworkUUID) as! String
        }
        else
        {
            meshUUID = currentNetworkDataMgr.currentNetworkData.meshUUID as String
        }
        let parameters  = [
            "userKey":userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as! String,
            "MeshUUID":meshUUID
        ]
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_DOWNLOAD_NETWORK, parameters: parameters, viewController: currentControllerInstance, notificationName: kNotificationNameForDownloadNetwork)
    }
    
    @objc private func responseFromCloudforDonwloadNetwork(notificationReponseObject : Notification) -> Void {
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        let currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
        let settingJSON = JSON.init(parseJSON: responseMessage)
        currentNetworkDataManager.populateNetworkConfigModelFromJson(settingJSON:settingJSON, currentNetworkDataModel: currentNetworkDataManager.currentNetworkData)
        currentNetworkDataManager.saveNetworkConfigToStorage()
        UserDefaults.standard.set(false, forKey: KConstantIsProvisionerAdded)
        UserDefaults.standard.set(true, forKey: KConstant_UserCreatedNetworkOnCloud_Key)
        CommonUtils.showAlertToastWithColor(title: AppTitle, message: "Successfully Configued", controller: currentControllerInstance, color: KConstant_SuccessfulColorCode_Key, fontSize: 12, success: { (completion) in
            self.currentControllerInstance.navigationController?.popViewController(animated: true)
            
        })
    }
    
    // MARK: Join Network
    func joinNetwork(viewControllerInstance : UIViewController , joinKey : String) -> Void {
        
        currentControllerInstance = viewControllerInstance
        // checking if user text field is empty
        if(!self.validate(textField: joinKey) ) {
            return
        }
        var parameters : Parameters
        if userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You are not logged in", controller: currentControllerInstance) { (completion) in
            }
            return
        }
        else{
            parameters  = [
                "iuserKey":userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as! String,
                "inCode":joinKey
            ]
        }
        // Making post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForJoinNetwork), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForJoinKey(notificationReponseObject:)), name: Notification.Name(kNotificationNameForJoinNetwork), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_JOIN_NETWORK, parameters: parameters, viewController: currentControllerInstance, notificationName: kNotificationNameForJoinNetwork)
    }
    
    @objc private func responseFromCloudForJoinKey(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForJoinNetwork), object: nil)
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        
        UserDefaults.standard.set(responseMessage, forKey: KConstant_JoinedMeshNetworkUUID)
        self.registerProvisioner(viewControllerInstance: currentControllerInstance)
    }
    
    // MARK: Register Provisioner
    func registerProvisioner(viewControllerInstance : UIViewController) {
        currentControllerInstance = viewControllerInstance
        /* Creating the parameter for the Url */
        var parameters : Parameters
        
        if userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil{
            CommonUtils.showAlertTostMessage(title: "Error", message: "You are not logged in", controller: currentControllerInstance) { (completion) in
            }
            return // no opeartion
        }
        else{
            parameters  = [
                "userKey":userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as! String,
                "provName": UIDevice.current.name,
                "MeshUUID":UserDefaults.standard.value(forKey: KConstant_JoinedMeshNetworkUUID) as! String ,
                "ProvUUID":UIDevice.current.identifierForVendor!.uuidString.lowercased()
            ]
        }
        
        /* Making post request */
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForRegistration), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForeRegisterProvisioner(notificationReponseObject:)), name: Notification.Name(kNotificationNameForRegistration), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_PROVISIONER_REGISTRATION_NETWORK, parameters: parameters, viewController: currentControllerInstance, notificationName: kNotificationNameForRegistration)
    }
    
    @objc private func responseFromCloudForeRegisterProvisioner(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForRegistration), object: nil)
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        print("Response message from:", responseMessage)
        self.donwloadNetwork(viewController: currentControllerInstance)
    }
    
    //MARK: validate text field
    func validate(textField : String) -> Bool {
        if ((textField.count) < 4){
            commonViewErrorHandling.createGenricErrorIn(viewcontroller: currentControllerInstance, forClassType: UITextField.self , statusLabel:nil , StatusLabelText:"")
            return false
        }
        return true
    }
    
    //MARK: Add On feature
    func jsonToNSData(json: AnyObject) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    func jsonToString(json: AnyObject) -> String{
        do {
            /* Convert json to the data */
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            /* Convert data to the string */
            let convertedString = String(data: data1, encoding: String.Encoding.utf8)
            
            print(convertedString ?? "defaultvalue")
            return convertedString!
        } catch let myJSONError {
            print(myJSONError)
        }
        return""
    }
    
    func getJsonString() -> String {
        let json  = currentNetworkDataMgr.generateJsonFromNetworkConfigModel()
        let jsonString = self.jsonToString(json: json.rawValue as AnyObject)
        print(jsonString)
        return jsonString
    }
}

