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


class AcceptFeedbackRequestViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    var entry: PFObject?
    let controller = AVPlayerViewController()
    var player: AVPlayer?
    var timeObserver: AnyObject!
    var playerRateBeforeSeek: Float = 0
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var fileNumber = 0
    var audioClips: [AudioClip] = []
    var currentUrl: NSURL?
    var timer = NSTimer()
    var currentAudioLength: Double = 0.0
    
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if entry != nil {
            timeSlider.value = 0.0
            convertVideoDataToNSURL()
            bindRecordOptions()
            startRecordingSession()
        }
        tableView.delegate = self
        tableView.dataSource = self
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
        currentUrl = documentDirectory.URLByAppendingPathComponent("sound\(fileNumber).m4a")
        
        return currentUrl
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
        let timestamp = player!.currentTime()
        let audioClip = AudioClip(url: currentUrl!, timestamp: timestamp, duration: currentAudioLength)
        audioRecorder.stop()
        timer.invalidate()
        audioRecorder = nil
        audioClips.append(audioClip)
        fileNumber += 1
        player!.play()
        tableView.reloadData()
        
    }
    
    func updateTimer() {
        currentAudioLength += 1
    }
    
    func handleTouchDown(sender: AnyObject) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)

        
        let audioURL = directoryURL()
        
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
        controller.view.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedbackClipTableViewCell") as! FeedbackClipTableViewCell
        let audioClip = audioClips[indexPath.row]
        cell.audioClip = audioClip
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioClips.count
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
