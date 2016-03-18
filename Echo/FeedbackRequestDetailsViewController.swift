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

class FeedbackRequestDetailsViewController: UIViewController, UITextViewDelegate {
    let MESSAGE_PLACEHOLDER = "Add a message for instructor"
    
    var entry: PFObject?
    var teacher: PFObject?
    var currentUser: PFUser?
    
    var controller: AVPlayerViewController?
    
    @IBOutlet weak var songLabel: UILabel!
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
        do {
            try currentUser!.fetch()
        } catch {
        }
        
        if entry != nil {
            entryLabel.text = "\(entry!.valueForKey("title") as! String)"
            songLabel.text = "\(entry!.valueForKey("song") as! String)"
            convertVideoDataToNSURL()
        }
        
        if teacher != nil {
            teacherLabel.text = teacher!["username"] as? String
            teacherLabel.textColor = StyleGuide.Colors.echoTeal
        }
        
        //text view styling and make text view editable
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = borderColor.CGColor
        messageTextView.layer.cornerRadius = 5.0
        messageTextView.delegate = self
        applyPlaceholderStyle(self.messageTextView, placeholderText: MESSAGE_PLACEHOLDER)
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
    
    // MARK: Text View
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == messageTextView && textView.text == MESSAGE_PLACEHOLDER
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: MESSAGE_PLACEHOLDER)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == messageTextView && aTextView.text == MESSAGE_PLACEHOLDER
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
    }

    
    
    // MARK: Video
    private func playVideo(url: NSURL){

        controller = AVPlayerViewController()
        controller!.willMoveToParentViewController(self)
        addChildViewController(controller!)
        view.addSubview(controller!.view)
        controller!.didMoveToParentViewController(self)
        controller!.view.translatesAutoresizingMaskIntoConstraints = false
        controller!.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        controller!.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        controller!.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        controller!.view.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        controller!.view.heightAnchor.constraintEqualToAnchor(controller!.view.widthAnchor, multiplier: 1, constant: 1)
        

        
        let player = AVPlayer(URL: url)
        controller!.player = player
        controller!.player!.play()
        
        
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
    
    
    // MARK: send feedback request
    func sendFeedbackRequest(teacher: PFObject) {
        var request: [String: String]! = Dictionary<String,String>()
        
        request["entry_id"] = self.entry?.objectId
        request["request_body"] = self.messageTextView.text
        let teacherId = teacher.objectId! as String
        request["teacher_id"] = teacherId
        request["user_id"] = currentUser!.objectId! as String
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
        
        // add to requests_received array for selected teacher
        let query = PFUser.query()!
        query.getObjectInBackgroundWithId(teacherId) {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error == nil && userObject != nil {
                let teacher = userObject as! PFUser
                if let requests_received = teacher["requests_received"] {
                    var array = requests_received as! Array<Dictionary<String,String>>
                    array.append(request)
                    teacher["requests_received"] = array
                } else {
                    let array = [request]
                    teacher["requests_received"] = array
                }
                teacher.saveInBackground()
            } else {
                print(error)
            }
        }
//        query.whereKey("facebook_id", equalTo: teacherId!)
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                if let objects = objects {
//                    for object in objects {
//                        let teacher = object as! PFUser
//                        if let requests_received = teacher["requests_received"] {
//                            var array = requests_received as! Array<Dictionary<String,String>>
//                            array.append(request)
//                            teacher["requests_received"] = array
//                        } else {
//                            let array = [request]
//                            teacher["requests_received"] = array
//                        }
//                        teacher.saveInBackground()
//                    }
//                }
//            } else {
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "feedbackSentSegue":
                    let vc = segue.destinationViewController as! FeedbackRequestSentViewController
                    vc.setTeacher(self.teacher!)
                    controller!.player!.pause()
                    sendFeedbackRequest(self.teacher!)
                    
                default:
                    return
            }
        }
    }
    

}
