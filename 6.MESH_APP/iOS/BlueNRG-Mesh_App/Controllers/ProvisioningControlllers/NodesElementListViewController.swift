/**
 ******************************************************************************
 * @file    NodesElementListViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    13-Mar-2018
 * @brief   ViewController for "Nodes Element List" View.
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

protocol NodeElementTableViewControllerDelegate {
    func configurationButtonClicked(isAllElementConfigButtonPressed: Bool,nodeBeingAdded: STMeshNode, elementIndexInNodeElementArray: Int)
}


class NodesElementListViewController: UIViewController {
    
    var nodeAddedToNetwork : STMeshNode!
    var nodesElementAddedToNetwork : NSArray!
    var delegate : NodeElementTableViewControllerDelegate!
    var manager:STMeshManager!
    @IBOutlet weak var tblViewElementList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = STMeshManager.getInstance(self as STMeshManagerDelegate)
        self.title = "Element List"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tblViewElementList.reloadData()
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: Button Selectors
    @IBAction func buttonAllElementAddClicked(_ sender: Any) {
        let unusedNegativeIndex = -1
        self.delegate .configurationButtonClicked(isAllElementConfigButtonPressed: true , nodeBeingAdded: nodeAddedToNetwork , elementIndexInNodeElementArray: unusedNegativeIndex)
    }
}


//MARK: Table View Delegate
extension NodesElementListViewController : UITableViewDataSource , UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodeAddedToNetwork.elementList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ElementListCell", for: indexPath) as! NodeElementTableViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configureCell(element: (nodeAddedToNetwork.elementList[indexPath.row]) as! STMeshElement)
        return cell
    }
}


// MARK: Node Element TableView Cell Delegate
extension NodesElementListViewController: NodeElementTableViewCellDelegate{
    func buttonEachElementAddedClicked(_sender: Any, elementIndexInNodeElementList: Int) {
        //        self .dismiss(animated: true, completion: nil)
        self.delegate .configurationButtonClicked(isAllElementConfigButtonPressed: false , nodeBeingAdded: nodeAddedToNetwork , elementIndexInNodeElementArray: elementIndexInNodeElementList)
    }
}


extension NodesElementListViewController:STMeshManagerDelegate{
    
}

