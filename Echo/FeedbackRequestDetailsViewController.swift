//
//  FeedbackRequestDetailsViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/11/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AVKit
import AVFoundation

class FeedbackRequestDetailsViewController: UIViewController {
    var entry: PFObject?
    var teacher: PFObject?
    var currentUser: PFUser?
    
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!

    @IBAction func clickedSendFeedback(sender: AnyObject) {
        performSegueWithIdentifier("feedbackSentSegue", sender: nil)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()
        
        if entry != nil {
            entryLabel.text = "\(entry!.valueForKey("title") as! String) \nSong: \(entry!.valueForKey("song") as! String)"
            convertVideoDataToNSURL()
        }
        
        if teacher != nil {
            teacherLabel.text = teacher!["username"] as? String
        }
    }
    
    func updateEntry(entry: PFObject) {
        self.entry = entry
    }
    
    func updateTeacher(teacher: PFObject) {
        self.teacher = teacher
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func sendFeedbackRequest(teacher: PFObject) {
        var request: [String: String]! = Dictionary<String,String>()
        
        request["entry_id"] = self.entry?.objectId
        request["request_body"] = "Hi please help me"
        let teacherId = teacher["facebook_id"] as? String
        request["teacher_id"] = teacherId
        request["user_id"] = currentUser!["facebook_id"] as? String
        request["accepted"] = "false"
        request["resolved"] = "false"
        
        // add to requests_sent array for current user
        if let requests_sent = currentUser!["requests_sent"] {
            var array = requests_sent as! Array<Dictionary<String,String>>
            array.append(request)
            currentUser!["requests_sent"] = array
        } else {
            let array = [request]
            currentUser!["requests_sent"] = array
        }
        currentUser!.saveInBackground()
        
        // add to requests_received array for current user
        let query = PFUser.query()!
        query.whereKey("facebook_id", equalTo: teacherId!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let teacher = object as! PFUser
                        if let requests_received = teacher["requests_received"] {
                            var array = requests_received as! Array<Dictionary<String,String>>
                            array.append(request)
                            teacher["requests_received"] = array
                        } else {
                            let array = [request]
                            teacher["requests_received"] = array
                        }
                        teacher.saveInBackground()
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "feedbackSentSegue":
                    let vc = segue.destinationViewController as! FeedbackRequestSentViewController
                    vc.setTeacher(self.teacher!)
                    sendFeedbackRequest(self.teacher!)
                    
                default:
                    return
            }
        }
    }
    

}
