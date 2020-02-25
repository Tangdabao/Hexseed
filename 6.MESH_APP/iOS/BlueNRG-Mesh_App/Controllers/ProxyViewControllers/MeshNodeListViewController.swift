/**
 ******************************************************************************
 * @file    ProvisionedCollectionViewCell.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    12-Dec-2017
 * @brief   Cell Class for ProvisionedCollectionViewCell.
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

let KNotificationForDownloadedNewNetwork = "Controll transfer for new network downloaded"
/* Main View Controller with Provisioned Nodes */
class MeshNodeListViewController: STMeshBaseViewController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var networkNodeView: UICollectionView!
    
    
    @IBOutlet var ViewSetUpOption: UIView!
    @IBOutlet weak var btnNewNetwork: UIButton!
    @IBOutlet weak var btnImportNetwork: UIButton!
    @IBOutlet weak var btnRemingMeLater: UIButton!
    
    @IBOutlet var viewNewNetworkName: UIView!
    @IBOutlet weak var btnCreateNetworkWithName: UIButton!
    @IBOutlet weak var txtFieldNetworkName: UITextField!
    
    @IBOutlet weak var layoutConstraintNewNetworkButtonTopSpace: NSLayoutConstraint!
    @IBOutlet weak var btnImportFromMail: UIButton!
    @IBOutlet weak var btnImportFromCloud: UIButton!
    
    var isReliableCommond = true
    var linked: Bool!
    var manager: STMeshManager?
    
    var operationMode = BLEOperationModes.Disabled
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var selectedIndexPath:IndexPath?
    var nodeToRemove : STMeshNode? = nil
    var nodeAddDic:[NSString:Any] = [:]
    
    var cellSelectedIndex : IndexPath!
    var lastSwitchState : Bool!
    let lblNew = UILabel()
    var strUUIDProxyValue : String = ""

    // MARK: Lifecycle Methods
    /* This function executes only when the view is loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"hamburger-menu-icon-1"), style: .plain, target: MenuViewIntializer.sharedInstance, action: #selector(MenuViewIntializer.handleMenuView))
        
        manager = STMeshManager.getInstance(self)
        manager?.getVendorModel().delegate = self
        //manager?.enablePromiscuousMode(true)
        
        
        if userDefault.bool(forKey: KConstantSIGTestData){
            currentNetworkDataManager.currentNetworkData.useDefaultSecuritiesCredential = true;
        }
        if (UserDefaults.standard.value(forKey: STMesh_NetworkSettings_Key) as? String != nil){

            self.currentNetworkDataManager.retrieveNetworkConfigFromStorage()
        }
        
        if  let node = CommonUtils.getCurrentProvisioner()
        {
            self.manager?.createNetwork(node)
        }else{
            self.manager?.createNetwork(10000)
        }
        self.manager?.setNetworkData(self.currentNetworkDataManager.currentNetworkData)
        self.setDataOnDic()
        self.tabBarItem.title = "Nodes"
        self.navigationItem.title = "BlueNRG-Mesh"
        self.tabBarController?.delegate = self
        self.networkNodeView.dataSource = self;
        self.networkNodeView.delegate = self;

        self.setUpMyLabel()
        self.setUpNoAddedDeviceSuggestionText()
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(KNotificationForDownloadedNewNetwork), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadedNewNetwork), name: Notification.Name(KNotificationForDownloadedNewNetwork), object: nil)
        manager?.getLogger()?.delegate = STLogReceiver.shareInstence
    }
    
    @objc func downloadedNewNetwork() -> Void {
        
        manager?.stopNetwork()
        self.didImportNewConfig()
        
        self.removeLoginView(tapGesture:UITapGestureRecognizer())

        UIView.animate(withDuration: 0.25, animations: {
            self.viewNewNetworkName.alpha = 0.0
            
        }) { (finished) in
            
            self.viewNewNetworkName.removeFromSuperview()
            self.viewNewNetworkName.frame = CGRect.zero
            
            self.viewNewNetworkName.alpha = 1.0
            
        }
        
    }
    
    /* This function will execute each time the view appears */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        DispatchQueue.main.async {
            self.networkNodeView?.scrollRectToVisible(CGRect.zero, animated: false)
            
            self.networkNodeView!.reloadData()
        }
        
        /* For the first time once the network will setup on user's click on create new network */
        if (UserDefaults.standard.object(forKey: STMesh_NetworkSettings_Key) as? String != nil){
            currentNetworkDataManager.saveNetworkConfigToStorage()
        }
        
        /* This for the cases when we come back from other screens */
        manager = STMeshManager.getInstance(self)
        manager?.getGenericModel().delegate = self
        
        if (!ProvisionerAdditionController.sharedInstance.checkIfProvisionerExist()){
            if currentNetworkDataManager.currentNetworkData.nodes.count > 0{
            
                ProvisionerAdditionController.sharedInstance.createProvisionerDataFieldValues()
            }
        }
        else{
            if (!UserDefaults.standard.bool(forKey: KConstantIsProvisionerAdded)){
                ProvisionerAdditionController.sharedInstance.AlreadyAddedProvisionerDataFieldValues()
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager?.startNetwork(0)
        self.networkNodeView!.reloadData()
        
        /* Calling helper screen */
        if(!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForProxyViewController)){
            UserHelperScreenManager.HelpScreenSetupForProvisionedViewController(objProvisionedCollectionView : self)
        }
        else if (UserDefaults.standard.object(forKey: STMesh_NetworkSettings_Key) as? String == nil){
            /* Open the upper code for cretae network view */
            self.btnCreateNewNetworkWithNameClicked(AnyClass.self)
        }
        else{
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.networkNodeView?.scrollsToTop = true
        self.networkNodeView?.scrollRectToVisible(CGRect.zero, animated: false)
        manager?.delegate = nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if networkNodeView != nil{
            UIView.performWithoutAnimation {
                networkNodeView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpMyLabel() {
        // let lblNew = UILabel()
        lblNew.backgroundColor = UIColor.white
        lblNew.text = "There are no nodes in your network. please add nodes by tapping add button in device tab"
        lblNew.textColor = UIColor.black
        lblNew.numberOfLines = 3
        lblNew.textAlignment = .center
        lblNew.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblNew)
        
        let widthConstraint = NSLayoutConstraint(item: lblNew, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth-40)
        let heightConstraint = NSLayoutConstraint(item: lblNew, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70)
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        /* Center vertically */
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",                         
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
    }
    
    @IBAction func btnRemindMeLaterClicked(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.ViewSetUpOption.alpha = 0.0
            
        }) { (finished) in
            
            self.ViewSetUpOption.removeFromSuperview()
            self.ViewSetUpOption.frame = CGRect.zero
            self.ViewSetUpOption.alpha = 1.0
            
        }
        
    }
    
    // MARK: Setup New Network
    let backBlurView = UIView()
    func callNetworkSetupView() -> Void {
        
        self.backBlurView.frame = self.view.frame
        self.backBlurView.addBlurEffect()
        /* Calling the set Up New Network View Presentation */
        let width = self.view.frame.size.width / 3
        let height = self.view.frame.size.height / 3
        
        self.ViewSetUpOption.frame = CGRect(x: width / 2, y: height, width: 2 * width, height: height)
        self.backBlurView.addSubview(self.ViewSetUpOption)
        UIView.transition(with: self.ViewSetUpOption, duration: 0.75, options: .transitionCrossDissolve, animations: nil, completion: nil)
        
        self.view.addSubview(self.backBlurView)
        
    }
    
    
    func removeLoginView(tapGesture:UITapGestureRecognizer) -> Void {
        self.backBlurView.removeFromSuperview()
    }
    
    @IBAction func btnImportNetworkClicked(_ sender: Any) {
        
    }
    
    @IBAction func btnSetUpNewNetworkClicked(_ sender: Any) {
        
        /* Calling the set Up New Network View Presentation */
        let width = self.view.frame.size.width / 3
        let height = self.view.frame.size.height / 3
        self.viewNewNetworkName.frame = CGRect(x: width / 2, y: height , width: 2 * width, height: height)
        
        self.btnRemindMeLaterClicked(sender)
        self.view.addSubview(self.viewNewNetworkName)
        UIView.transition(with: viewNewNetworkName, duration: 0.25, options: .transitionCurlUp, animations: nil) { (completion) in
            
        }
    }
    
    // MARK: Create Network View
    @IBAction func btnCreateNewNetworkWithNameClicked(_ sender: Any) {
        
        
        txtFieldNetworkName.text = "Default_Mesh"
        if (txtFieldNetworkName.text == "" && (txtFieldNetworkName.text?.count)! < 3){
            self.txtFieldNetworkName.layer.borderWidth = 1.0
            self.txtFieldNetworkName.layer.borderColor = UIColor.red.cgColor
            self.txtFieldNetworkName.viewQuakeGenricAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(int_fast64_t(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {() -> Void in
                
                self.txtFieldNetworkName.layer.borderWidth = 0.0
                self.txtFieldNetworkName.layer.borderColor = UIColor.clear.cgColor
            })
            return
        }
        currentNetworkDataManager.meshNetworkName = txtFieldNetworkName.text
        currentNetworkDataManager.retrieveNetworkConfigFromStorage()
        if  let node = CommonUtils.getCurrentProvisioner()
        {
            self.manager?.createNetwork(node)
        }else{
            self.manager?.createNetwork(10000)
        }
        manager?.setNetworkData(currentNetworkDataManager.currentNetworkData)
        currentNetworkDataManager.saveNetworkConfigToStorage()
        
        if (!ProvisionerAdditionController.sharedInstance.checkIfProvisionerExist()){
                ProvisionerAdditionController.sharedInstance.createProvisionerDataFieldValues()
        }
        else{
            if (!UserDefaults.standard.bool(forKey: KConstantIsProvisionerAdded)){
                ProvisionerAdditionController.sharedInstance.AlreadyAddedProvisionerDataFieldValues()
                
            }
        }
        if  let node = CommonUtils.getCurrentProvisioner()
        {
            self.manager?.createNetwork(node)
        }else{
            self.manager?.createNetwork(10000)
        }
        self.removeLoginView(tapGesture:UITapGestureRecognizer())
        //manager?
        UIView.animate(withDuration: 0.25, animations: {
            self.viewNewNetworkName.alpha = 0.0
            
        }) { (finished) in
            self.viewNewNetworkName.removeFromSuperview()
            self.viewNewNetworkName.frame = CGRect.zero
            self.viewNewNetworkName.alpha = 1.0
        }
    }
    
    // MARK: Set up No device added text in screen
    func setUpNoAddedDeviceSuggestionText() {
        // let lblNew = UILabel()
        lblNew.backgroundColor = UIColor.white
        lblNew.text = "There is no node in your network. Please add nodes by tapping add button "
        lblNew.textColor = UIColor.hexStringToUIColor(hex: "133063")
        lblNew.numberOfLines = 2
        lblNew.textAlignment = .center
        lblNew.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lblNew)
        
        let widthConstraint = NSLayoutConstraint(item: lblNew, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth-40)
        let heightConstraint = NSLayoutConstraint(item: lblNew, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70)
        var constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        /* Center vertically */
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
    }
    
    @IBAction func btnAddNewDeviceClicked(_ sender: Any) {
        if (self.ViewSetUpOption.frame.contains(self.view.center) || self.viewNewNetworkName.frame.contains(self.view.center)){
            self.ViewSetUpOption.viewQuakeGenricAnimation()
            self.viewNewNetworkName.viewQuakeGenricAnimation()
            
        }else{
            self.performSegue(withIdentifier: "goNext", sender: Any?.self)
        }
        
    }
    
    
    // MARK: Navigation Methods
    //sync the value of label name of diff view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        lastSwitchState =  false
        if segue.identifier == "settingsSegue"{
            
            let destinationVC = segue.destination as! NodeSettingViewController
            let button = sender as! UIButton
            /* Check both options, can be optimized */
            var cell = button.superview?.superview?.superview?.superview as? provisionedNodeCollectionViewCell
            if(cell == nil){
                cell = button.superview?.superview?.superview?.superview?.superview as? provisionedNodeCollectionViewCell
            }
            if(cell != nil){
                cellSelectedIndex = cell!.indexPath!
                let node = currentNetworkDataManager.currentNetworkData.nodes[cellSelectedIndex.row] as! STMeshNode
                destinationVC.settingsNode = node
                destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
                destinationVC.isProxyNodeConnectionEstablished = (manager?.isConnectedToProxyService())!
                destinationVC.lastSwitchState = cell?.mainSwitch.isOn;
                lastSwitchState = cell?.mainSwitch.isOn
                destinationVC.isComingFromElement = false;
                
                destinationVC.delegate = self
                
            }
        }
        if segue.identifier == "ElementSettingsSegue"{
            
            let destinationVC = segue.destination as! ElementSettingViewController
            let button = sender as! UIButton
            /* Check both options, can be optimized */
            var cell = button.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview as? provisionedNodeCollectionViewCell
            if(cell == nil){
                cell = button.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview as? provisionedNodeCollectionViewCell
            }
            var tableViewCell = button.superview?.superview?.superview?.superview as? ProvisionedElementsTableViewCell
            if (tableViewCell == nil){
                tableViewCell = button.superview?.superview?.superview?.superview?.superview as? ProvisionedElementsTableViewCell
            }
            if(cell != nil && tableViewCell != nil){
                cellSelectedIndex = cell!.indexPath!
                let node = currentNetworkDataManager.currentNetworkData.nodes[cellSelectedIndex.row] as! STMeshNode
                destinationVC.nodeRelatedToElement = node
                destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
                destinationVC.isProxyNodeConnectionEstablished = (manager?.isConnectedToProxyService())!
                let element = node.elementList[(tableViewCell?.indexPath?.row)!] as! STMeshElement;
                destinationVC.indexPathElement = IndexPath(row: (tableViewCell?.indexPath?.row)!, section: cellSelectedIndex.row)
                destinationVC.elementSetting = element
                lastSwitchState = cell?.mainSwitch.isOn
                destinationVC.delegate = self as ElementSettingDelegate
            }
        }
        else if segue.identifier == "modelGroupDetails"{
            //let destinationVC = segue.destination as! InfoViewController
        }
        else if segue.identifier == "settingInfoSegue"{
            let destinationVC = segue.destination as! InfoViewController
            let button = sender as! UIButton
            /* Check both options, can be optimized */
            var cell = button.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview as? provisionedNodeCollectionViewCell
            if(cell == nil){
                cell = button.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview?.superview as? provisionedNodeCollectionViewCell
            }
            var tableViewCell = button.superview?.superview?.superview?.superview as? ProvisionedElementsTableViewCell
            if (tableViewCell == nil){
                tableViewCell = button.superview?.superview?.superview?.superview?.superview as? ProvisionedElementsTableViewCell
            }
            if(cell != nil && tableViewCell != nil){
                let indexPath = cell!.indexPath
                let node = currentNetworkDataManager.currentNetworkData.nodes[indexPath!.row] as! STMeshNode
                let element = node.elementList[(tableViewCell?.indexPath?.row)!] as! STMeshElement;
                destinationVC.ElementInfo = element
                destinationVC.isComingFromElementView = true
                destinationVC.infoNode = node
            }
        }
        else if segue.identifier == "goNext"{
            
            let destinationVC = segue.destination as! MeshDeviceListViewController
            destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
            destinationVC.operationMode = self.operationMode
            /* Find next free unicast address */
        }
        else if segue.identifier == "ImportExportConfigControllerSegue"{
            let destinationVC = segue.destination as! ImportExportConfigController
            destinationVC.isComingFromFirstTimeSetup = true
        }
    }
    
    func readRemoteData(addr:UInt16, data:Data,readType:UInt8)
    {
        manager?.getVendorModel().readRemoteData(addr, usingOpcode:readType, send: data as Data?)
    }
    
    //MARK:Custom Instance method
    func chnageCellColorWithStatus(){
        if selectedIndexPath != nil{
            let cell = networkNodeView.cellForItem(at:selectedIndexPath!)
            cell?.backgroundColor = UIColor.hexStringToUIColor(hex: "FFFFCC")
        }
    }
    
    func setDataOnDic(){
        for (index, element) in currentNetworkDataManager.currentNetworkData.nodes.enumerated() {
            nodeAddDic.updateValue( index, forKey:NSString(format:"%i", ((element as? STMeshNode)?.unicastAddress)!))
        }
    }
    func navigateToConfigureScreen(node:STMeshNode){
        let controller = UIStoryboard.loadViewController(storyBoardName: "Main", identifierVC: "AddConfigurationViewController", type: AddConfigurationViewController.self)
        controller.nodeBeingAdded = node
        controller.currentNetworkDataManager = self.currentNetworkDataManager
        controller.isCommingFromAllElementClickedButton = true;
        controller.elementIndexInNodeElementArray = 0;
        self.addModelToSeleclectedElement(index: 0, isComingFromAllElement: true, node: node)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func addModelToSeleclectedElement(index:Int , isComingFromAllElement:Bool ,node : STMeshNode){
        
    }
    
    func isConfigureNotComplete(currentNode:STMeshNode) ->Bool{
        if !currentNode.configComplete{
            CommonUtils.showAlertWithOptionMessage(message:"Configuration of this node is not complete, Do you want to configure it?", continueBtnTitle:"Yes", cancelBtnTitle:"No", controller: self) { (response) in
                self.navigateToConfigureScreen(node: currentNode)
            }
        }
        return currentNode.configComplete
    }
    
    
    func btnHeartbeatInfoClicked(nodeIndexValue : Int) {
//        objHeartbeatInfoVC.delegate = self
//        objHeartbeatInfoVC.selectedNode = currentNetworkDataManager.currentNetworkData.nodes[nodeIndexValue] as? STMeshNode
//        self.navigationController?.pushViewController(objHeartbeatInfoVC, animated: true)
    }
    
    func btnHealthModelFaultsWarningClicked(nodeIndexValue : Int) {
        //faults will be shown here.
        //        objHeartbeatInfoVC.selectedNode = currentNetworkDataManager.currentNetworkData.nodes[nodeIndexValue] as? STMeshNode
        //        self.navigationController?.pushViewController(objHeartbeatInfoVC, animated: true)
    }
}//class ends

