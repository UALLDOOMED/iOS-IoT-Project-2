//
//  ScheduledTasksTableViewCell.swift
//  ControlTheWorld
//
//  Created by Kang Meng on 10/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit

class ScheduledTasksTableViewCell: UITableViewCell {
    @IBOutlet weak var commandLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
