//
//  HomeViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import AVKit
import AVFoundation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var inspirationalQuoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var videoContainerView: UIView!

    @IBAction func onTap(sender: AnyObject) {
        if let videoUrl = self.videoUrl{
            playVideo(videoUrl)
        }
    }
    
    
    var controller = AVPlayerViewController()
    
    var videoUrl: NSURL?
    
    override func viewDidAppear(animated: Bool) {
        print("view did appear")
//        convertVideoDataToNSURL()
//        // restart video
//        let seconds : Int64 = 0
//        let preferredTimeScale : Int32 = 1
//        let kCMTimeMake = CMTimeMake(seconds, preferredTimeScale)
//        controller.player!.seekToTime(kCMTimeMake)
//
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.sendSubviewToBack(controller.view)
        self.view.bringSubviewToFront(self.coverImage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coverImage.alpha = 1
        convertVideoDataToNSURL()
        
        self.view.bringSubviewToFront(self.coverImage)
        
        self.navigationController?.navigationBarHidden = true
        let quoteAndAuthor = InspirationGenerator.pickRandomQuote()
        let quote = quoteAndAuthor[0]
        let author = quoteAndAuthor[1]
        
        inspirationalQuoteLabel.text = quote
        authorLabel.text = "- \(author)"
        if currentUser == nil {
            currentUser = User(user: PFUser.currentUser()!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Video
    private func createVideo(url: NSURL){
        
        
        controller.willMoveToParentViewController(self)
        addChildViewController(controller)
        videoContainerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        controller.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        controller.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        controller.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        controller.view.heightAnchor.constraintEqualToAnchor(controller.view.widthAnchor, multiplier: 1, constant: 1)
        
        
        let player = AVPlayer(URL: url)
        controller.player = player
        

        
        
    }
    
    
    // MARK: Video
    private func playVideo(url: NSURL){
        

        controller.willMoveToParentViewController(self)
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        controller.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        controller.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        controller.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        controller.view.heightAnchor.constraintEqualToAnchor(controller.view.widthAnchor, multiplier: 1, constant: 1)
        
        
        let player = AVPlayer(URL: url)
        controller.player = player
        controller.player!.play()
        
        
    }
    
    private func convertVideoDataToNSURL() {
        
        let query = PFQuery(className:"Videos")
        query.getObjectInBackgroundWithId("EX4cigSdlA") {
            (Video: PFObject?, error: NSError?) -> Void in
            if error == nil && Video != nil {
                
                let rawData: NSData?
                let videoData = Video!["video"] as! PFFile
                
                do {
                    rawData = try videoData.getData()
                    self.videoUrl = FileProcessor.sharedInstance.writeVideoDataToFile(rawData!)
                    self.createVideo(self.videoUrl!)
                } catch {
                    
                }
                
            } else {
                print(error)
            }
        }
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        FileProcessor.sharedInstance.deleteVideoFile()
        controller.player!.pause()
    }


}
