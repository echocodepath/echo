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
import SnapKit

class FeedbackRequestDetailsViewController: UITableViewController, UITextViewDelegate, VideoPlayerContainable {
    var videoPlayerHeight: Constraint?
    var videoURL: NSURL?
    var videoPlayer = AVPlayerViewController()
    var playerRateBeforeSeek: Float = 0
    var avPlayer: AVPlayer?
    var timeObserver: AnyObject!

    let MESSAGE_PLACEHOLDER = "Add a message for instructor"
    
    var entry: PFObject?
    var teacher: PFUser?
    var videoId: String?
    
    
    @IBOutlet weak var messageWrapperView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var formBackgroundView: UIView!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var teacherAvatar: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artistIconImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    
    @IBAction func onTogglePlayPause(sender: AnyObject) {
        let playerIsPlaying:Bool = avPlayer!.rate > 0
        if playerIsPlaying {
            playBtn.selected = true
            avPlayer!.pause();
        } else {
            playBtn.selected = false
            avPlayer!.play()
        }
    }
    
    func setupIcons() {
        view.backgroundColor = StyleGuide.Colors.echoFormGray
        tableView.separatorStyle = .None
        artistIconImageView.image = UIImage(named: "Music Icon")
    }
    
    func setupButtonToggle() {
        playBtn.setImage(UIImage(named: "pause_button"), forState: .Normal)
        playBtn.setImage(UIImage(named: "white_play_button"), forState: .Selected)
    }
    
    func bindVideoControlActions() {
        
        timeSlider.addTarget(self, action: "sliderBeganTracking:",
            forControlEvents: UIControlEvents.TouchDown)
        timeSlider.addTarget(self, action: "sliderEndedTracking:",
            forControlEvents: [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside])
        timeSlider.addTarget(self, action: "sliderValueChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
    }
    
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        if !timeSlider.tracking {
            timeSlider.value = Float(elapsedTime/duration)
        }
        timeAgoLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer!.rate
        avPlayer!.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        
        avPlayer!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
            let playerIsPlaying:Bool = self.avPlayer!.rate > 0
            if (self.playerRateBeforeSeek > 0 && playerIsPlaying == true) {
                self.avPlayer!.play()
            }
            self.playBtn.selected = true
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer!.currentItem!.duration);
        if (isfinite(duration)) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }

    
    @IBAction func clickSendFeedback(sender: AnyObject) {
        if messageTextView.text == MESSAGE_PLACEHOLDER{
            messageTextView.text = "Student did not write anything"
        }
        //performSegueWithIdentifier("feedbackSentSegue", sender: nil)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item == 1 {
            return videoPlayerHeight(forWidth: tableView.frame.width)
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVideoControlActions()
        setupButtonToggle()
        timeSlider.value = 0
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        timeSlider.setThumbImage(UIImage(named: "grey_slider_thumb"), forState: .Normal)
        timeSlider.tintColor = StyleGuide.Colors.echoBlue
        setupIcons()

        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        artistIconImageView.image = UIImage(named: "Music Icon")
        if entry != nil {
            self.entryLabel.text = "\(entry!.valueForKey("title") as! String)"
            self.songLabel.text = "\(entry!.valueForKey("song") as! String)"
            self.artistLabel.text = "\(entry!.valueForKey("artist") as! String)"
        }
        
        if teacher != nil {
            teacher?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                self.teacher = object as? PFUser
                self.teacherLabel.text = self.teacher!["username"] as? String
                self.teacherLabel.textColor = StyleGuide.Colors.echoBlue
                
                let url  = NSURL(string: (self.teacher?.objectForKey("profilePhotoUrl") as? String)!)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.teacherAvatar.setImageWithURL(url!)
                    self.teacherAvatar.layer.cornerRadius = self.teacherAvatar.frame.height/2
                    self.teacherAvatar.clipsToBounds = true
                })
            })
        }
        
        formBackgroundView.backgroundColor = StyleGuide.Colors.echoFormGray
        messageWrapperView.layer.cornerRadius = 10.0
        messageWrapperView.clipsToBounds = true
        messageTextView.delegate = self
        

        
        applyPlaceholderStyle(self.messageTextView, placeholderText: MESSAGE_PLACEHOLDER)
    }
    
    func updateEntry(entry: PFObject) {
        self.entry = entry
    }
    
    func updateTeacher(teacher: PFUser) {
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
        videoPlayer(addToView: videoContainerView, videoURL: url)
        
        let player = AVPlayer(URL: url)
        videoPlayer.player = player
        videoPlayer.showsPlaybackControls = false

        avPlayer = player
        videoPlayer.player!.play()
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        
        timeObserver = avPlayer!.addPeriodicTimeObserverForInterval(timeInterval,
            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
        }
    }
    
    private func convertVideoDataToNSURL() {
        var url: NSURL?
        let videoData = entry!["video"] as! PFFile
        
        videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
            url = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: self.videoId!)
            self.videoURL = url
            self.tableView.reloadData()
            self.playVideo(url!)
        })
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
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let id = videoId {
            FileProcessor.sharedInstance.deleteVideoFileWithId(id)
        }
        videoPlayer.player?.pause()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if entry != nil {
            self.videoId = entry!.objectId
            convertVideoDataToNSURL()
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
                    videoPlayer.player?.pause()
                    sendFeedbackRequest()
                    
                default:
                    return
            }
        }
    }
    

}
