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
import SnapKit
class InboxDetailsViewController: UITableViewController, VideoPlayerContainable {
    var videoPlayerHeight: Constraint?
    var videoURL: NSURL?
    var videoPlayer = AVPlayerViewController()
    var avPlayer: AVPlayer?
    var playerRateBeforeSeek: Float = 0

    var timeObserver: AnyObject!
    var request : PFObject?
    var entry : PFObject?
    var userId: String? // id of user who sent request
    var controller: AVPlayerViewController?
    var videoId: String?
    
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songIconImageView: UIImageView!
    
    @IBOutlet weak var semanticTimeAgoLabel: UILabel!

    @IBOutlet weak var messageBodyView: UIView!
    @IBOutlet weak var videoTitleView: UIView!
    @IBOutlet weak var messageWrapperView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var requestBodyLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var wouldLikeFeedbackLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var wordTimeAgoLabel: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    
    func setupFonts() {
        authorLabel.font = StyleGuide.Fonts.mediumFont(size: 15)
        wouldLikeFeedbackLabel.font = StyleGuide.Fonts.mediumFont(size: 12)
        requestBodyLabel.font = StyleGuide.Fonts.mediumFont(size: 12)
        semanticTimeAgoLabel.font = StyleGuide.Fonts.mediumFont(size: 10)
        semanticTimeAgoLabel.textColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 76/100, alpha: 1.0)
        self.songLabel.alpha = 0
        self.artistLabel.alpha = 0
        self.usernameLabel.alpha = 0
        self.wouldLikeFeedbackLabel.alpha = 0
        self.requestBodyLabel.alpha = 0
        self.byLabel.alpha = 0
        self.wordTimeAgoLabel.alpha = 0
    }
    
    func setupViewElements() {
        messageBodyView.layer.cornerRadius = 10.0
        messageBodyView.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        songIconImageView.image = UIImage(named: "Music Icon")
        bindVideoControlActions()
        setupButtonToggle()
        timeSlider.value = 0
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        timeSlider.setThumbImage(UIImage(named: "grey_slider_thumb"), forState: .Normal)
        timeSlider.tintColor = StyleGuide.Colors.echoBlue
        setupIcons()
        setupFonts()
        setupViewElements()
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        usernameLabel.textColor = StyleGuide.Colors.echoBlue
        messageView.backgroundColor = StyleGuide.Colors.echoFormGray
        view.backgroundColor = StyleGuide.Colors.echoFormGray

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
        tableView.separatorStyle = .None
        songIconImageView.image = UIImage(named: "Music Icon")
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
    

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        if !timeSlider.tracking {
            timeSlider.value = Float(elapsedTime/duration)
        }
        timeAgoLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    func setEntryLabels() {
        entry?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.entry = object
                self.videoId = self.entry?.objectId
                self.convertVideoDataToNSURL()
                self.userId = self.entry?.objectForKey("user_id") as? String
                self.songLabel.text = "\(self.entry!.valueForKey("song") as! String)"
                self.titleLabel.text = self.entry!.valueForKey("title") as! String
                self.artistLabel.text = "\(self.entry!.valueForKey("artist") as! String)"
                self.title = DateManager.getFriendlyTime(self.entry?.createdAt)
                self.setUserLabels()
            }
        })
    }
    
    func bindVideoControlActions() {
        
        timeSlider.addTarget(self, action: "sliderBeganTracking:",
            forControlEvents: UIControlEvents.TouchDown)
        timeSlider.addTarget(self, action: "sliderEndedTracking:",
            forControlEvents: [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside])
        timeSlider.addTarget(self, action: "sliderValueChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func setupButtonToggle() {
        playBtn.setImage(UIImage(named: "pause_button"), forState: .Normal)
        playBtn.setImage(UIImage(named: "white_play_button"), forState: .Selected)
    }
    
    
    
    func setUserLabels(){
        let query = PFUser.query()!
        query.getObjectInBackgroundWithId(self.userId!) {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error == nil && userObject != nil {
                
                let user = userObject as! PFUser
                self.usernameLabel.text = user["username"] as? String
                let profUrl = user["profilePhotoUrl"] as? String
                self.userImageView.setImageWithURL(NSURL(string: profUrl!)!)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.songLabel.alpha = 1
                    self.artistLabel.alpha = 1
                    self.usernameLabel.alpha = 1
                    self.titleLabel.alpha = 1
                    self.wouldLikeFeedbackLabel.alpha = 1
                    self.requestBodyLabel.alpha = 1
                    self.byLabel.alpha = 1
                    self.wordTimeAgoLabel.alpha = 1
                })
            } else {
                print(error)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item == 1 {
            return videoPlayerHeight(forWidth: tableView.frame.width)
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
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
        timeObserver = player.addPeriodicTimeObserverForInterval(timeInterval,
            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
    
//    private func convertVideoDataToNSURL() {
//        var url: NSURL?
//        let videoData = entry!["video"] as! PFFile
//        videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
//            url = FileProcessor.sharedInstance.writeVideoDataToFile(data!)
//            self.playVideo(url!)
//        })
//    }

    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: add rejected request for user
    @IBAction func onReject(sender: AnyObject) {
        request!["rejected"] = "true"
        request?.saveInBackground()
        self.navigationController?.popViewControllerAnimated(true)
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
        super.viewWillDisappear(animated)
        videoPlayer.player?.pause()
        if let id = videoId {
            FileProcessor.sharedInstance.deleteVideoFileWithId(id)
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    deinit {
        videoPlayer.player?.removeTimeObserver(timeObserver)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "AcceptFeedbackSegue":
                    let acceptFeedbackRequestViewController = segue.destinationViewController as! AcceptFeedbackRequestViewController
                    
                    acceptFeedbackRequestViewController.entry = self.entry
                    acceptFeedbackRequestViewController.request = self.request

                default:
                    return
            }
        }
        
    }

}
