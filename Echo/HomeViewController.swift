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

class HomeViewController: UIViewController, VideoPlayerContainable {
    
    @IBOutlet weak var inspirationalQuoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var videoContainerView: UIView!

    @IBAction func onTap(sender: AnyObject) {
        if let videoUrl = self.videoURL{
            self.view.bringSubviewToFront(videoPlayer.view)
            playVideo(videoUrl)
        }
    }
    
    let videoPlayer = AVPlayerViewController()
    var videoURL: NSURL?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        videoContainerView.sendSubviewToBack(videoPlayer.view)
        videoContainerView.bringSubviewToFront(self.coverImage)
        convertVideoDataToNSURL()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        self.coverImage.alpha = 1
        
        self.view.bringSubviewToFront(self.coverImage)
        
        self.navigationController?.navigationBarHidden = true
        let quoteAndAuthor = InspirationGenerator.pickRandomQuote()
        let quote = quoteAndAuthor[0]
        let author = quoteAndAuthor[1]
        
        inspirationalQuoteLabel.font = StyleGuide.Fonts.regularFont(size: 14.0)
        inspirationalQuoteLabel.text = quote
        authorLabel.text = "- \(author)"
        authorLabel.font = StyleGuide.Fonts.mediumFont(size: 14.0)

        if currentUser == nil {
            currentUser = User(user: PFUser.currentUser()!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    private func playVideo(url: NSURL){
//        
//        controller.willMoveToParentViewController(self)
//        addChildViewController(controller)
//        view.addSubview(controller.view)
//        controller.didMoveToParentViewController(self)
//        controller.view.translatesAutoresizingMaskIntoConstraints = false
//        controller.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
//        controller.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
//        controller.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
//        controller.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
//        controller.view.heightAnchor.constraintEqualToAnchor(controller.view.widthAnchor, multiplier: 1, constant: 1)
//        
//        let player = AVPlayer(URL: url)
//        controller.player = player
//        controller.player!.play()
//        
//        
//    }
//    
    // MARK: Video
    private func playVideo(url: NSURL){
        videoPlayer(addToView: videoContainerView, videoURL: url)
        
        let player = AVPlayer(URL: url)
        videoPlayer.player = player
        videoPlayer.player!.play()
        
        
    }
    
    private func convertVideoDataToNSURL() {
        
        let query = PFQuery(className:"Videos")
        query.getObjectInBackgroundWithId("FLajZA8B6W") {
            (Video: PFObject?, error: NSError?) -> Void in
            if error == nil && Video != nil {
                let videoData = Video!["video"] as! PFFile
                videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    self.videoURL = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: "FLajZA8B6W")
                })
                
            } else {
                print(error)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        FileProcessor.sharedInstance.deleteVideoFileWithId("FLajZA8B6W")
        videoPlayer.player?.pause()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
