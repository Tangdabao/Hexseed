/**
 ******************************************************************************
 * @file    CloudOperationConstantFile.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    23-May-2018
 * @brief   Cloud Synchronization
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

//MARK: Constants User Default Keys
let KConstant_UserID_key = "userid"
let KConstant_Temp_UserID_Key = "tempUserID"
let KConstant_UserName_key = "user"

//MARK:  User created the network in the cloud
let KConstant_UserCreatedNetworkOnCloud_Key = "User has Created the network on cloud"
let KConstant_NetworkRegisteredByUsername = "Network Registered by username"
let KConstant_UserUploadedNetworkOnCloud_Key = "User has uploaded the network on cloud"

// MARK : Constants URL
let KURL_USER_LOGIN = "https://mycloud.com/API/v1/Login"
let KURL_USER_CREATE = "https://mycloud.com/API/v1/Create"
let KURL_CREATE_NETWORK = "https://mycloud.com/API/v1/createNetwork"
let KURL_INVITE_IN_NETWORK = "https://mycloud.com/API/v1/invite"
let KURL_UPLOAD_DB_TO_NETWORK = "https://mycloud.com/API/v1/uploadDb"
let KURL_JOIN_NETWORK = "https://mycloud.com/API/v1/joinNetwork"
let KURL_DOWNLOAD_NETWORK = "https://mycloud.com/API/v1/downloadDb"
let KURL_PROVISIONER_REGISTRATION_NETWORK = "https://mycloud.com/API/v1/provisionerRegistration"
let KURL_USER_LOGOUT = "https://mycloud.com/API/v1/logout"
let KURL_GET_ALL_NETWORKS = "https://mycloud.com/API/v1/getNetworks"
let KURL_REGISTER_SECURITY_QUESTIONS = "https://mycloud.com/API/v1/registerSecurityQuestion"
let KURL_RETRIEVE_SECURITY_QUESTIONS = "https://mycloud.com/API/v1/retrieveSecurityQuestions"
let KURL_SUBMIT_SECURITY_QUESTIONS = "https://mycloud.com/API/v1/submitSecurityAnswer"
let KURL_CHANGE_PASSWORD = "https://mycloud.com/API/v1/changePassword"


//MARK: Constants Message
let KConstant_Message_Invalid_Details = "Invalid Entries"
let KConstant_Message_UserName_Length_Check = "Username must be greater than 3 letters"
let KConstant_Message_Password_Length_Check = "Password must be greater than 3 letters"
let KConstant_Message_InvalidEmail = "Invalid email Id"
let KConstant_Message_ServerError = "Server not responding"
let KConstant_Message_Passwod_Reconfirm_Mismatch = "Password Mistmatch."
let KConstant_Message_Same_Security_Question = "Kindly choose different security questions."
let KConstant_Message_Same_Security_Question_Length_Check = "Answer must be greater than 3 letters"
let KConstant_Message_Same_Security_Answer_Length_Check = "Security question must be greater than 4 letters"

let KConstant_ErrorCode_Key = "statusCode"
let KConstant_ErrorMessage_Key = "errorMessage"
let KConstant_ResponseMessage_Key = "responseMessage"
let KConstant_JoinedMeshNetworkUUID = "Joined Mesh Network UUID"
let KConstant_RetrievedFirstQuestionKey = "firstQuestion"
let KConstant_RetrievedSecondQuestionKey = "secondQuestion"
let KConstant_RetrievedThirdQuestionKey = "thirdQuestion"

let KConstant_FirstPasswordKey = "firstPassword"
let KConstant_SecondPasswordKey = "secondPassword"
let KConstant_ThirdPasswordKey = "thirdPassword"

let KConstant_OldPasswordKey = "oldPassword"
let KConstant_NewPasswordKey = "newPassword"
//MARK: Constants Warnings
let KConstant_Warning_Sign_In_First = "Sign in first."
let KConstant_Warning_Server_Error = "Server not responding"


// MARK: Anynonumus
let KConstant_LoginSuccessfullNotification_key = "Notification After Successfull Login"

//MARK : Color Code
let KConstant_SuccessfulColorCode_Key = UIColor.hexStringToUIColor(hex: "1A6106")


// MARK: Notification Names
let kNotificationNameForSignUp = "Sign Up Notification"
let kNotificationNameForLoginUser = "Login User Notification"
let kNotificationNameForCreateNetwork = "Create Network Notification"
let kNotificationNameForInvite = "Invite In Network Notification"
let kNotificationNameForJoinNetwork = "Join Network Notification"
let kNotificationNameForRegistration = "Provisioner Registration Notification"
let kNotificationNameForDownloadNetwork = "Dowload Network Notification"
let kNotificationNameForUpload = "Upload Network Notification"
let kNotificationNameForSignOut = "Sign Out Notification"
let kNotificationNameForGetAllNetworks = "Get all networks Notification"
let kNotificationNameForRegisterSecurityQuestions = "Security Questions Notification"
let kNotificationNameForRetrieveSecurityQuestions = "Retrieved Security Questions Notification"
let kNotificationNameForSubmitSecurityQuestions = "Submit Security Questions Notification"
let kNotificationNameForChangePassword = "Change Password Notification"


