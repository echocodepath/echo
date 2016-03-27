//
//  DualVideoViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/24/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse

class DualVideoViewController: UIViewController {
    var onComplete: ((finished: Bool) -> Void)?
    
    var studentEntry: PFObject?
    var teacherEntry: PFObject?
    var timeObserver: AnyObject!
    let studentVideoPlayer = AVPlayerViewController()
    let teacherVideoPlayer = AVPlayerViewController()
    var playerRateBeforeSeek: Float = 0
    var studentAvPlayer: AVPlayer?
    var teacherAvPlayer: AVPlayer?
    var studentVideoId: String?
    var teacherVideoId: String?
    
    @IBOutlet weak var studentVideoContainerView: UIView!
    @IBOutlet weak var teacherVideoContainerView: UIView!
    @IBOutlet weak var dualControlView: UIView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVideoControlActions()
        setupButtonToggle()
        timeSlider.value = 0
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        timeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        timeSlider.tintColor = StyleGuide.Colors.echoBrownGray
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if studentEntry != nil && teacherEntry != nil {
            studentVideoId = studentEntry?.objectId
            teacherVideoId = teacherEntry?.objectId
            convertVideosDataToNSURL()
        }
        
        // Just one play button for both av players
        if studentAvPlayer != nil {
            let playerIsPlaying:Bool = studentAvPlayer?.rate > 0
            if playerIsPlaying == true {
            } else {
                playBtn.selected = true
            }
        }
        
    }
    
    private func convertVideosDataToNSURL() {
        var studentUrl: NSURL?
        var teacherUrl: NSURL?
        let studentVideoData = studentEntry!["video"] as! PFFile
        let teacherVideoData = teacherEntry!["video"] as! PFFile
        
        // TODO: Refactor so no nested getDatas
        studentVideoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
            studentUrl = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: self.studentVideoId!)
            teacherVideoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
                teacherUrl = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: self.teacherVideoId!)
                self.playVideos(studentUrl!, teacherUrl: teacherUrl!)
            })
        })
    }
    
    @IBAction func onBack(sender: AnyObject) {
        studentVideoPlayer.player?.pause()
        teacherVideoPlayer.player?.pause()
        
        if let handler = onComplete {
            handler(finished: false)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func videoPlaybackDidPause() {
        studentAvPlayer!.pause();
        teacherAvPlayer!.pause();
    }
    
    @IBAction func onTogglePlayPause(sender: AnyObject) {
        // Just one play button for both av palyers
        let playerIsPlaying:Bool = studentAvPlayer!.rate > 0
        if playerIsPlaying {
            playBtn.selected = true
            videoPlaybackDidPause()
        } else {
            playBtn.selected = false
            studentAvPlayer!.play()
            teacherAvPlayer!.play()
        }
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
        playBtn.setImage(UIImage(named: "white_pause_button"), forState: .Normal)
        playBtn.setImage(UIImage(named: "white_play_button"), forState: .Selected)
    }
    
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        if !timeSlider.tracking {
            timeSlider.value = Float(elapsedTime/duration)
        }
        timeLeftLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = studentAvPlayer!.rate
        studentAvPlayer!.pause()
        teacherAvPlayer!.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(studentAvPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        // Just one play button: use studentAvPlayer to check time
        studentAvPlayer!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
            let playerIsPlaying:Bool = self.studentAvPlayer!.rate > 0
            if (self.playerRateBeforeSeek > 0 && playerIsPlaying == true) {
                self.studentAvPlayer!.play()
                self.teacherAvPlayer!.play()
            }
            self.playBtn.selected = true
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(studentAvPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(studentAvPlayer!.currentItem!.duration);
        if (isfinite(duration)) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    
    private func playVideos(studentUrl: NSURL, teacherUrl: NSURL){
        studentVideoPlayer.showsPlaybackControls = false
        studentVideoPlayer.willMoveToParentViewController(self)
        addChildViewController(studentVideoPlayer)
        studentVideoContainerView.addSubview(studentVideoPlayer.view)
        studentVideoPlayer.didMoveToParentViewController(self)
        studentVideoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        studentVideoPlayer.view.leadingAnchor.constraintEqualToAnchor(studentVideoContainerView.leadingAnchor).active = true
        studentVideoPlayer.view.trailingAnchor.constraintEqualToAnchor(studentVideoContainerView.trailingAnchor).active = true
        studentVideoPlayer.view.topAnchor.constraintEqualToAnchor(studentVideoContainerView.topAnchor).active = true
        studentVideoPlayer.view.bottomAnchor.constraintEqualToAnchor(studentVideoContainerView.bottomAnchor).active = true
        studentAvPlayer = AVPlayer(URL: studentUrl)
        studentVideoPlayer.player = studentAvPlayer!
        studentVideoPlayer.player!.play()
        
        teacherVideoPlayer.showsPlaybackControls = false
        teacherVideoPlayer.willMoveToParentViewController(self)
        addChildViewController(teacherVideoPlayer)
        teacherVideoContainerView.addSubview(teacherVideoPlayer.view)
        teacherVideoPlayer.didMoveToParentViewController(self)
        teacherVideoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        teacherVideoPlayer.view.leadingAnchor.constraintEqualToAnchor(teacherVideoContainerView.leadingAnchor).active = true
        teacherVideoPlayer.view.trailingAnchor.constraintEqualToAnchor(teacherVideoContainerView.trailingAnchor).active = true
        teacherVideoPlayer.view.topAnchor.constraintEqualToAnchor(teacherVideoContainerView.topAnchor).active = true
        teacherVideoPlayer.view.bottomAnchor.constraintEqualToAnchor(teacherVideoContainerView.bottomAnchor).active = true
        teacherAvPlayer = AVPlayer(URL: teacherUrl)
        teacherVideoPlayer.player = teacherAvPlayer!
        teacherVideoPlayer.player!.play()
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = studentAvPlayer!.addPeriodicTimeObserverForInterval(timeInterval,
            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        studentVideoPlayer.player?.pause()
        teacherVideoPlayer.player?.pause()
        if let id = studentVideoId {
            FileProcessor.sharedInstance.deleteVideoFileWithId(id)
        }
        if let id = teacherVideoId {
            FileProcessor.sharedInstance.deleteVideoFileWithId(id)
        }
    }
    
    deinit {
        studentAvPlayer?.removeTimeObserver(timeObserver)
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}