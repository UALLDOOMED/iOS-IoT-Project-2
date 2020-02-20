//
//  ScheduledTasks.swift
//  ControlTheWorld
//
//  Created by Kang Meng on 10/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit

class ScheduledTasks: NSObject {
    var id: String
    var command: String
    var device: String
    var status: String
    var timestamp: Date
    
    init(id: String, command: String, device: String, status: String, timestamp: Date) {
        self.id = id
        self.command = command
        self.device = device
        self.status = status
        self.timestamp = timestamp
    }
}
