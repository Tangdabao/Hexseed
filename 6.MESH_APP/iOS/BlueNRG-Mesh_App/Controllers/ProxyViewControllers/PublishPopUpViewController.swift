/**
 ******************************************************************************
 * @file    PublishPopUpViewController.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    04-Dec-2017
 * @brief   ViewController for "Publish pop-up" View.
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

protocol PublishPopUpViewControllerDelegate{
    func cellSelected(cellName: String, address: UInt16)
}

import UIKit

class PublishPopUpViewController: UIViewController{
    
    var delegate : PublishPopUpViewControllerDelegate? = nil
    var publisherListArray = [AnyObject]()
    var addressArray = [UInt16]()
    var labelValue : String!
    var frame : CGRect!
    var currentNode:STMeshNode?
    var currentNetworkDataManager = NetworkConfigDataManager.sharedInstance
    @IBOutlet var dropDownTable: UITableView!
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<currentNetworkDataManager.currentNetworkData.nodes.count{
            let node = currentNetworkDataManager.currentNetworkData.nodes[i] as! STMeshNode
            publisherListArray.append(node)
            addressArray.append(node.unicastAddress)
        }
        for i in 1..<currentNetworkDataManager.currentNetworkData.groups.count{
            let group = currentNetworkDataManager.currentNetworkData.groups[i] as! STMeshGroup
            publisherListArray.append(group)
            addressArray.append(group.groupAddress)
        }
        dropDownTable.frame = CGRect(x: frame.minX, y: (frame.minY + frame.height + CGFloat(5)), width: frame.width, height: CGFloat((publisherListArray.count * 40) + 10))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Custom method
    func assignPublisherToNode(selectedPublisherIndex:IndexPath){
    }
}


extension PublishPopUpViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publisherListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = dropDownTable.dequeueReusableCell(withIdentifier: "dropDownCell") as! PublishPopUpTableViewCell
        if let node = publisherListArray[indexPath.row] as? STMeshNode{
            cell.publishValue.text = node.nodeName
        }
        if let group = publisherListArray[indexPath.row] as? STMeshGroup{
            cell.publishValue.text = group.groupName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.assignPublisherToNode(selectedPublisherIndex:indexPath)
        self.delegate?.cellSelected(cellName: "0", address: addressArray[indexPath.row] )
        dismiss(animated: true, completion: nil)
    }
}
