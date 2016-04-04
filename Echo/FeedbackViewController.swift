//
//  FeedbackViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/15/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Parse
import SnapKit
import PulsingHalo

class FeedbackViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource, VideoPlayerContainable {
    var videoPlayerHeight: Constraint?
    var videoURL: NSURL?
    
    let videoPlayer = AVPlayerViewController()
    var audioPlayers = Array<AVPlayer>()
    var avPlayer: AVPlayer?
    var timeObserver: AnyObject!
    var audioTimers = Array<NSTimer>()
    var currentIndexPath: NSIndexPath?
    var videoId: String?
    
    var feedback: PFObject?
    var entry: PFObject?
    
    var parseAudioClips: [PFObject] = []
    var parsePulses: [PFObject] = []
    var audioClips: [AudioClip] = []
    var pulses: [Pulse] = []
    var fileNumber = 0
    var currentUrl: NSURL?
    var audioUrls:[NSURL] = []
    var playerRateBeforeSeek: Float = 0

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FeedbackClipTableViewCell.count = 0

        bindGestures()
        setupViewProperties()
        setupButtonToggle()
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = 1
        timeSlider.continuous = true
        timeSlider.setThumbImage(UIImage(named: "slider_thumb"), forState: .Normal)
        timeSlider.tintColor = UIColor.whiteColor()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func setupViewProperties() {
        controlView.backgroundColor = StyleGuide.Colors.echoBrownGray
        tableView.backgroundColor = StyleGuide.Colors.echoLightBrownGray
        tableView.tableFooterView = UIView()
    }
    
    func setupButtonToggle() {
        playBtn.setImage(UIImage(named: "white_pause_button"), forState: .Normal)
        playBtn.setImage(UIImage(named: "white_play_button"), forState: .Selected)
    }
    
    func videoPlaybackDidPause() {
        avPlayer!.pause();
        invalidateTimers()
    }
    
    func invalidateTimers(){
        audioTimers.forEach({ $0.invalidate() })
    }
    
    func videoPlaybackDidUnPause() {
        invalidateTimers()
        audioPlayers.removeAll()
        videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
    }
    
    func invalidateTimersAndFeedback() {
        invalidateTimers()
        audioClips.forEach({ $0.hasBeenPlayed = false })
    }
    