extension MeshNodeListViewController : UITabBarDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: UINavigationController.self){
            let myViewController = viewController.childViewControllers[0]
            if myViewController.isKind(of: GroupsCollectionViewController.self){
                let destinationVC = myViewController as! GroupsCollectionViewController
                destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
                destinationVC.manager = self.manager!
                lastSwitchState = false
            }
        }
        return true
    }
}

extension MeshNodeListViewController:UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let addressString = (currentNetworkDataManager.currentNetworkData.nodes[indexPath.row] as! STMeshNode).nodeUUID {
            let size = CGSize(width:screenWidth - 173 , height: 50)
            let attributes = [kCTFontAttributeName:UIFont.systemFont(ofSize:15)]
            let estimatedFrame = NSString(string:addressString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context:nil)
            let elementCount = (currentNetworkDataManager.currentNetworkData.nodes[indexPath.row] as! STMeshNode).elementList.count ;
            return CGSize(width: view.frame.width, height:estimatedFrame.height +  45 + 64 * CGFloat(elementCount))
        }
        return CGSize(width: view.frame.width, height:1.78 * 39.5)
    }
    
    /* This function returns the no. of cells in collection view */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let nodes = currentNetworkDataManager.currentNetworkData.nodes {
            lblNew.isHidden = nodes.count > 0 ? true  : false
            return nodes.count
        }
        lblNew.isHidden = false
        return 0
    }
    
    /* This determines the value of labels and buttons on each cell */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! provisionedNodeCollectionViewCell
        let nodeIndex = indexPath.row
        
        if let nodes = (currentNetworkDataManager.currentNetworkData.nodes as? [STMeshNode]){
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configureCell(node: nodes[nodeIndex])
            
            if (nodes[nodeIndex].nodeUUID.caseInsensitiveCompare(strUUIDProxyValue) == .orderedSame)
            {
                cell.nodeName.textColor = UIColor.ST_Maroon
                cell.nodeName.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
            }
            else
            {
                cell.nodeName.textColor = UIColor.black
                cell.nodeName.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
            }
            if(cellSelectedIndex != nil)
            {
                if (indexPath.row == selectedIndexPath?.row)
                {
                    if (lastSwitchState != nil)
                    {
                        cell.mainSwitch .setOn(lastSwitchState, animated: true)
                    }
                }
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}


extension MeshNodeListViewController: ProvisionedNodeCellProtocol {
    
    func heartbeatInfoButtonClicked(indexPathSection: Int) {
        self.btnHeartbeatInfoClicked(nodeIndexValue: indexPathSection)
    }
    
    func healthModelFaultsWarningButtonClicked(indexPathSection: Int) {
        
    }
    
    func switchStateDidChange(index: IndexPath, switchState:Bool) -> Bool {
        if (manager?.isConnectedToProxyService())!{
            /* For element checking */
            let nodeElement = currentNetworkDataManager.currentNetworkData.nodes[index.section] as! STMeshNode
            let element = nodeElement.elementList[index.row] as! STMeshElement
            self.selectedIndexPath = index
            /* Send toggle command */
            if isConfigureNotComplete(currentNode: nodeElement) == true{
                LEDControlManager.setLEDState(controller:self, manager:manager!, addr: element.unicastAddress, cmd:switchState)
                
                // comment before release
                //                let objHeartbeatModel = manager?.getHeartbeatModel()
                //                objHeartbeatModel?.heartbeatPublicationSet(nodeElement.unicastAddress, destinationAddress: 2, countLog: 5, periodLog:3 , ttl: 5, features: 3, netKeyIndex: 0)
            }
            return true
        }
        else {
            CommonUtils.showAlertTostMessage(title: "ALERT!", message: "Connection is not established with proxy node.", controller: self, success: { (response) in
                
            })
            return false
        }
    }
}


extension MeshNodeListViewController: SettingsDelegate {
    func deleteNode(nodeToDelete: STMeshNode, forceDelete: Bool)->Bool  {

        return  true
    }
    
    func updateNodeName(nodeUpdated: STMeshNode, newName: String) ->Bool{
        nodeUpdated.nodeName = newName
        for i in 0..<currentNetworkDataManager.currentNetworkData.groups.count{
            let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
            for a in 0..<group.subscribersElem.count{
                let element = group.subscribersElem[a] as! STMeshElement
                if(element.parentNode.nodeUUID == nodeUpdated.nodeUUID){
                    element.parentNode.nodeName = newName
                    break;
                }
            }
        }
        currentNetworkDataManager.saveNetworkConfigToStorage()
        return true
    }
    
    func updateSwitchStatus(nodeUpdated: STMeshNode, status: Bool) -> Bool {

        nodeUpdated.switchState = status
        lastSwitchState = status
        /* Send toggle command */
        LEDControlManager.setLEDState(controller:self, manager:manager!, addr:(nodeUpdated.elementList[0] as! STMeshElement).unicastAddress, cmd: lastSwitchState)
        return true
    }
    
}


extension MeshNodeListViewController:STMeshVendorModelDelegate{
    
    func vendorModel(_ vendorModel: STMeshVendorModel!, didReceiveResponseFromAddress peerAddress: UInt16, usingOpcode opcode: UInt8, recvData data: Data!) {
    }
    
    func vendorModel(_ vendorModel: STMeshVendorModel!, didReceiveMessageFromAddress sourceAddress: UInt16,
                     toDestination destinationAddress: UInt16, usingOpcode opcode: UInt8, data: Data!, msgType:VendorModelMsgTypes) {
        print("Vendor Recd: Src = \(sourceAddress), Dest = \(destinationAddress), OpCode \(opcode)")
    }
}


extension MeshNodeListViewController:STMeshGenericModelDelegate{
    func genericModel(_ genericModel: STMeshGenericModel!, didReceiveOnOffStatusFromAddress peerAddress: UInt16, presentOnOff presentState: UInt8, targetOnOff targetState: UInt8, remainingTime time: UInt8) {
        print("Generic On/Off Status Recd: Src = \(peerAddress) On/Off Status = \(presentState)")
    }
    
    func genericModel(_ genericModel: STMeshGenericModel!, didReceiveLevelStatusFromAddress peerAddress: UInt16, presentOnOff presentState: UInt16, targetOnOff targetState: UInt16, remainingTime time: UInt16) {
    }
}

// MARK: - STMeshManagerDelegate Functions
extension MeshNodeListViewController: STMeshManagerDelegate {
    
    func meshManager(_ manager:STMeshManager!, didBTStateChange state:STMeshBleRadioState) {
        let radioMode = ProvisioningManager.getSTMeshBleRadioStatus(state:state)
        operationMode = radioMode.mode
        if operationMode == BLEOperationModes.DummyMode{
            CommonUtils.showAlertWithOptionMessage(message:radioMode.message!, continueBtnTitle:"Yes", cancelBtnTitle: "No", controller:self) { (response) in
                manager.setDummyMode(true)
            }
        }
    }
    
    func meshManager(_ manager:STMeshManager!, didProxyConnectionChanged isConnected:Bool) {
        if !isConnected{
            strUUIDProxyValue = ""
            self.networkNodeView?.reloadData()
        }
    }
    
    func meshManager(_ manager: STMeshManager!, didProxyNodeAddressRetrieved strUUID: String!, peerAddress: UInt16) {
        strUUIDProxyValue = strUUID
        self.networkNodeView?.reloadData()
    }
    func meshManager(_ manager: STMeshManager!, didErrorOccurred errMessage: String!) {
        print("Error Message!!!!" , errMessage)
    }
}

extension MeshNodeListViewController : ElementSettingDelegate
{
    func deleteElement(nodeToDelete: STMeshNode, elementUpdates: STMeshElement, forceDelete: Bool) -> Bool {
        return true;
    }
    
    func updateElementName(nodeUpdated: STMeshNode, elementUpdated: STMeshElement, newName: String) -> Bool {
        
        elementUpdated.elementName = newName
        for i in 0..<currentNetworkDataManager.currentNetworkData.groups.count{
            let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
            for a in 0..<group.subscribersElem.count{
                let element = group.subscribersElem[a] as! STMeshElement
                if (element.unicastAddress == elementUpdated.unicastAddress){
                    elementUpdated.elementName = newName 
                }
            }
        }
        currentNetworkDataManager.saveNetworkConfigToStorage()
        return true
    }
    
    func updateElementSwitchStatus(nodeUpdated: STMeshNode,elementUpdates: STMeshElement ,indexPath: IndexPath, status: Bool)->Bool
    {
        _ = self.switchStateDidChange(index: indexPath, switchState: status)
        return true
    }
}


extension MeshNodeListViewController : UserHelperScreenDelegate{
    
    func helperScreenClosed() {
        /* To set the standard user default */
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForProxyViewController)
        if ((currentNetworkDataManager.currentNetworkData.netKey == nil)){
            /* Open the upper code for cretae network view */
            self.btnCreateNewNetworkWithNameClicked(AnyClass.self)
            
        }
        if (!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForProxyViewControllerOnAtleastOneNode)){
            
            if currentNetworkDataManager.currentNetworkData.nodes.count > 0{
                UserHelperScreenManager.HelpScreenForMeshNodeListViewControllerWhenNodeIsAdded(objMeshNodeListViewController: self)
            }
        }
    }
}
