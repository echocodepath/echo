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

class FeedbackViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    let videoPlayer = AVPlayerViewController()
    var audioPlayers = Array<AVAudioPlayer>()
    var avPlayer: AVPlayer?
    var timeObserver: AnyObject!
    var audioTimers = Array<NSTimer>()
    var currentIndexPath: NSIndexPath?
    
    var feedback: PFObject?
    var entry: PFObject?
    
    var parseAudioClips: [PFObject] = []
    var audioClips: [AudioClip] = []
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
        loadAudioClips()
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
        playBtn.selected = true
        if let player = try? AVAudioPlayer(contentsOfURL: clip.path!) {
            player.delegate = self
            player.prepareToPlay()
            player.play()
            invalidateTimersAndFeedback()
            clip.hasBeenPlayed = true
            audioPlayers.append(player)
        } else {
            print("Something went wrong")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentIndexPath = indexPath
        let clip = audioClips[indexPath.row]
        playBtn.selected = true
        avPlayer!.seekToTime(CMTimeMakeWithSeconds(clip.offset! + 0.89, 10)) { (completed: Bool) -> Void in
        }
        jumpAndPlayAudio(clip)
    }
    
    func playAudio(timer: NSTimer){
        let clip = timer.userInfo!["clip"] as! AudioClip
        let index = timer.userInfo!["index"] as! Int
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        avPlayer!.pause()
        if let player = try? AVAudioPlayer(contentsOfURL: clip.path!) {
            player.delegate = self
            player.prepareToPlay()
            player.play()
            playBtn.selected = true
            clip.hasBeenPlayed = true
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            currentIndexPath = indexPath
            audioPlayers.append(player)
        } else {
            print("Something went wrong")
        }
    }
    
    func videoDidStartPlayback(withOffset offset: CFTimeInterval) {
        let filteredClips = audioClips.filter({ $0.offset > offset && $0.hasBeenPlayed == false })
        if filteredClips.count > 0 {
            let clipIndex = audioClips.indexOf(filteredClips[0])
            createTimer(filteredClips[0], clipIndex: clipIndex!)
        }
    }
    
    func createTimer(clip: AudioClip, clipIndex: Int) {
        let currentTime = avPlayer!.currentTime().seconds
        let params: [String: NSObject] = ["clip" : clip, "index": clipIndex]
        let playAudioAt = clip.offset! - currentTime
        let timer = NSTimer.scheduledTimerWithTimeInterval(playAudioAt, target: self, selector: "playAudio:", userInfo: params, repeats: false)
        audioTimers.append(timer)
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
        tableView.deselectRowAtIndexPath(currentIndexPath!, animated: true)
        playBtn.selected = false
    }

    func loadAudioClips() {
        let audioClipQuery = PFQuery(className:"AudioClip")
        audioClipQuery.whereKey("feedback_id", equalTo: feedback!)
        
        audioClipQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.parseAudioClips = objects!
                self.createAudioClipDictionary()
                self.convertVideoDataToNSURL()
                self.tableView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
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
            url = FileProcessor.sharedInstance.writeVideoDataToFile(data!)
            self.playVideo(url!)
        })
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
    
    
    func createAudioClipDictionary() {
        parseAudioClips.forEach({ parseObject in
            let audioClipParseObject = parseObject.objectForKey("audioFile") as! PFFile
            let audioClipUrl = convertAudioDataToNSURL(audioClipParseObject)
            let duration = parseObject.objectForKey("duration") as! Float64
            let offset = parseObject.objectForKey("offset") as! Double
            let audioClip = AudioClip(path: audioClipUrl, offset: offset, duration: duration)
            audioClips.append(audioClip)
            
        })
        audioClips = audioClips.sort({ $0.offset < $1.offset })
    }

    override func viewWillDisappear(animated: Bool) {
        self.invalidateTimersAndFeedback()
        self.avPlayer!.pause()
        FileProcessor.sharedInstance.deleteVideoFile()
        self.audioClips.forEach({ clip in
            FileProcessor.sharedInstance.deleteFile(clip.path!)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        timeSlider.value = 0
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
