//
//  Commands.swift
//  ControlTheWorld
//
//  Created by Qiwei Wang on 9/11/19.
//  Copyright © 2019 Qiwei Wang. All rights reserved.
//

import UIKit
import Foundation
class Commands : NSObject{
    var device : String
    var name : String
    var remote : String
    var voice : String
    var command : String
    
    init(device : String, name : String, remote : String, voice : String, command : String) {
        self.device = device
        self.name = name
        self.remote = remote
        self.voice = voice
        self.command = command
    }
}
