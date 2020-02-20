//
//  CmdListTableViewCell.swift
//  ControlTheWorld
//
//  Created by Qiwei Wang on 7/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit

class CmdListTableViewCell: UITableViewCell {
    @IBOutlet weak var device: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var voice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
