/**
 ******************************************************************************
 * @file    UserHelperScreenManager.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    20-Apr-2018
 * @brief   Helper class for displaying user helper screens.
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

class UserHelperScreenManager: NSObject {
    
    //MARK: HELP SCREEN SETUP
    class func HelpScreenSetupForProvisionedViewController(objProvisionedCollectionView:MeshNodeListViewController) -> Void{
        
        
        // adding Help in Elements
        let marrButtons = NSMutableArray()
        //  Add new Device Button Added
        
        var mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Side Menu - Global settings are accessed from here.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objProvisionedCollectionView.navigationItem.leftBarButtonItem as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Devices Tab – Opens the provisioning View.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objProvisionedCollectionView.tabBarController?.tabBar.items?[0] as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Nodes Tab – Opens the Network View.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objProvisionedCollectionView.tabBarController?.tabBar.items?[1] as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Groups Tab – Opens the Groups view.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objProvisionedCollectionView.tabBarController?.tabBar.items?[2] as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Models Tab – Opens the Models view.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objProvisionedCollectionView.tabBarController?.tabBar.items?[3] as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        
        // Help Class Instance
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.delegate = objProvisionedCollectionView
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
        // To set the standard user default
        //        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForProxyViewController)
    }
    
    
    
    //MARK: HELP SCREEN SETUP
    class func HelpScreenSetupForSettingViewController(objSettingViewController :NodeSettingViewController) -> Void
    {
        /* Adding Help in Elements */
        let marrButtons = NSMutableArray()
        
        /* Node Name Helper */
        var mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Current node name.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objSettingViewController.viewNodeNameBar, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* Edit Node name helper */
        var mdictHelpAddButton = NSMutableDictionary()
        mdictHelpAddButton.setObject("You can edit node name here.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpAddButton.setObject(objSettingViewController.btnEditName, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpAddButton)
        
        /* Device MAC Address Helper */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject(" Device UUID for identification.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objSettingViewController.viewNodeAddressBar, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* Proxy Supported helper */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Proxy feature Control.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objSettingViewController.viewProxyBar, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* Relay supported helper */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Relay feature Control.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objSettingViewController.viewRelayBar, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* Friend Supported helper */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Friend feature Control.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objSettingViewController.viewFriendBar, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        
        /* Low Power supported helper */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Low Power feature control.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objSettingViewController.viewLowPowerBar, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* Remove Node from netwok */
        mdictHelpAddButton = NSMutableDictionary()
        mdictHelpAddButton.setObject("Un-provision the node.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpAddButton.setObject(objSettingViewController.btnRemoveNode as UIView, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpAddButton)
        
        /* Help Class Instance */
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForSettingViewController)
        
        
    }
    
    class func HelpScreenForMeshNodeListViewControllerWhenNodeIsAdded(objMeshNodeListViewController : MeshNodeListViewController){
        
        let selectedNodeIndex = 0
        let networkData = NetworkConfigDataManager.sharedInstance
        let selectedNode = networkData.currentNetworkData.nodes[selectedNodeIndex] as! STMeshNode
        objMeshNodeListViewController.view.layoutIfNeeded()
        let selectedCellInCollectionView = objMeshNodeListViewController.collectionView(objMeshNodeListViewController.networkNodeView, cellForItemAt: IndexPath(item: 0, section: 0)) as! provisionedNodeCollectionViewCell
        selectedCellInCollectionView.layoutIfNeeded()
        let selectedCellElementView = selectedCellInCollectionView.tableView(selectedCellInCollectionView.tblViewElements, cellForRowAt: IndexPath(item: 0, section: 0)) as! ProvisionedElementsTableViewCell
        selectedCellElementView.layoutIfNeeded()
        
        
        let marrButtons = NSMutableArray()
        //  Add new Device Button Added
        
        var mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Node name, You can edit in setting page.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedCellInCollectionView.nodeName as UIView, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        if (selectedNode.features.proxy == 1){
            mdictHelpNodesDescriptionButton = NSMutableDictionary()
            mdictHelpNodesDescriptionButton.setObject("P indicates: Proxy feature supported.", forKey: KConstantHelpMessageKey as NSCopying)
            mdictHelpNodesDescriptionButton.setObject(selectedCellInCollectionView.proxyButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
            marrButtons.add(mdictHelpNodesDescriptionButton)
        }
        if (selectedNode.features.relay == 1){
            mdictHelpNodesDescriptionButton = NSMutableDictionary()
            mdictHelpNodesDescriptionButton.setObject("R indicates: Relay feature supported.", forKey: KConstantHelpMessageKey as NSCopying)
            mdictHelpNodesDescriptionButton.setObject(selectedCellInCollectionView.realyNode as UIButton, forKey: KConstantHelpElementKey as NSCopying)
            marrButtons.add(mdictHelpNodesDescriptionButton)
        }
        if (selectedNode.features.lowPower == 1){
            mdictHelpNodesDescriptionButton = NSMutableDictionary()
            mdictHelpNodesDescriptionButton.setObject("L indicates: Low power feature supported.", forKey: KConstantHelpMessageKey as NSCopying)
            mdictHelpNodesDescriptionButton.setObject(selectedCellInCollectionView.lowPowerButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
            marrButtons.add(mdictHelpNodesDescriptionButton)
        }
        if (selectedNode.features.friendFeature == 1){
            mdictHelpNodesDescriptionButton = NSMutableDictionary()
            mdictHelpNodesDescriptionButton.setObject("F indicates: Friend feature supported.", forKey: KConstantHelpMessageKey as NSCopying)
            mdictHelpNodesDescriptionButton.setObject(selectedCellInCollectionView.friendButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
            marrButtons.add(mdictHelpNodesDescriptionButton)
        }
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Node Setting will open from here.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedCellInCollectionView.nodeSettings as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        
        /* Elements Helper guide start from here */
        /* setting icon */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Element Setting will open from here.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedCellElementView.btnElementSetting as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* Models view help */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Model supported in a element shows here.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedCellElementView.modelView as UIView, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        /* switch on/off help */
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Element on/off command operates from here.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedCellElementView.switchElement as UISwitch, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        
        
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.delegate = objMeshNodeListViewController
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
        /* To set the standard user default */
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForProxyViewControllerOnAtleastOneNode)
    }
    class func HelpScreenForModelSelectionListViewController(objMeshModelListViewcontroller : ModelListViewController){
        
        let modelRandomSelection = arc4random_uniform(UInt32(objMeshModelListViewcontroller.marrModelListViewController.count))
        let selectAnyItemInModelListController = objMeshModelListViewcontroller.collectionView(objMeshModelListViewcontroller.collectionViewModelList, cellForItemAt: IndexPath(item: Int(modelRandomSelection), section: 0))
        
        let marrButtons = NSMutableArray()
        //  Add new Device Button Added
        
        let mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("You can select any model.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectAnyItemInModelListController as UICollectionViewCell, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.delegate = objMeshModelListViewcontroller
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
    }
    
    class func HelpScreenForVendorModelViewController(objVendorModelListViewController : VendorModelNodeListController){
        
        objVendorModelListViewController.view.layoutIfNeeded()
        
        let selectedNodeCellInModelView = objVendorModelListViewController.tableView(objVendorModelListViewController.vendorModelTableView, cellForRowAt: IndexPath(item: 0, section: 0)) as! VendorModelListTableCell
        let selectedElementCellInModelView = selectedNodeCellInModelView.tableView(selectedNodeCellInModelView.tblViewElement, cellForRowAt: IndexPath(item: 0, section: 0)) as! ProvisionedElementsTableViewCell
        
        let marrButtons = NSMutableArray()
        //  Add new Device Button Added
        var mdictHelpNodesDescriptionButton = NSMutableDictionary()
        //        mdictHelpNodesDescriptionButton.setObject("Vendor Model \"On/Off command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        //        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.switchElement as UISwitch, forKey: KConstantHelpElementKey as NSCopying)
        //        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Vendor Model \"Toggle command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.toggleButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Vendor Model \"Version command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.versionButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Vendor Model \"Intensity control\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.intensityButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("You can change model selection anytime.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objVendorModelListViewController.navigationItem.rightBarButtonItem as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.delegate = objVendorModelListViewController
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
    }
    
    class func HelpScreenForLightingModelViewController(objLightingModelListViewController : LightingModelNodeListController){
        let selectedNodeCellInModelView = objLightingModelListViewController.tableView(objLightingModelListViewController.tableView, cellForRowAt: IndexPath(item: 0, section: 0)) as! LightingModelListTableCell
        
        let selectedElementCellInModelView = selectedNodeCellInModelView.tableView(selectedNodeCellInModelView.elementTableView, cellForRowAt: IndexPath(item: 0, section: 0)) as! ProvisionedElementsTableViewCell
        let marrButtons = NSMutableArray()
        //  Add new Device Button Added
        var mdictHelpNodesDescriptionButton = NSMutableDictionary()
//        mdictHelpNodesDescriptionButton.setObject("Lighting Model \"On/Off command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
//        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.switchElement as UISwitch, forKey: KConstantHelpElementKey as NSCopying)
//        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Lighting Model \"Lightness command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.levelButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Lighting Model \"CTL command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.batteryButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("You can change model selection anytime.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objLightingModelListViewController.navigationItem.rightBarButtonItem as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.delegate = objLightingModelListViewController
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
    }
    
    
    class func HelpScreenForGenricModelViewController(objGenericModelNodeListController : GenericModelNodeListController){
        
        let selectedNodeCellInModelView = objGenericModelNodeListController.tableView(objGenericModelNodeListController.genericModelTableView, cellForRowAt: IndexPath(item: 0, section: 0)) as! GenericModelListTableCell
        let selectedElementCellInModelView = selectedNodeCellInModelView.tableView(selectedNodeCellInModelView.elementTableView, cellForRowAt: IndexPath(item: 0, section: 0)) as! ProvisionedElementsTableViewCell
        let marrButtons = NSMutableArray()
        //  Add new Device Button Added
        var mdictHelpNodesDescriptionButton = NSMutableDictionary()
//        mdictHelpNodesDescriptionButton.setObject("Genercic Model \"On/Off command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
//        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.switchElement as UISwitch, forKey: KConstantHelpElementKey as NSCopying)
//        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("Genric Model \"level command\" button.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(selectedElementCellInModelView.levelButton as UIButton, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        mdictHelpNodesDescriptionButton = NSMutableDictionary()
        mdictHelpNodesDescriptionButton.setObject("You can change model selection anytime.", forKey: KConstantHelpMessageKey as NSCopying)
        mdictHelpNodesDescriptionButton.setObject(objGenericModelNodeListController.navigationItem.rightBarButtonItem as Any, forKey: KConstantHelpElementKey as NSCopying)
        marrButtons.add(mdictHelpNodesDescriptionButton)
        
        let objUserHelperScreen = UserHelperScreen(frame: CGRect())
        objUserHelperScreen.delegate = objGenericModelNodeListController
        objUserHelperScreen.showHelpForElements(marrElements: marrButtons)
        UIApplication.shared.windows[0].addSubview(objUserHelperScreen)
    }
}
