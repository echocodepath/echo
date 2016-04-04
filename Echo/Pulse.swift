//
//  Pulse.swift
//  Echo
//
//  Created by Christine Hong on 4/3/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import CoreMedia
import Parse

class Pulse: NSObject {
    var location: CGPoint?
    var video_offset: Double?
    var clip_offset: Double?
    var clipNum: Int?
    var clipPointer: PFObject?
    
    init(location: CGPoint, video_offset: Double, clip_offset: Double) {
        self.location = location
        self.video_offset = video_offset
        self.clip_offset = clip_offset
    }
    
}

