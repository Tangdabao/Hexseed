/**
 ******************************************************************************
 * @file    AddViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    10-Nov-2017
 * @brief   ViewController for "Provisioning" View.
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

/* Main Screen -> Click on Add Button */
class MeshDeviceListViewController: STMeshBaseViewController {
    @IBOutlet var addTitle: UILabel!
    @IBOutlet var UnprovisionedCollectionView: UICollectionView!
    
    
    /* Public variables for source CV to set */
    var addTimer: Timer!
    var manager: STMeshManager?
    var provisioningTimer: Timer!
    var nodeBeingAdded: STMeshNode?
    var unprovisionedNodesCount = 0
    var nodeToAdd: UnprovisionedNode!
    var provisioningCurrentStep = 0
    let PROVISIONING_MAX_STEPS = 10
    var dummyNodes: [UnprovisionedNode] = []
    var unicastAddressOfNewNode: UInt16 = 0
    var operationMode = BLEOperationModes.Disabled
    var unprovisionedNodes: [UnprovisionedNode] = []
    var provisioningManager = ProvisioningManager()
    weak var provisioningProgressView: ProvisioningPopUpController?
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    var isCommingFromAllElement: Bool!
    var provisionDone = false
    let lblNew = UILabel()
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.UnprovisionedCollectionView.delegate = self
        self.UnprovisionedCollectionView.dataSource = self
        // title of this scene
        self.navigationItem.title = "Devices"
        self.tabBarController?.title = "Devices"
        // back button
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: nil, action: nil);
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        setUpMyLabel()
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        unprovisionedNodes = []
        UnprovisionedCollectionView.reloadData()
        provisioningManager.initialSetup(currrentNewworkData:currentNetworkDataManager)
        provisioningManager.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
        }
        // provisioningManager.stopDeviceScan()
        if  self.addTimer != nil  {
            addTimer.invalidate()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UnprovisionedCollectionView != nil{
            UIView.performWithoutAnimation {
                UnprovisionedCollectionView.reloadData()
            }
        }
    }
    
    func setUpMyLabel() {
        // let lblNew = UILabel()
        lblNew.backgroundColor = UIColor.white
        lblNew.text = "Please make sure that the device you wish to provision is switched on and in range."
        lblNew.textColor = UIColor.black
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
        
        // Center vertically
        constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=1)-[label]",
            options: NSLayoutFormatOptions.alignAllCenterY,
            metrics: nil,
            views: ["superview":view, "label":lblNew])
        view.addConstraints(constraints)
        
        view.addConstraints([ widthConstraint, heightConstraint])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addPopUpSegue" {
            let destinationVC = segue.destination as! ProvisioningPopUpController
            self.provisioningProgressView = destinationVC
            provisioningManager.startProvisioningforNode(node: nodeToAdd, progressView: destinationVC)
            // starting Timer for calculating Provisioning Time value
            //self.tabBarController?.tabBar.isHidden = true
            STCustomEventLogClass.sharedInstance.STEvent_ProvisioningStartEvent()
        }
        if segue.identifier == "performNodeElementListSegue"
        {
            //  addModelToSeleclectedElement()
            STCustomEventLogClass.sharedInstance.STEvent_ProvisioningEndEvent()
            let destinationVC = segue.destination as! NodesElementListViewController
            destinationVC.nodeAddedToNetwork = nodeBeingAdded
            destinationVC.delegate = self
            provisionDone = false
            destinationVC.nodesElementAddedToNetwork = nodeBeingAdded?.elementList
        }
        
        if segue.identifier == "groupSegue"{
            let destinationVC = segue.destination as! AddConfigurationViewController
            destinationVC.currentNetworkDataManager = self.currentNetworkDataManager
            destinationVC.nodeBeingAdded = self.nodeBeingAdded
            destinationVC.isCommingFromAllElementClickedButton = isCommingFromAllElement
            destinationVC.delegate = self
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "performNodeElementListSegue" && !provisionDone  {
            let button = sender as! UIButton
            let pos:CGPoint = button.convert(.zero, to: self.UnprovisionedCollectionView)
            let indexPath = self.UnprovisionedCollectionView.indexPathForItem(at: pos)
            nodeToAdd = unprovisionedNodes[indexPath!.row] as UnprovisionedNode
            performSegue(withIdentifier: "addPopUpSegue", sender: self)
            return false
        }else{
            
            provisionDone = false
        }
        return true
    }
}

