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
import SnapKit
import Waver

class AcceptFeedbackRequestViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource, VideoPlayerContainable{
    lazy var carousel = CarouselView()
    
    var videoPlayerHeight: Constraint?
    var videoURL: NSURL?
    let videoPlayer = AVPlayerViewController()
    var audioPlayers = Array<AVPlayer>()
    var avPlayer: AVPlayer?
    var feedback: [AudioClip] = []
    var entryDuration: Double?
    var entry: PFObject?
    var request: PFObject?
    var timeObserver: AnyObject!
    var playerRateBeforeSeek: Float = 0
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var fileNumber = 0
    var currentUrl: NSURL?
    var currentIndexPath: NSIndexPath?
    var videoId: String?
    
    var audioTimers = Array<NSTimer>()
    var hiddenEmptyAudioCellView = false
    
    
    
    @IBOutlet weak var audioWaveContainerView: Waver!
    @IBOutlet weak var emptyAudioCellView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var recordContainerView: UIView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioWaveContainerView.backgroundColor = StyleGuide.Colors.echoLightTeal
        
        FeedbackClipTableViewCell.count = 0
        emptyAudioCellView.addSubview(carousel)
        let views = ["carousel" : carousel]
        carousel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[carousel]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[carousel]|", options: [], metrics: nil, views: views))
        
