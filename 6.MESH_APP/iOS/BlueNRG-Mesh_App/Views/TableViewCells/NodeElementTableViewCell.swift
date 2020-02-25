/**
 ******************************************************************************
 * @file    NodeElementTableViewCell.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.00.000
 * @date    13-Mar-2018
 * @brief   ViewCell class for NodeElement Table.
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
protocol NodeElementTableViewCellDelegate {
    func buttonEachElementAddedClicked(_sender: Any ,elementIndexInNodeElementList: Int) -> Void
}

class NodeElementTableViewCell: UITableViewCell {
    var delegate : NodeElementTableViewCellDelegate!
    var indexPath : IndexPath!
    @IBOutlet weak var lblElementName: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    /*MARK: Life Cycle Method */
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /*MARK: Custom Function */
    /* Configure cell data */
    func configureCell(element:STMeshElement) -> Void {
        self.lblElementName.text = element.elementName
        if (element.subscribedGroups.count != 0 || element.publishTarget != nil){
            self.btnAdd.isHidden = true;
        }
    }
    
    
    // Mark: Button Selectors
    @IBAction func buttonEachElementAddClicked(_ sender: Any) {
        delegate.buttonEachElementAddedClicked(_sender: sender , elementIndexInNodeElementList:indexPath.row)
    }
}