// MARK: Collection View Data Source and delegate Method
extension MeshDeviceListViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width*0.9 , height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> NSInteger {
        lblNew.isHidden = unprovisionedNodes.count > 0 ? true  : false
        return unprovisionedNodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "unprovisionedCell", for: indexPath) as! MeshDeviceListCollectionViewCell
        cell.configureCell(node: unprovisionedNodes[indexPath.row])
        return cell
    }
}

extension MeshDeviceListViewController:ProvisioningManagerDelegate{
    func didProvisioningFinishFor(unprovisionedNode: UnprovisionedNode, newNode: STMeshNode) {
        self.nodeBeingAdded = newNode
        performSegue(withIdentifier: "performNodeElementListSegue", sender: self)
    }
    
    func didReciveNewNode(newNode: UnprovisionedNode) {
        unprovisionedNodes.append(newNode)
        let indexPath = IndexPath(row: unprovisionedNodes.count - 1, section: 0)
        UnprovisionedCollectionView.insertItems(at: [indexPath])
    }
    
    func rssiValueDidChangeFor(node: UnprovisionedNode, index: IndexPath) {
        unprovisionedNodes[index.row].rssiValue = node.rssiValue
        let cell = self.UnprovisionedCollectionView.cellForItem(at:index) as? MeshDeviceListCollectionViewCell
        cell?.rssiValue.text = "\(unprovisionedNodes[index.row].rssiValue)"
    }
}


extension MeshDeviceListViewController : NodeElementTableViewControllerDelegate{
    
    func configurationButtonClicked(isAllElementConfigButtonPressed: Bool , nodeBeingAdded: STMeshNode, elementIndexInNodeElementArray: Int) {
        self.nodeBeingAdded = nodeBeingAdded
        self.isCommingFromAllElement = isAllElementConfigButtonPressed
        let controller = UIStoryboard.loadViewController(storyBoardName: "Main", identifierVC: "AddConfigurationViewController", type: AddConfigurationViewController.self)
        controller.currentNetworkDataManager = self.currentNetworkDataManager
        controller.nodeBeingAdded = self.nodeBeingAdded
        controller.elementIndexInNodeElementArray = elementIndexInNodeElementArray
        controller.isCommingFromAllElementClickedButton = isCommingFromAllElement
        if isCommingFromAllElement {
            
            for elementIndex in 0..<nodeBeingAdded.elementList.count{
                let element = nodeBeingAdded.elementList[elementIndex] as! STMeshElement
                if  element.subscribedGroups.count == 0{
                    controller.elementIndexInNodeElementArray = elementIndex
                    break;
                }
            }
        }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func addModelToSeleclectedElement(){
        if (nodeBeingAdded?.elementList[0] as! STMeshElement).modelList.count < 1 {
            for i in 0 ..< self.nodeBeingAdded!.elementList.count {
                let elementRelatedToNodeInIndex = self.nodeBeingAdded?.elementList[i] as! STMeshElement
                let model = STMeshModel()
                model.modelId = UInt32(001)
                elementRelatedToNodeInIndex.modelList.add(model)
            }
            self.currentNetworkDataManager.saveNetworkConfigToStorage()
        }
    }
}


extension MeshDeviceListViewController : AddGroupPopUpViewDelegate{
    
    func startProvision(flag: Bool, group:STMeshGroup)
    {
        if (flag == true){
            unprovisionedNodesCount = 0
            self.unprovisionedNodes = []
            self.UnprovisionedCollectionView.reloadData()
        }
    }
}

