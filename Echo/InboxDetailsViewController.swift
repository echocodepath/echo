//
//  InboxDetailsViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/8/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AFNetworking
import AVKit
import AVFoundation

class InboxDetailsViewController: UIViewController {
    var request : PFObject?
    var entry : PFObject?
    var userId: String? // id of user who sent request
    var controller: AVPlayerViewController?
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var videoTitleView: UIView!
    @IBOutlet weak var messageWrapperView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var requestBodyLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var videoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        usernameLabel.textColor = StyleGuide.Colors.echoTeal
        self.view.backgroundColor = StyleGuide.Colors.echoFormGray
        messageWrapperView.backgroundColor = UIColor(patternImage: UIImage(named:"speechbubble")!)


//        messageWrapperView.layer.borderWidth = 1
//        messageWrapperView.layer.borderColor = StyleGuide.Colors.echoBorderGray.CGColor
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.userImageView.layer.cornerRadius = self.userImageView.frame.height/2
            self.userImageView.clipsToBounds = true
        })
        
        if request != nil {
            self.entry = request?.objectForKey("entry") as? PFObject
            self.requestBodyLabel.text = request?.objectForKey("request_body") as? String
            self.setEntryLabels()
        }
    }
    
    func setEntryLabels() {
        entry?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.entry = object
                self.convertVideoDataToNSURL()
                self.titleLabel.text = self.entry?.objectForKey("title") as? String
                self.userId = self.entry?.objectForKey("user_id") as? String
                self.createdAtLabel.text = DateManager.getFriendlyTime(self.entry?.createdAt)
                self.setUserLabels()
            }
        })
    }
    
    func setUserLabels(){
        let query = PFUser.query()!
        query.getObjectInBackgroundWithId(self.userId!) {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error == nil && userObject != nil {
                let user = userObject as! PFUser
                self.usernameLabel.text = user["username"] as? String
                self.locationLabel.text = user["location"] as? String
                let profUrl = user["profilePhotoUrl"] as? String
                self.userImageView.setImageWithURL(NSURL(string: profUrl!)!)
            } else {
                print(error)
            }
        }
    }
    
    // MARK: Video
    private func playVideo(url: NSURL){
        controller = AVPlayerViewController()
        controller!.willMoveToParentViewController(self)
        addChildViewController(controller!)
        videoContainerView.addSubview(controller!.view)
        controller!.didMoveToParentViewController(self)
        controller!.view.translatesAutoresizingMaskIntoConstraints = false
        controller!.view.leadingAnchor.constraintEqualToAnchor(videoContainerView.leadingAnchor).active = true
        controller!.view.trailingAnchor.constraintEqualToAnchor(videoContainerView.trailingAnchor).active = true
        controller!.view.topAnchor.constraintEqualToAnchor(videoContainerView.topAnchor).active = true
        controller!.view.bottomAnchor.constraintEqualToAnchor(videoContainerView.bottomAnchor).active = true
        
        let player = AVPlayer(URL: url)
        controller!.player = player
        controller!.player!.play()
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func convertVideoDataToNSURL() {
        let url: NSURL?
        let rawData: NSData?
        let videoData = self.entry!["video"] as! PFFile
        do {
            rawData = try videoData.getData()
            url = FileProcessor.sharedInstance.writeVideoDataToFile(rawData!)
            playVideo(url!)
        } catch {
            
        }
    }

    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: add rejected request for user
    @IBAction func onReject(sender: AnyObject) {
        request!["rejected"] = "true"
        request?.saveInBackground()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onAccept() {
        request!["accepted"] = "true"
        request?.saveInBackground()
    }
    
//    // MARK: sets current feedback request
//    func setFeedbackRequest(request: PFObject?) {
//        self.request = request
//    }
//    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        controller?.player?.pause()
        FileProcessor.sharedInstance.deleteVideoFile()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "AcceptFeedbackSegue":
                    let navController = segue.destinationViewController as! UINavigationController
                    let acceptFeedbackRequestViewController = navController.topViewController as! AcceptFeedbackRequestViewController
                    acceptFeedbackRequestViewController.entry = self.entry
                    onAccept()

                default:
                    return
            }
        }
        
    }

}
