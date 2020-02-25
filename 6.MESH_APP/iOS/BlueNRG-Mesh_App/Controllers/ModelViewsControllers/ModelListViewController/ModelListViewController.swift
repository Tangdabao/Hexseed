/**
 ******************************************************************************
 * @file    ModelListViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    04-June-2018
 * @brief   ViewController for displaying models selection View
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

class ModelListViewController:STMeshBaseViewController {
    @IBOutlet var collectionViewModelList: UICollectionView!
    var marrModelListViewController = NSMutableArray()
    var viewDisappeared = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Models"
        self.tabBarController?.title = "Mesh Models"
        marrModelListViewController.add("Vendor Model")
        marrModelListViewController.add("Genric Model")
        marrModelListViewController.add("Lightning Model")
        marrModelListViewController.add("Sensor Model")
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if(!UserDefaults.standard.bool(forKey: KConstantHelpScreenToShowForModelListViewController)){
            DispatchQueue.main.asyncAfter(deadline:.now()+0.15)
            {
                if (!self.viewDisappeared){
                    UserHelperScreenManager.HelpScreenForModelSelectionListViewController(objMeshModelListViewcontroller: self)
                    
                }
                else{
                    return
                }
            }
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewDisappeared = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if collectionViewModelList != nil{
            UIView.performWithoutAnimation {
                collectionViewModelList.reloadData()
            }
        }
    }
}

extension ModelListViewController:UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return marrModelListViewController.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collectionCell =  collectionView.dequeueReusableCell(withReuseIdentifier:"ModelListCollectionViewCell", for:indexPath) as? ModelListCollectionViewCell
        collectionCell?.configureModelList(index: indexPath.item)
        return collectionCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:((screenWidth - 40) / 3), height: ((screenWidth - 40) / 3))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigateToModelNodePage(index:indexPath.item)
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    
    func navigateToModelNodePage(index:Int){
        switch index {
        case 0:
            let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"VendorModelNodeListController", type:VendorModelNodeListController.self)
            (self.navigationController?.setViewControllers([controller], animated:true))
        case 1:
            let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"GenericModelNodeListController", type:GenericModelNodeListController.self)
            self.navigationController?.setViewControllers([controller], animated:true)
        case 2:
            let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"LightingModelNodeListController", type:LightingModelNodeListController.self)
            self.navigationController?.setViewControllers([controller], animated:true)
        case 3:
            let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"SensorModelViewControllerID", type:SensorModelViewController.self)
            self.navigationController?.setViewControllers([controller], animated:true)
        default:
            let controller = UIStoryboard.loadViewController(storyBoardName:"Models", identifierVC:"VendorModelNodeListController", type:VendorModelNodeListController.self)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
extension ModelListViewController : UserHelperScreenDelegate{
    func helperScreenClosed() {
        UserDefaults.standard.set(true, forKey: KConstantHelpScreenToShowForModelListViewController)
    }
    
    
}
class ModelListCollectionViewCell:UICollectionViewCell{
    
    @IBOutlet var modelNameLabel: UILabel!
    @IBOutlet var modelImageView: UIImageView!
    
    
    func configureModelList(index:Int){
        switch index {
        case 0:
            modelNameLabel.text = "Vendor"
            modelImageView.image = UIImage(named:"vendor_Icon")
            break
        case 1:
            modelNameLabel.text = "Generic"
            modelImageView.image = UIImage(named:"generic_Icon")
            break
        case 2:
            modelNameLabel.text = "Lighting"
            modelImageView.image = UIImage(named:"lighting_Icon")
            break;
        case 3:
            modelNameLabel.text = "Sensor"
            modelImageView.image = UIImage(named:"sensor_Icon")
            break;
        default:
            modelNameLabel.text = "Generic"
        }
    }
}