    @IBAction func onBack(sender: AnyObject) {
        //dismissViewControllerAnimated(true) { () -> Void in
//            self.invalidateTimersAndFeedback()
//            self.avPlayer!.pause()
//            FileProcessor.sharedInstance.deleteVideoFile()
//            self.audioClips.forEach({ clip in
//                FileProcessor.sharedInstance.deleteFile(clip.path!)
//            })
        //}
        
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
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
    
    func jumpAndPlayAudio(clip: AudioClip) {
        avPlayer!.pause()
        let player = AVPlayer(URL: clip.path!)
        player.play()
        clip.hasBeenPlayed = true
        audioPlayers.append(player)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentIndexPath = indexPath
        let clip = audioClips[indexPath.row]
        playBtn.selected = true
        avPlayer!.seekToTime(CMTimeMakeWithSeconds(clip.offset! + 0.89, 10)) { (completed: Bool) -> Void in
        }
        jumpAndPlayAudio(clip)
    }
    
    var currentPlayerUpdateToken: AnyObject?
    var currentPlayer: AVPlayer?

    func createPulseTimers(clip: AudioClip) {
        let pulses = clip.pulses
        for pulse in pulses {
            let params: [String: NSObject] = ["pulse" : pulse]
            let showPulseAt = pulse.clip_offset
            NSTimer.scheduledTimerWithTimeInterval(showPulseAt!, target: self, selector: #selector(FeedbackViewController.showPulse(_:)), userInfo: params, repeats: false)
        }
    }

    func showPulse(timer: NSTimer) {
        let dict = timer.userInfo! as! NSDictionary
        let pulse = dict["pulse"] as! Pulse
        let position = pulse.location

        //show pulse
        let halo = PulsingHaloLayer()
        halo.repeatCount = 0
        halo.position = position!
        view.layer.addSublayer(halo)
    }

    func createTimer(clip: AudioClip, clipIndex: Int) {
        let currentTime = avPlayer!.currentTime().seconds
        let params: [String: NSObject] = ["clip" : clip, "index": clipIndex]
        let playAudioAt = clip.offset! - currentTime
        let timer = NSTimer.scheduledTimerWithTimeInterval(playAudioAt, target: self, selector: #selector(FeedbackViewController.playAudio(_:)), userInfo: params, repeats: false)
        audioTimers.append(timer)
    }

    func playAudio(timer: NSTimer){
        let dict = timer.userInfo! as! NSDictionary
        let clip = dict["clip"] as! AudioClip
        let index = dict["index"] as! Int
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        avPlayer!.pause()
        let player = AVPlayer(URL: clip.path!)
        createPulseTimers(clip)
        player.play()

        playBtn.selected = true
        clip.hasBeenPlayed = true
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        currentIndexPath = indexPath
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
        
        tableView.deselectRowAtIndexPath(currentIndexPath!, animated: false)
        videoPlayer.player!.play()
        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
        playBtn.selected = false
    }
    
    func videoDidStartPlayback(withOffset offset: CFTimeInterval) {
        let filteredClips = audioClips.filter({ $0.offset > offset && $0.hasBeenPlayed == false })
        if filteredClips.count > 0 {
            let clipIndex = audioClips.indexOf(filteredClips[0])
            createTimer(filteredClips[0], clipIndex: clipIndex!)
        }
    }
    
    func bindGestures() {
        timeSlider.addTarget(self, action: "sliderBeganTracking:",
            forControlEvents: UIControlEvents.TouchDown)
        timeSlider.addTarget(self, action: "sliderEndedTracking:",
            forControlEvents: [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside])
        timeSlider.addTarget(self, action: "sliderValueChanged:",
            forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        videoPlayer.player?.play()
        videoDidStartPlayback(withOffset: avPlayer!.currentTime().seconds)
        tableView.deselectRowAtIndexPath(currentIndexPath!, animated: false)
        playBtn.selected = false
    }

    func loadAudioClips() {
        let audioClipQuery = PFQuery(className:"AudioClip")
        audioClipQuery.whereKey("feedback_id", equalTo: feedback!)
        audioClipQuery.orderByAscending("offset")
        
//        audioClipQuery.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            if error == nil {
//                self.parseAudioClips = objects!
//            } else {
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
        do {
            let data = try audioClipQuery.findObjects()
            self.parseAudioClips = data
        }
        catch {
            print("Error: \(error)")
        }
    }

    func loadPulses() {
        let pulseQuery = PFQuery(className:"Pulse")
        pulseQuery.whereKey("feedback_id", equalTo: feedback!)
        pulseQuery.orderByAscending("video_offset")
        
//        pulseQuery.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            if error == nil {
//                self.parsePulses = objects!
//            } else {
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
        do {
            let data = try pulseQuery.findObjects()
            self.parsePulses = data
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    func getAudioFilePath() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        currentUrl = documentDirectory.URLByAppendingPathComponent("feedback-clip-\(fileNumber).m4a")
        fileNumber += 1
        return currentUrl
    }
    
    private func convertVideoDataToNSURL() {
        var url: NSURL?
        let videoData = entry!["video"] as! PFFile
        
        videoData.getDataInBackgroundWithBlock({ (data, error) -> Void in
            url = FileProcessor.sharedInstance.writeVideoDataToFileWithId(data!, id: self.videoId!)
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
                self.invalidateTimersAndFeedback()
                self.videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
            }
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
        videoPlayer.player!.play()
        self.videoDidStartPlayback(withOffset: self.avPlayer!.currentTime().seconds)
    }
    
    private func updateTimeLabel(elapsedTime elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = elapsedTime
        if !timeSlider.tracking {
            timeSlider.value = Float(elapsedTime/duration)
            print(elapsedTime/duration)
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
    
    private func convertAudioDataToNSURL(audioClip: PFFile) -> NSURL {
        let url: NSURL = getAudioFilePath()!
        audioClip.getDataInBackgroundWithBlock { (data, error) -> Void in
            FileProcessor.sharedInstance.writeAudioDataToFile(data!, path: url)
        }
        return url

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioClips.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedbackClipTableViewCell") as! FeedbackClipTableViewCell
        let audioClip = audioClips[indexPath.row]
        cell.audioClip = audioClip
        return cell
    }

    func createPulseDictionary() {
        //parsePulses = parsePulses.sort({ $0.objectForKey("video_offset") as! Double < $1.objectForKey("video_offset") as! Double})
        parsePulses.forEach({ parseObject in
            let video_offset = parseObject.objectForKey("video_offset") as! Double
            let clip_offset = parseObject.objectForKey("clip_offset") as! Double
            let locationX = parseObject.objectForKey("locationX") as! Double
            let locationY = parseObject.objectForKey("locationY") as! Double
            let position = CGPoint(x: locationX, y: locationY)
            //let audioClipPointer = parseObject.objectForKey("audioclip_id") as! PFObject

            let pulse = Pulse(location: position, video_offset: video_offset, clip_offset: clip_offset)
            //pulse.clipPointer = audioClipPointer
            pulses.append(pulse)
        })
    }
    
    func createAudioClipDictionary() {
        //parseAudioClips = parseAudioClips.sort({ $0.objectForKey("offset") as! Double < $1.objectForKey("offset") as! Double})
        parseAudioClips.forEach({ parseObject in
            let audioClipParseObject = parseObject.objectForKey("audioFile") as! PFFile
            let audioClipUrl = convertAudioDataToNSURL(audioClipParseObject)
            let duration = parseObject.objectForKey("duration") as! Float64
            let offset = parseObject.objectForKey("offset") as! Double
            let audioClip = AudioClip(path: audioClipUrl, offset: offset, duration: duration)
            var audioClipPulses: [Pulse] = []
            while pulses.count > 0 && pulses[0].video_offset == offset {
                audioClipPulses.append(pulses[0])
                pulses.removeAtIndex(0)
            }
            audioClip.pulses = audioClipPulses
            audioClips.append(audioClip)
        })
        //audioClips = audioClips.sort({ $0.offset < $1.offset })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.invalidateTimersAndFeedback()
        self.avPlayer?.pause()
        if entry != nil {
            let videoData = entry!["video"] as! PFFile
            videoData.cancel()
        }
        if let id = videoId {
            FileProcessor.sharedInstance.deleteVideoFileWithId(id)
        }
        self.audioClips.forEach({ clip in
            FileProcessor.sharedInstance.deleteFile(clip.path!)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        timeSlider.value = 0
        videoId = entry?.objectId
        
        let queue = NSOperationQueue()
        
        let op1 = NSBlockOperation {
            self.loadAudioClips()
        }
        
        let op2 = NSBlockOperation {
            self.loadPulses()
        }
        
        let finish = NSBlockOperation {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                // The ops have finished
                self.createPulseDictionary()
                self.createAudioClipDictionary()
                self.convertVideoDataToNSURL()
                self.tableView.reloadData()
                
                if self.avPlayer != nil {
                    let playerIsPlaying:Bool = self.avPlayer?.rate > 0
                    if playerIsPlaying == true {
                    } else {
                        self.playBtn.selected = true
                    }
                }
            })
        }
        
        finish.addDependency(op1)
        finish.addDependency(op2)
        
        queue.addOperations([op1, op2, finish], waitUntilFinished: false)
    }
    
    deinit {
        avPlayer?.removeTimeObserver(timeObserver)
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
