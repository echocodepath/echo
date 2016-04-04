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
    var duration: Float64?
    var offset: Double?
    var hasBeenPlayed: Bool = false
    var pulses: [Pulse] = []
    
    init(path: NSURL, offset: Double, duration: Float64 ) {
        self.path = path
        self.offset = offset
        self.duration = duration
    }
    
}
