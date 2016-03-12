//
//  AcceptFeedbackRequestViewController.swift
//  Echo
//
//  Created by Andrew Yu on 3/10/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import AVKit
import AVFoundation


class AcceptFeedbackRequestViewController: UIViewController, AVAudioRecorderDelegate {
    var entry: PFObject?
    let controller = AVPlayerViewController()
    var player: AVPlayer?
    var timeObserver: AnyObject!
    var playerRateBeforeSeek: Float = 0
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry != nil {
            timeSlider.value = 0.0
            convertVideoDataToNSURL()
            bindRecordOptions()
            startRecordingSession()
        }
        
    }

    @IBAction func onTogglePlayPause(sender: AnyObject) {
        let playerIsPlaying:Bool = player!.rate > 0
        if (playerIsPlaying) {
            player!.pause();
        } else {
            player!.play();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {

                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        debugPrint(soundURL)
        
        return soundURL
    }
    
    
    func bindRecordOptions() {
        recordButton.addTarget(self, action:"handleTouchUp:", forControlEvents: .TouchUpInside)
        recordButton.addTarget(self, action: "handleTouchDown:", forControlEvents: .TouchDown)
        
        timeSlider.addTarget(self, action: "sliderBeganTracking:",
            forControlEvents: UIControlEvents.TouchDown)
        timeSlider.addTarget(self, action: "sliderEndedTracking:",
            forControlEvents: [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside])
        timeSlider.addTarget(self, action: "sliderValueChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleTouchUp(sender: AnyObject) {
        audioRecorder.stop()
        audioRecorder = nil
        player!.play()
    }
    
    func handleTouchDown(sender: AnyObject) {
        let audioURL = directoryURL()
        print("URL!!!! \(audioURL)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("recording!!")
        } catch {
        }
        
        player!.pause()

    }
    
    func sliderBeganTracking(slider: UISlider) {
        print("sliderBeganTracking")
        playerRateBeforeSeek = player!.rate
        player!.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        print("sliderEndedTracking")
        let videoDuration = CMTimeGetSeconds(player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        player!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.player!.play()
            }
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        print("sliderValueChanged")
        let videoDuration = CMTimeGetSeconds(player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    private func playVideo(url: NSURL){
        controller.showsPlaybackControls = false
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
        player = AVPlayer(URL: url)
        let playerItem = AVPlayerItem(URL: url)
        player!.replaceCurrentItemWithPlayerItem(playerItem)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = player!.addPeriodicTimeObserverForInterval(timeInterval,
            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
        }
        
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
    
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        timeSlider.value = Float(elapsedTime/100)
        timeLeftLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(player!.currentItem!.duration);
        if (isfinite(duration)) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    deinit {
        player!.removeTimeObserver(timeObserver)
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
