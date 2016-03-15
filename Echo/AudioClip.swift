//
//  AudioClip.swift
//  Echo
//
//  Created by Isis Anchalee on 3/12/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import CoreMedia


class AudioClip: NSObject {
    var path: NSURL?
    var timestamp: CMTime?
    var duration: Float64?
    var offset: Double?
    var hasBeenPlayed: Bool = false
    
    init(path: NSURL, timestamp: CMTime, duration: Float64 ) {
        self.path = path
        self.timestamp = timestamp
        self.duration = duration
        self.offset = timestamp.seconds
        print("duration!! \(duration)")
        print(path)
    }
    
}
