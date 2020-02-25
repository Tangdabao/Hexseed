/**
 ******************************************************************************
 * @file    GroupMembersTableViewCell.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    13-Nov-2017
 * @brief   Cell class for GroupMembersTableView.
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

protocol GroupMemberDeleteProtocol{
    func deleteMember(yes: Bool, member: STMeshElement, indexPath:IndexPath)
}
import UIKit

class GroupMembersTableViewCell: UITableViewCell {
    
    var delegate: GroupMemberDeleteProtocol? = nil
    var memberToDelete: STMeshElement!
    @IBOutlet var memberName: UILabel!
    @IBOutlet var deleteMemberButton: UIButton!
    var indexPath:IndexPath?
    var controller:UIViewController?
    @IBAction func memberDelete(_ sender: Any) {
        CommonUtils.showAlertWithOptionMessage(message:"Are sure you want to remove node!.", continueBtnTitle: "Yes", cancelBtnTitle: "No", controller: controller!) { (response) in
            self.delegate?.deleteMember(yes: true, member: self.memberToDelete, indexPath: self.indexPath!)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
    }
    
}

