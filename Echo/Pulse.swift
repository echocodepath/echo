//
//  Pulse.swift
//  Echo
//
//  Created by Christine Hong on 4/3/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import CoreMedia


class Pulse: NSObject {
    var location: CGPoint?
    var time: Double?
    
    init(location: CGPoint, time: Double) {
        self.location = location
        self.time = time
    }
    
}

