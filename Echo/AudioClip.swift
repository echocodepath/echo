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
    var url: NSURL?
    var timestamp: CMTime?
    var duration: Float64?
    
    init(url: NSURL, timestamp: CMTime, duration: Float64 ) {
        self.url = url
        self.timestamp = timestamp
        self.duration = duration
    }
    
}