        for index in 1...3 {
            let view = UIImageView(image: UIImage(named: "tut_\(index)"))
            view.contentMode = .ScaleAspectFit
            view.backgroundColor = UIColor(red: 0.1529, green: 0.1529, blue: 0.1765, alpha: 1.0)
            carousel.views.append(view)
        }
        
        
        setupViewProperties()
        setupButtonToggle()
        tableView.delegate = self
        tableView.dataSource = self
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        //        timeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        timeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        timeSlider.tintColor = UIColor.whiteColor()
    }
    
    func videoPlaybackDidUnPause() {
        invalidateTimers()
        audioPlayers.removeAll()
        videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
    }
    
    func setupViewProperties() {
        emptyAudioCellView.backgroundColor = UIColor(red: 39/255, green: 39/255, blue: 45/255, alpha: 1.0)
        timeLeftLabel.textColor = StyleGuide.Colors.echoTranslucentClear
        controlView.backgroundColor = StyleGuide.Colors.echoBrownGray
        tableView.backgroundColor = StyleGuide.Colors.echoLightBrownGray
        recordContainerView.backgroundColor = StyleGuide.Colors.echoBrownGray
        tableView.tableFooterView = UIView()
    }
    
    func setupButtonToggle() {
        playBtn.setImage(UIImage(named: "white_pause_button"), forState: .Normal)
        playBtn.setImage(UIImage(named: "white_play_button"), forState: .Selected)
    }
    
    func videoPlaybackDidPause() {
        avPlayer!.pause();
        invalidateTimersAndFeedback()
    }
    
    func invalidateTimers(){
        audioTimers.forEach({ $0.invalidate() })
    }
    
    func invalidateAudioClips() {
        audioPlayers.forEach({ $0.pause() })
    }
    
    func invalidateTimersAndFeedback() {
        invalidateTimers()
        feedback.forEach({ $0.hasBeenPlayed = false })
    }
    
    func createTimer(clip: AudioClip, clipIndex: Int) {
        let currentTime = avPlayer!.currentTime().seconds
        let params: [String: NSObject] = ["clip" : clip, "index": clipIndex]
        let playAudioAt = clip.offset! - currentTime
        let timer = NSTimer.scheduledTimerWithTimeInterval(playAudioAt, target: self, selector: "playAudio:", userInfo: params, repeats: false)
        audioTimers.append(timer)
    }
    
    var currentPlayerUpdateToken: AnyObject?
    var currentPlayer: AVPlayer?
    func playAudio(timer: NSTimer){
        avPlayer!.pause()
        let params = timer.userInfo as! [String : AnyObject]
        let clip = params["clip"] as! AudioClip
        let index = params["index"] as! Int
        let indexPath = NSIndexPath(forRow: index, inSection: 0)

        let player = AVPlayer(URL: clip.path!)
        player.play()
        playBtn.selected = true
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        currentIndexPath = indexPath
        clip.hasBeenPlayed = true
        audioPlayers.append(player)
        
        currentPlayerUpdateToken = player.addPeriodicTimeObserverForInterval(CMTimeMake(1, 60), queue: dispatch_get_main_queue()) { [weak self] (time) -> Void in
            if let cell = self?.tableView.cellForRowAtIndexPath(indexPath) as? FeedbackClipTableViewCell {
                cell.waveformView.progressTime = time
            }
        }
        
        currentPlayer = player
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioPlaybackDidEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem!)
    }
    
    func audioPlaybackDidEnd(notification: NSNotification) {
        guard let player = currentPlayer else {
            return 
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        player.removeTimeObserver(currentPlayerUpdateToken!)
        
        tableView.deselectRowAtIndexPath(currentIndexPath!, animated: true)
        videoPlayer.player!.play()
        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
        playBtn.selected = false
    }
    
    @IBAction func onTogglePlayPause(sender: AnyObject) {
        let playerIsPlaying:Bool = avPlayer!.rate > 0
        if playerIsPlaying {
            playBtn.selected = true
            videoPlaybackDidPause()
        } else {
            playBtn.selected = false
            avPlayer!.play()
            invalidateTimersAndFeedback()
            videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
            videoPlaybackDidUnPause()
        }
    }
    
    func videoDidStartPlayback(withOffset offset: CFTimeInterval) {
        let filteredClips = feedback.filter({ $0.offset > offset && $0.hasBeenPlayed == false })
        if filteredClips.count > 0 {
            let clipIndex = feedback.indexOf(filteredClips[0])
            createTimer(filteredClips[0], clipIndex: clipIndex!)
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
    
    func jumpAndPlayAudio(clip: AudioClip) {
        avPlayer!.pause()
        let player = AVPlayer(URL: clip.path!)
        player.play()
        clip.hasBeenPlayed = true
        audioPlayers.append(player)
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentIndexPath = indexPath
        let clip = feedback[indexPath.row]
        invalidateTimersAndFeedback()
        avPlayer!.seekToTime(CMTimeMakeWithSeconds(clip.offset! + 0.89, 10)) { (completed: Bool) -> Void in
        }
        jumpAndPlayAudio(clip)
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
        let audioClip = AudioClip(path: currentUrl!, offset: timestamp.seconds, duration: duration)

        audioRecorder.stop()
        audioRecorder = nil
        feedback.append(audioClip)
        fileNumber += 1
        UIView.animateWithDuration(0.3) { () -> Void in
            self.audioWaveContainerView.alpha = 0
        }
        avPlayer!.play()
        if hiddenEmptyAudioCellView == false {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.emptyAudioCellView.alpha = 0
            })
        }
        tableView.reloadData()
    }
    
    func handleTouchDown(sender: AnyObject) {

        UIView.animateWithDuration(0.3) { () -> Void in
            self.audioWaveContainerView.alpha = 1
        }

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
            audioRecorder.meteringEnabled = true
            audioRecorder.record()

            audioWaveContainerView.waverLevelCallback = { [weak self] waver in
                if let recorder = self?.audioRecorder {
                    recorder.updateMeters()
                    let normalizedValue = pow(10, recorder.averagePowerForChannel(0) / 50)
                    waver.level = CGFloat(normalizedValue)
                }
            }
            
        } catch {
        }
        
        avPlayer!.pause()

    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        tableView.deselectRowAtIndexPath(currentIndexPath!, animated: true)
        videoPlayer.player!.play()
        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
        playBtn.selected = false
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
                self.invalidateTimersAndFeedback()
                self.avPlayer!.play()
                self.videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
            }
            self.invalidateTimersAndFeedback()
            self.playBtn.selected = true
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(timeSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    private func playVideo(url: NSURL){
        videoPlayer(addToView: videoContainerView, videoURL: url)
        
        videoPlayer.showsPlaybackControls = false
        avPlayer = AVPlayer(URL: url)
        let playerItem = AVPlayerItem(URL: url)
        avPlayer!.replaceCurrentItemWithPlayerItem(playerItem)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = avPlayer!.addPeriodicTimeObserverForInterval(timeInterval,
            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
                self.observeTime(elapsedTime)
        }
        
        videoPlayer.player = avPlayer
//        videoPlayer.player!.play()
        playBtn.selected = true

        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
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
//    
//    private func convertVideoDataToNSURL() {
//        var url: NSURL?
//        let videoData = entry!["video"] as! PFFile
//        videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
//            url = FileProcessor.sharedInstance.writeVideoDataToFile(data!)
//            self.playVideo(url!)
//        })
//    }
//    
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        if !timeSlider.tracking {
            timeSlider.value = Float(elapsedTime/duration)
        }
        timeLeftLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer!.currentItem!.duration);
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
        self.avPlayer?.pause()
        FileProcessor.sharedInstance.deleteVideoFile()
        self.feedback.forEach({ clip in
            FileProcessor.sharedInstance.deleteFile(clip.path!)
        })
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedback.count
    }
    
    @IBAction func onSaveFeedback(sender: AnyObject) {
        var paramDict: [String: NSObject] = Dictionary<String, NSObject>()
        paramDict["teacher_id"] = PFUser.currentUser()
        paramDict["entry_id"] = entry!
        paramDict["user_id"] = entry!.objectForKey("user_id") as! String
        paramDict["teacher_username"] = currentUser?.username

        ParseClient.sharedInstance.createFeedbackWithCompletion(paramDict) { (feedback, error) -> () in
            self.feedback.forEach { clip in
                var params = Dictionary<String, NSObject>()
                let audioData = NSData(contentsOfURL: clip.path!)
                let audioFile = PFFile(name: "AudioClip.mp4", data: audioData!)
                let duration = clip.duration
                let offset = clip.offset
                params["feedback_id"] = feedback
                params["audioFile"] = audioFile
                params["duration"] = duration
                params["offset"] = offset
                
                
                ParseClient.sharedInstance.createAudioClipWithCompletion(params){ (audioClip, error) -> () in                     FileProcessor.sharedInstance.deleteFile(clip.path!)
                }
            }
            self.markAccepted()
        }
    }
    
    func markAccepted() {
        request!["accepted"] = "true"
        request?.saveInBackground()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.player?.pause()
        if let id = videoId {
            FileProcessor.sharedInstance.deleteVideoFileWithId(id)
        }
        audioPlayers.forEach({ $0.pause() })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if entry != nil {
            timeSlider.value = 0.0
            videoId = entry!.objectId
            convertVideoDataToNSURL()
            bindRecordOptions()
            startRecordingSession()
        }
        if avPlayer != nil {
            let playerIsPlaying:Bool = avPlayer?.rate > 0
            if playerIsPlaying == true {
            } else {
                playBtn.selected = true
            }
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
                case "SaveFeedbackReceiptSegue":
                let destinationvc = segue.destinationViewController as! FeedbackSendReceiptViewController
                let username = entry?.valueForKey("username")
                destinationvc.studentName = username! as? String
                default:
                    return
            }
        }
    }
    

}
