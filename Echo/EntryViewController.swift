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
import SnapKit

class EntryViewController: UITableViewController, VideoPlayerContainable {
    
    var onComplete: ((finished: Bool) -> Void)?

    var entry: PFObject?
    var timeObserver: AnyObject!
    let videoPlayer = AVPlayerViewController()
    var playerRateBeforeSeek: Float = 0
    var avPlayer: AVPlayer?
    var videoId: String?
    
    var videoPlayerHeight: Constraint?
    var videoURL: NSURL?
    
    let COMPLIMENTS = ["LOOKIN GOOD!", "WERK!", "YASSS SLAY"]
    
    @IBOutlet weak var inspirationalLabel: UILabel!
    @IBOutlet weak var playerControlView: UISlider!
    @IBOutlet weak var entryHeaderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
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
            self.navigationController?.popViewControllerAnimated(true)
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
        tableView.separatorStyle = .None
//        artistIconImageView.image = UIImage(named: "Artist Icon")
        songIconImageView.image = UIImage(named: "Music Icon")
//        titleIconImageView.image = UIImage(named:"Title Icon")
//        privateSwitch.onTintColor = UIColor(red: 0.7647, green: 0.7647, blue: 0.7647, alpha: 1.0)
        entryHeaderView.backgroundColor = StyleGuide.Colors.echoFormGray
//        playerControlView.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1.0)
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
        super.viewWillAppear(animated)
        if entry != nil {
            videoId = entry?.objectId
            convertVideoDataToNSURL()
        }
        if avPlayer != nil {
            let playerIsPlaying:Bool = avPlayer?.rate > 0
            if playerIsPlaying == true {
            } else {
                playBtn.selected = true
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVideoControlActions()
        setupButtonToggle()
        timeSlider.value = 0
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        timeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        timeSlider.tintColor = StyleGuide.Colors.echoBrownGray
        setupIcons()
        generateRandomCompliment()
        
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension

        
        if entry != nil {
            self.title = "\(entry!.valueForKey("title") as! String)".uppercaseString
            songLabel.text = "\(entry!.valueForKey("song") as! String)"
            artistLabel.text = "\(entry!.valueForKey("artist") as! String)"
//            self.title = DateManager.defaultFormatter.stringFromDate(entry!.createdAt!)
//            titleLabel.text = "\(entry!.valueForKey("title") as! String)"
            if entry!["user_id"] as? String != currentUser?.id{
                requestFeedbackBtn.hidden = true
            }
            
            if entry?.valueForKey("user_id") as? String != currentUser!.id {
                self.navigationController!.navigationItem.rightBarButtonItem = nil
            }
        }
        
    }
    
    func generateRandomCompliment() {
        let maxLength = COMPLIMENTS.count - 1
        let randomIndex = Int(arc4random_uniform(UInt32(maxLength)) + 1)
        let compliment = COMPLIMENTS[randomIndex]
        inspirationalLabel.font = StyleGuide.Fonts.boldFont(size: 40.0)
        inspirationalLabel.text = compliment
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item == 1 {
            return videoPlayerHeight(forWidth: tableView.frame.width)
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
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
    
    
    private func playVideo(url: NSURL){
        tableView.reloadData()
        videoPlayer(addToView: videoContainerView, videoURL: url)
        
        videoPlayer.showsPlaybackControls = false
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
            url = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: self.videoId!)
            self.videoURL = url
            self.playVideo(url!)
        })
    }

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
    
    deinit {
        avPlayer?.removeTimeObserver(timeObserver)

    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "requestFeedback":
                    let vc = segue.destinationViewController  as! FeedbackRequestViewController
                    vc.setFeedbackEntry(self.entry)
                case "allFeedback":
                    let vc = segue.destinationViewController as! EntryFeedbackViewController
                    vc.entry = entry
//                case "dualHome":
//                    let vc = segue.destinationViewController as! DualHomeViewController
//                    vc.studentEntry = entry
                default:
                    return
            }
        }
    }
}
