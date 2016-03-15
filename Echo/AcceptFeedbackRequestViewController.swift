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


class AcceptFeedbackRequestViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    enum State {
        case None, Playing, Paused, Rewinding
    }
    
    var state: State = .None
    let videoPlayer = AVPlayerViewController()
    var audioPlayers = Array<AVAudioPlayer>()
    var avPlayer: AVPlayer?
    var feedback: [AudioClip] = []
    var entryDuration: Double?
    var entry: PFObject?
    var timeObserver: AnyObject!
    var playerRateBeforeSeek: Float = 0
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var fileNumber = 0
    var currentUrl: NSURL?
    
    
    var audioTimers = Array<NSTimer>()

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
    
    func videoPlaybackDidUnPause() {
        audioTimers.forEach({ $0.invalidate() })
        audioPlayers.removeAll()
        videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
    }
    
    func videoPlaybackDidPause() {
        avPlayer!.pause();

    }
    
    func videoDidRewind() {
        invalidateTimers()
    }
    
    func invalidateTimers() {
        audioTimers.forEach({ $0.invalidate() })
        feedback.map({ $0.hasBeenPlayed = false })
    }
    
    func createTimer(clip: AudioClip) {
        clip.hasBeenPlayed = true
        let currentTime = avPlayer!.currentTime().seconds
        let params: [String: AudioClip] = ["clip" : clip]
        let playAudioAt = clip.offset! - currentTime
        let timer = NSTimer.scheduledTimerWithTimeInterval(playAudioAt, target: self, selector: "playAudio:", userInfo: params, repeats: false)
        audioTimers.append(timer)
    }
    

    func playAudio(timer: NSTimer){
        let clip = timer.userInfo!["clip"] as! AudioClip
        avPlayer!.pause()
        if let player = try? AVAudioPlayer(contentsOfURL: clip.path!) {
            player.delegate = self
            player.prepareToPlay()
            player.play()
            audioPlayers.append(player)
        } else {
            print("Something went wrong")
        }
    }
    
    
    @IBAction func onTogglePlayPause(sender: AnyObject) {
        let playerIsPlaying:Bool = avPlayer!.rate > 0
        if playerIsPlaying {
            videoPlaybackDidPause()
        } else {
            avPlayer!.play()
            videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
            videoPlaybackDidUnPause()
        }
    }
    
    func videoDidStartPlayback(withOffset offset: CFTimeInterval) {
        let filteredClips = feedback.filter({ $0.offset > offset && $0.hasBeenPlayed == false })
        if filteredClips.count > 0 {
            createTimer(filteredClips[0])
        }
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
        currentUrl = documentDirectory.URLByAppendingPathComponent("feedback-clip-\(fileNumber).m4a")
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
        let timestamp = avPlayer!.currentTime()
        let duration = audioRecorder.currentTime
        let audioClip = AudioClip(path: currentUrl!, timestamp: timestamp, duration: duration)
        audioRecorder.stop()
        audioRecorder = nil
        feedback.append(audioClip)
        fileNumber += 1
        avPlayer!.play()
        tableView.reloadData()
    }
    
    func handleTouchDown(sender: AnyObject) {
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
        
        avPlayer!.pause()

    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        videoPlayer.player!.play()
        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
    }

    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer!.rate
        avPlayer!.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        state = .Rewinding
        let videoDuration = CMTimeGetSeconds(avPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        

        avPlayer!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.avPlayer!.play()
                print("offset!!! \(self.avPlayer!.currentTime().seconds)")
                self.videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
            }
        }
        videoDidRewind()
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    private func playVideo(url: NSURL){
        videoPlayer.showsPlaybackControls = false
        videoPlayer.willMoveToParentViewController(self)
        addChildViewController(videoPlayer)
        view.addSubview(videoPlayer.view)
        videoPlayer.didMoveToParentViewController(self)
        videoPlayer.view.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        videoPlayer.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        videoPlayer.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        videoPlayer.view.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor).active = true
        videoPlayer.view.heightAnchor.constraintEqualToAnchor(videoPlayer.view.widthAnchor, multiplier: 1, constant: 1)
        avPlayer = AVPlayer(URL: url)
        let playerItem = AVPlayerItem(URL: url)
        avPlayer!.replaceCurrentItemWithPlayerItem(playerItem)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = avPlayer!.addPeriodicTimeObserverForInterval(timeInterval,
            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
        }
        
        videoPlayer.player = avPlayer
        videoPlayer.player!.play()
        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
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
        let duration = CMTimeGetSeconds(avPlayer!.currentItem!.duration);
        timeSlider.maximumValue = Float(duration/100)
        if (isfinite(duration)) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedbackClipTableViewCell") as! FeedbackClipTableViewCell
        let audioClip = feedback[indexPath.row]
        cell.audioClip = audioClip
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedback.count
    }
    
    deinit {
        avPlayer!.removeTimeObserver(timeObserver)
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
