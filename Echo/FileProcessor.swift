//
//  FileProcessor.swift
//  Echo
//
//  Created by Isis Anchalee on 3/10/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class FileProcessor: NSObject {
    class var sharedInstance: FileProcessor {
        struct Static {
            static let instance =  FileProcessor()
        }
        return Static.instance
    }
    
    func writeVideoDataToFile(data: NSData) -> NSURL {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documents as NSString).stringByAppendingPathComponent("sweet-dance-moves.mov")
        let url = NSURL(fileURLWithPath: path)
        do {
            data.writeToURL(url, atomically: true)
        } catch {
        
        }
        return url
    }
}