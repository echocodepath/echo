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
    
    var onComplete: ((finished: Bool) -> Void)?
    
    var entry: PFObject?
    
    let videoPlayer = AVPlayerViewController()

    @IBOutlet weak var requestFeedbackBtn: UIButton!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var feedbackIcon: UINavigationItem!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBAction func onBack(sender: AnyObject) {
        videoPlayer.player!.pause()
        
        if let handler = onComplete {
            handler(finished: false)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func updateEntry(myEntry: PFObject?) {
        self.entry = myEntry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry != nil {
            self.title = entry!.valueForKey("title") as! String
//            entryLabel.text = "\(entry!.valueForKey("title") as! String)"
            songLabel.text = "\(entry!.valueForKey("song") as! String)"
            artistLabel.text = "by \(entry!.valueForKey("artist") as! String)"
            createdAtLabel.text = DateManager.defaultFormatter.stringFromDate(entry!.createdAt!)
            if entry!["user_id"] as? String != currentUser?.id{
                requestFeedbackBtn.hidden = true
            }
            
            convertVideoDataToNSURL()
            
            if entry?.valueForKey("user_id") as! String != currentUser!.id {
                self.navigationController!.navigationItem.rightBarButtonItem = nil
            }
        }
        
    }
    
    private func playVideo(url: NSURL){
        videoPlayer.willMoveToParentViewController(self)
        addChildViewController(videoPlayer)
        view.addSubview(videoPlayer.view)
        videoPlayer.didMoveToParentViewController(self)
        videoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        videoPlayer.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        videoPlayer.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        videoPlayer.view.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        videoPlayer.view.heightAnchor.constraintEqualToAnchor(videoPlayer.view.widthAnchor, multiplier: 1, constant: 1)
        let player = AVPlayer(URL: url)
        videoPlayer.player = player
        videoPlayer.player!.play()
    }
    
    private func convertVideoDataToNSURL() {
        var url: NSURL?
        let videoData = entry!["video"] as! PFFile
        videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
            url = FileProcessor.sharedInstance.writeVideoDataToFile(data!)
            self.playVideo(url!)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            videoPlayer.player?.pause()
            FileProcessor.sharedInstance.deleteVideoFile()
            switch identifier {
                case "requestFeedback":
                    let nc = segue.destinationViewController as! UINavigationController
                    let vc = nc.topViewController as! FeedbackRequestViewController
                    vc.setFeedbackEntry(self.entry)
                case "allFeedback":
                    let vc = segue.destinationViewController as! EntryFeedbackViewController
                    vc.entry = entry
                default:
                    return
            }
        }
    }
}
