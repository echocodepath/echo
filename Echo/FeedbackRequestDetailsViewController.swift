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
    
    var controller: AVPlayerViewController?
    
    @IBOutlet weak var formBackgroundView: UIView!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var teacherAvatar: UIImageView!
    
    
    @IBAction func clickSendFeedback(sender: AnyObject) {
        if messageTextView.text == MESSAGE_PLACEHOLDER{
            messageTextView.text = "Student did not write anything"
        }
        //performSegueWithIdentifier("feedbackSentSegue", sender: nil)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        if entry != nil {
            entryLabel.text = "\(entry!.valueForKey("song") as! String) - \(entry!.valueForKey("title") as! String)"
            convertVideoDataToNSURL()
        }
        
        if teacher != nil {
            teacherLabel.text = teacher!["username"] as? String
            teacherLabel.textColor = StyleGuide.Colors.echoTeal

            let url  = NSURL(string: (teacher?.objectForKey("profilePhotoUrl") as? String)!)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.teacherAvatar.setImageWithURL(url!)
                self.teacherAvatar.layer.cornerRadius = self.teacherAvatar.frame.height/2
                self.teacherAvatar.clipsToBounds = true
            })
            
        }
        
        formBackgroundView.backgroundColor = StyleGuide.Colors.echoFormGray
        //text view styling and make text view editable
        messageTextView.layer.borderWidth = 1
        messageTextView.layer.borderColor = StyleGuide.Colors.echoBorderGray.CGColor
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
    func textViewDidEndEditing(textView: UITextView) {
        
    }
    
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
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        controller!.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
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
    func sendFeedbackRequest() {
        var request: [String: NSObject] = Dictionary<String, NSObject>()
        
        request["entry"] = self.entry
        request["entry_name"] = self.entry!["title"] as! String
        request["teacher"] = self.teacher
        request["teacherId"] = self.teacher?.objectId
        request["teacher_name"] = self.teacher!["username"] as! String
        request["teacher_picture"] = self.teacher!["profilePhotoUrl"] as! String
        request["user"] = currentPfUser
        request["userId"] = currentPfUser?.objectId
        request["user_name"] = currentPfUser!["username"] as! String
        request["user_picture"] = currentPfUser!["profilePhotoUrl"] as! String
        request["request_body"] = self.messageTextView.text
        request["accepted"] = "false"
        request["resolved"] = "false"
        request["rejected"] = "false"
        
        ParseClient.sharedInstance.createFeedbackRequestWithCompletion(request) { (feedbackRequest, error) -> () in
            print("Yay saved feedback!")
//            // add to requests_sent array for current user
//            if let requests_sent = self.currentUser!["requests_sent"] {
//                var array = requests_sent as! Array<PFObject>
//                array.append(feedbackRequest!)
//               self.currentUser!["requests_sent"] = array
//            } else {
//                let array = [feedbackRequest!] as Array<PFObject>
//                self.currentUser!["requests_sent"] = array
//            }
//            self.currentUser!.saveInBackground()
//            
//            // add to requests_received array for selected teacher
//            if let requests_received = self.teacher!["requests_received"] {
//                var array = requests_received as! Array<PFObject>
//                array.append(feedbackRequest!)
//                self.teacher!["requests_received"] = array
//            } else {
//                let array = [feedbackRequest!] as Array<PFObject>
//                self.teacher!["requests_received"] = array
//            }
//            self.teacher!.saveInBackground()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
//            videoPlayer.player?.pause()
//            FileProcessor.sharedInstance.deleteVideoFile()
            switch identifier {
                case "feedbackSentSegue":
                    let vc = segue.destinationViewController as! FeedbackRequestSentViewController
                    vc.setTeacher(self.teacher!)
                    controller!.player!.pause()
                    sendFeedbackRequest()
                    
                default:
                    return
            }
        }
    }
    

}
