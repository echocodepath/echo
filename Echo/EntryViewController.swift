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
    var timeObserver: AnyObject!
    let videoPlayer = AVPlayerViewController()
    var playerRateBeforeSeek: Float = 0
    var avPlayer: AVPlayer?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var requestFeedbackBtn: UIButton!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var feedbackIcon: UINavigationItem!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var titleIconImageView: UIImageView!
    
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var artistIconImageView: UIImageView!
    @IBOutlet weak var songIconImageView: UIImageView!
    @IBAction func onBack(sender: AnyObject) {
        videoPlayer.player?.pause()
        
        if let handler = onComplete {
            handler(finished: false)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func videoPlaybackDidPause() {
        avPlayer!.pause();
    }
    
    @IBAction func onTogglePlayPause(sender: AnyObject) {
        let playerIsPlaying:Bool = avPlayer!.rate > 0
        if playerIsPlaying {
            playBtn.selected = true
            videoPlaybackDidPause()
        } else {
            playBtn.selected = false
            avPlayer!.play()
        }
    }
    
    func setupIcons() {
        artistIconImageView.image = UIImage(named: "Artist Icon")
        songIconImageView.image = UIImage(named: "Music Icon")
        titleIconImageView.image = UIImage(named:"Title Icon")
        privateSwitch.onTintColor = UIColor(red: 0.7647, green: 0.7647, blue: 0.7647, alpha: 1.0)
    }
    
    func bindVideoControlActions() {
        timeSlider.addTarget(self, action: "sliderBeganTracking:",
            forControlEvents: UIControlEvents.TouchDown)
        timeSlider.addTarget(self, action: "sliderEndedTracking:",
            forControlEvents: [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside])
        timeSlider.addTarget(self, action: "sliderValueChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func updateEntry(myEntry: PFObject?) {
        self.entry = myEntry
    }
    
    func setupButtonToggle() {
        playBtn.setImage(UIImage(named: "white_pause_button"), forState: .Normal)
        playBtn.setImage(UIImage(named: "white_play_button"), forState: .Selected)
    }
    
    override func viewWillAppear(animated: Bool) {
        timeSlider.value = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        bindVideoControlActions()
        setupButtonToggle()
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        timeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        timeSlider.tintColor = StyleGuide.Colors.echoBrownGray
        setupIcons()
        
        if entry != nil {
            self.title = "\(entry!.valueForKey("title") as! String)".uppercaseString
            songLabel.text = "\(entry!.valueForKey("song") as! String)"
            artistLabel.text = "\(entry!.valueForKey("artist") as! String)"
            createdAtLabel.text = DateManager.defaultFormatter.stringFromDate(entry!.createdAt!)
            titleLabel.text = "\(entry!.valueForKey("title") as! String)"
            if entry!["user_id"] as? String != currentUser?.id{
                requestFeedbackBtn.hidden = true
            }
            
            convertVideoDataToNSURL()
            
            if entry?.valueForKey("user_id") as? String != currentUser!.id {
                self.navigationController!.navigationItem.rightBarButtonItem = nil
            }
        }
        
    }

    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        if !timeSlider.tracking {
            timeSlider.value = Float(elapsedTime/duration)
        }
        timeAgoLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        print("dismiss keyboard invoked")
        view.endEditing(true)
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
    
    
    private func playVideo(url: NSURL){
        videoPlayer.showsPlaybackControls = false
        videoPlayer.willMoveToParentViewController(self)
        addChildViewController(videoPlayer)
        videoContainerView.addSubview(videoPlayer.view)
        videoPlayer.didMoveToParentViewController(self)
        videoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.view.leadingAnchor.constraintEqualToAnchor(videoContainerView.leadingAnchor).active = true
        videoPlayer.view.trailingAnchor.constraintEqualToAnchor(videoContainerView.trailingAnchor).active = true
        videoPlayer.view.topAnchor.constraintEqualToAnchor(videoContainerView.topAnchor).active = true
        videoPlayer.view.bottomAnchor.constraintEqualToAnchor(videoContainerView.bottomAnchor).active = true
        avPlayer = AVPlayer(URL: url)
        videoPlayer.player = avPlayer!
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
            url = FileProcessor.sharedInstance.writeVideoDataToFile(data!)
            self.playVideo(url!)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        avPlayer?.removeTimeObserver(timeObserver)

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
