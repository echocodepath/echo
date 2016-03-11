//
//  AcceptFeedbackRequestViewController.swift
//  Echo
//
//  Created by Andrew Yu on 3/10/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import AVKit
import AVFoundation


class AcceptFeedbackRequestViewController: UIViewController {
    var entry: PFObject?
    let controller = AVPlayerViewController()
    var player: AVPlayer?
    
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry != nil {
            convertVideoDataToNSURL()
        }
    }

    @IBAction func onTogglePlayPause(sender: AnyObject) {
        let playerIsPlaying:Bool = player!.rate > 0
        if (playerIsPlaying) {
            player!.pause();
        } else {
            player!.play();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func bindRecordOptions() {
        recordButton.addTarget(self, action:"handleTouchUp:", forControlEvents: .TouchUpInside)
        recordButton.addTarget(self, action: "handleTouchDown:", forControlEvents: .TouchDown)
    }
    
    func handleTouchUp() {
        //create audio piece and add to table
        //play video
    }
    
    func handleTouchDown() {
        // pause video
        // start recording audio
    }
    
    private func playVideo(url: NSURL){
        controller.showsPlaybackControls = false
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
        player = AVPlayer(URL: url)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
