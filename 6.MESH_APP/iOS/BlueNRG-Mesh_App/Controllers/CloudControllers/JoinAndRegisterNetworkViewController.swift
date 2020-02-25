/**
 ******************************************************************************
 * @file    JoinAndRegisterNetworkViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    12-June-2018
 * @brief   ViewController for the "Join & Register" View.
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

let KConstantNetworkNameKey = "Network name key"
let KConstantNetworkMeshUUID = "Network Mesh UUID"

class JoinAndRegisterNetworkViewController: UIViewController {
    
    @IBOutlet weak var btnJoinNetwork: UIButton!
    @IBOutlet weak var txtFieldJoinNetwork: UITextField!
    @IBOutlet weak var btnRegisterNewNetwok: UIButton!
    @IBOutlet weak var tblViewJoinNetwork: UITableView!
    @IBOutlet weak var layoutConstraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewJoinExistingNetworks: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var scrollContentViewHeightConstraint: NSLayoutConstraint!
    
    let currentNetworkDataMgr = NetworkConfigDataManager.sharedInstance
    var arrayNetworkRetrieved = Array<Dictionary<String , Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblViewJoinNetwork.estimatedRowHeight = 60
        tblViewJoinNetwork.tableFooterView = UIView()
        tblViewJoinNetwork.separatorStyle = .singleLine
        self.layoutConstraintTableViewHeight.constant = -tblViewJoinNetwork.frame.size.height + 3 * 50
        self.viewJoinExistingNetworks.layoutIfNeeded()
        self.view.layoutIfNeeded()
        
        if ((userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as? String) == nil){
            LoginSignUpManager.sharedInstance.createLoginPage(callingClassDelegate: self)
        }
        if let _ = (UserDefaults.standard.value(forKey: KConstant_UserID_key)) as? String{
            self.btnLogin.setTitle("Logout", for: .normal)
        }
        else{
            self.btnLogin.setTitle("Login", for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (UserDefaults.standard.value(forKey: KConstant_UserID_key) != nil){
            self.checkingExistingNetworks()
        }
        scrollContentViewHeightConstraint.constant = self.view.frame.size.height
        
    }
    
    //MARK: Checking all existing networks
    func checkingExistingNetworks() -> Void {
        let parameters : Parameters
        if ((userDefaultLoginDetails.value(forKey: KConstant_UserID_key) as? String) != nil){
            parameters = ["userKey" : UserDefaults.standard.value(forKey: KConstant_UserID_key) as! String]
        }
        else{
            
            return
        }
        // Making post request
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForGetAllNetworks), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(responseFromCloudForGetAllNetworks(notificationReponseObject:)), name: Notification.Name(kNotificationNameForGetAllNetworks), object: nil)
        CloudWebRequestHandler.sharedInstance.stWebRequest(strURL: KURL_GET_ALL_NETWORKS, parameters: parameters, viewController: self, notificationName: kNotificationNameForGetAllNetworks)
    }
    
    @objc private func responseFromCloudForGetAllNetworks(notificationReponseObject : Notification) -> Void {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kNotificationNameForGetAllNetworks), object: nil)
        let responseMessage = (notificationReponseObject.object as! NSDictionary).value(forKey: KConstant_ResponseMessage_Key) as! String
        let jSON = JSON.init(parseJSON: responseMessage)
        let networkName = jSON["netName"].array!
        let networkMeshUUID = jSON["networksList"].array!
        for i in 0..<networkName.count{
            var ntwNameDictionary = Dictionary<String, Any>()
            ntwNameDictionary = [KConstantNetworkNameKey: networkName[i].string as Any , KConstantNetworkMeshUUID : networkMeshUUID[i].string as Any]
            arrayNetworkRetrieved.append(ntwNameDictionary)
        }
        print("NETWORKS RETRIEVED FROM CLOUD", arrayNetworkRetrieved)
        
        DispatchQueue.main.async {
            self.tblViewJoinNetwork.delegate = self
            self.tblViewJoinNetwork.dataSource = self
            self.tblViewJoinNetwork.reloadData()
        }
        
        print("Response message from:", responseMessage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnLoginClicked(_ sender: Any) {
        if (userDefaultLoginDetails.value(forKey: KConstant_UserID_key) == nil){
            LoginSignUpManager.sharedInstance.createLoginPage(callingClassDelegate: self)
        }
        else if (((sender as! UIButton).title(for: .normal))!.caseInsensitiveCompare("Logout") == .orderedSame)
        {
            let logoutButtonAction = { () ->Void in
                
                SignOutOperation.sharedInstance.signOutProcess(viewController : self)
            }
            
            let cancelButtonAction = { ()-> Void in
                
            }
            
            commonAlertView().setUpGUIAlertView(title: "", message: "Do you really want to Log out", viewController: self, firstButtonTitle: "logout", reqSecondButton: true, secondButtonText: "Cancel", firstButtonAction: logoutButtonAction, secondButtonAction: cancelButtonAction)        }
    }
    
    @IBAction func btnJoinNetworkClicked(_ sender: UIButton) {
        
        CloudOperationHandler.sharedInstance.joinNetwork(viewControllerInstance: self, joinKey: txtFieldJoinNetwork.text!)
    }
    
    @IBAction func btnRegisterNewNetwork(_ sender: UIButton) {
        
        CloudOperationHandler.sharedInstance.createNetwork(viewController: self)
    }
}


extension JoinAndRegisterNetworkViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayNetworkRetrieved.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: "joinedNetworkListCell", for: indexPath) as! JoinedNetworkTableViewCell
        let networkName = arrayNetworkRetrieved[indexPath.row][KConstantNetworkNameKey]
        let networkMeshUUID = arrayNetworkRetrieved[indexPath.row][KConstantNetworkMeshUUID]
        
        cell.configureJoinedNetworkCell(networkName:networkName as! String , networkUUID : networkMeshUUID as! String)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Path Index Tapped:",indexPath.row)
        let cellTapped = tableView.cellForRow(at: indexPath) as! JoinedNetworkTableViewCell
        let meshUUID = cellTapped.lblNetworkUUID.text
        UserDefaults.standard.set(meshUUID, forKey: KConstant_JoinedMeshNetworkUUID)
        CloudOperationHandler.sharedInstance.donwloadNetwork(viewController: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}


extension JoinAndRegisterNetworkViewController : LoginAndSignUpDelegate{
    func removeLoginClicked() {
        self.removeLoginView(tapGesture: nil)
    }
    
    func loginSuccessful() {
        SyncInviteViewController.isLogin = true
        self.removeLoginView(tapGesture: nil)
        self.btnLogin.setTitle("Logout", for: .normal)
        UIView.transition(with: self.btnLogin, duration: 0.75, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        appDelegate.menuViewController.btnLoginIn.setTitle("Logout", for: .normal)
        appDelegate.menuViewController.lblUserName.isHidden = false
        appDelegate.menuViewController.lblUserName.text = String(format: "Welcome  " + "\"" + ((UserDefaults.standard.value(forKey: KConstant_UserName_key) as? String))! + "\"")
        
        if let loginUsername = (UserDefaults.standard.value(forKey: KConstant_UserName_key)) , let ntwRegisteredUsername = (UserDefaults.standard.value(forKey: KConstant_NetworkRegisteredByUsername)), (loginUsername as! String).caseInsensitiveCompare((ntwRegisteredUsername as! String)) != .orderedSame {
            UserDefaults.standard.set(false, forKey: KConstant_UserCreatedNetworkOnCloud_Key)
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            self.checkingExistingNetworks()
        }
    }
    
    func signupSuccessful() {
        self.loginSuccessful()
    }
    
    @objc func removeLoginView(tapGesture:UITapGestureRecognizer?)  {
        
        self.navigationController?.popToViewController(self, animated: true)
    }
}


extension JoinAndRegisterNetworkViewController : SignOutOperationDelegate{
    func signOutSuccessful() {
        self.btnLogin.setTitle("Login", for: .normal)
        self.navigationController?.popViewController(animated: true)
        UIView.transition(with: self.btnLogin, duration: 0.3, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
}


extension JoinAndRegisterNetworkViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}
