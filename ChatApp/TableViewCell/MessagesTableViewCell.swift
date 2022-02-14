//
//  MessagesTableViewCell.swift
//  ChatApp
//
//  Created by Vanderlei Thome on 14/02/22.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageRightLabel: UILabel!
    
    @IBOutlet weak var messageLeftLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
