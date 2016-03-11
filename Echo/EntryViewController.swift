//
//  EntryViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/6/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import AVKit
import AVFoundation


class EntryViewController: UIViewController {
    var entry: PFObject?
    
    
    @IBOutlet weak var entryLabel: UILabel!
    
    
    func updateEntry(myEntry: PFObject?) {
        self.entry = myEntry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry != nil {
            entryLabel.text = "\(entry!.valueForKey("title") as! String) \nSong: \(entry!.valueForKey("song") as! String)"
        }
        convertVideoDataToNSURL()
    }
//    private func playVideo(url: NSURL){
//        let player = AVPlayer(URL: url)
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        self.presentViewController(playerController, animated: true) {
//            player.play()
//        }
//    }
    
    private func playVideo(url: NSURL){
        let controller = AVPlayerViewController()
        controller.willMoveToParentViewController(self)
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        controller.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        controller.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        controller.view.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        controller.view.heightAnchor.constraintEqualToAnchor(controller.view.widthAnchor, multiplier: 1, constant: 1)
        let player = AVPlayer(URL: url)
        controller.player = player
        controller.player!.play()
    }
    
    private func convertVideoDataToNSURL() {
        let url: NSURL?
        let rawData: NSData?
        let videoData = entry!["video"] as! PFFile
        do {
            rawData = try videoData.getData()
            url = FileProcessor.sharedInstance.writeVideoDataToFile(rawData!)
            playVideo(url!)
        } catch {
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "requestFeedback":
                    let vc = segue.destinationViewController as! FeedbackRequestViewController
                    vc.setFeedbackEntry(self.entry)
                
                default:
                    return
            }
        }
    }
}
