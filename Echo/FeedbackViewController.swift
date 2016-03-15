//
//  FeedbackViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/15/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse

class FeedbackViewController: UIViewController {
    var feedback: PFObject?
    var parseAudioClips: [PFObject] = []
    var audioClips: [AudioClip] = []
    var fileNumber = 0
    var currentUrl: NSURL?
    var audioUrls:[NSURL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAudioClips()
        // Do any additional setup after loading the view.
    }
    
    func loadAudioClips() {
        let audioClipQuery = PFQuery(className:"AudioClip")
        audioClipQuery.whereKey("feedback_id", equalTo: feedback!)
        
        audioClipQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.parseAudioClips = objects!
                self.createAudioClipDictionary()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func getAudioFilePath() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        currentUrl = documentDirectory.URLByAppendingPathComponent("feedback-clip-\(fileNumber).m4a")
        fileNumber += 1
        return currentUrl
    }

    private func convertVideoDataToNSURL(audioClip: PFFile) -> NSURL {
        var url: NSURL = getAudioFilePath()!
        let rawData: NSData?
        do {
            rawData = try audioClip.getData()
            url = FileProcessor.sharedInstance.writeAudioDataToFile(rawData!, path: url)
        } catch {
            
        }
        return url
    }
    
    func createAudioClipDictionary() {
        parseAudioClips.forEach({ parseObject in
            let audioClipParseObject = parseObject.objectForKey("audioFile") as! PFFile
            let audioClipUrl = convertVideoDataToNSURL(audioClipParseObject)
            let duration = parseObject.objectForKey("duration") as! Float64
            let offset = parseObject.objectForKey("offset") as! Double

            let audioClip = AudioClip(path: audioClipUrl, offset: offset, duration: duration)
            audioClips.append(audioClip)
            
        })
        print(audioClips)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
