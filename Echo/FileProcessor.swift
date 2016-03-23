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
    
    func writeVideoDataToFileWithId(data: NSData, id: String) -> NSURL {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documents as NSString).stringByAppendingPathComponent("sweet-dance-moves-\(id).mov")
        let url = NSURL(fileURLWithPath: path)
        do {
            try data.writeToURL(url, atomically: true)
        } catch {
            print("error writing data to url")
        }
        return url
    }
    
    
    func writeVideoDataToFile(data: NSData) -> NSURL {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documents as NSString).stringByAppendingPathComponent("sweet-dance-moves.mov")
        deleteFile(NSURL(fileURLWithPath: path))
        let url = NSURL(fileURLWithPath: path)
        do {
            try data.writeToURL(url, atomically: true)
        } catch {
            print("error writing data to url")
        }
        return url
    }
    
    func writeAudioDataToFile(data: NSData, path: NSURL) -> NSURL {
        do {
            try data.writeToURL(path, atomically: true)
        } catch {
            print("error writing data to url")
        }
        return path
    }
    
    func deleteVideoFileWithId(id: String) {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documents as NSString).stringByAppendingPathComponent("sweet-dance-moves-\(id).mov")
        let filemgr = NSFileManager.defaultManager()
        do {
            try filemgr.removeItemAtPath(path)
            print("Remove successful")
        } catch {
            print("Remove unsuccessful")
        }
    }
    
    
    func deleteFile(path: NSURL) {
        let filemgr = NSFileManager.defaultManager()
        do {
            try filemgr.removeItemAtPath(path.path!)
            print("Remove successful")
        } catch {
            print("Remove unsuccessful")
        }
    }
    
    func deleteVideoFile() {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = (documents as NSString).stringByAppendingPathComponent("sweet-dance-moves.mov")
        let filemgr = NSFileManager.defaultManager()
        do {
            try filemgr.removeItemAtPath(path)
            print("Remove successful")
        } catch {
            print("Remove unsuccessful")
        }
    }
}