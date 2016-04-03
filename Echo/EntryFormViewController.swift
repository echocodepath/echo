//
//  EntryFormViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Parse

class EntryFormViewController: UITableViewController, VideoPlayerContainable {
    var video: NSURL?
    var thumbnail: NSData?
    
    var videoURL: NSURL?
    let videoPlayer = AVPlayerViewController()
    var playerRateBeforeSeek: Float = 0
    var avPlayer: AVPlayer?

    
    @IBOutlet weak var videoPlayerContainer: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var entryThumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var songTextField: UITextField!
    
    @IBOutlet weak var artistIconImageView: UIImageView!
    @IBOutlet weak var songIconImageView: UIImageView!
    @IBOutlet weak var titleIconImageView: UIImageView!
    @IBOutlet weak var artistTextField: UITextField!
    @IBAction func onCancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func generateThumbnail(){
        let asset = AVURLAsset(URL: video!, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        var uiImage: UIImage?
        do {
            let cgImage = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            uiImage = UIImage(CGImage: cgImage)
        } catch {
            uiImage = UIImage(named: "sea-otter")
        }
        entryThumbnailImageView.image = uiImage
        thumbnail = UIImagePNGRepresentation(uiImage!)
    }
    
    private func playVideo(url: NSURL){
        tableView.reloadData()
        videoPlayer(addToView: videoPlayerContainer, videoURL: url)
        
//        videoPlayer.showsPlaybackControls = false
        avPlayer = AVPlayer(URL: url)
        videoPlayer.player = avPlayer!
        videoPlayer.player!.play()
//        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
//        timeObserver = avPlayer!.addPeriodicTimeObserverForInterval(timeInterval,
//            queue: dispatch_get_main_queue()) { (elapsedTime: CMTime) -> Void in
//                self.observeTime(elapsedTime)
//        }
    }
    
    func setupIcons() {
        tableView.tableFooterView = UIView()
        artistIconImageView.image = UIImage(named: "Artist Icon")
        songIconImageView.image = UIImage(named: "Music Icon")
        titleIconImageView.image = UIImage(named:"Title Icon")
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
         dismissKeyboard()
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func onEntrySave(sender: AnyObject) {
        LoadingOverlay.shared.showOverlay(self.view)
        saveButton.enabled = false
        let user_id = currentUser!.id
        let username =  currentUser!.username
        let title = titleTextField.text
        let song = songTextField.text
        var responseDict: [String: NSObject] = Dictionary<String,NSObject>()
        let videoData = NSData(contentsOfURL: video!)
        let videoFile = PFFile(name: "Entry.mov", data: videoData!)
        let thumbnailFile = PFFile(name: "Thumbnail.png", data: thumbnail!)
        
        responseDict["username"] = username
        responseDict["user_id"] = user_id
        responseDict["title"] = title
        responseDict["song"] = song
        responseDict["video"] = videoFile
        responseDict["thumbnail"] = thumbnailFile
        responseDict["artist"] = artistTextField.text
        if privateSwitch.on {
            responseDict["private"] = true
        } else {
            responseDict["private"] = false
        }
        
        ParseClient.sharedInstance.createEntryWithCompletion(responseDict) { (entry, error) -> () in
            let entryStoryBoard = UIStoryboard(name: "Entry", bundle: nil)
            let entryViewController = entryStoryBoard.instantiateViewControllerWithIdentifier("EntryViewController") as! EntryViewController
            entryViewController.entry = entry
            entryViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "entryDoneButtonTapped:")
            LoadingOverlay.shared.hideOverlayView()
            self.navigationController?.pushViewController(entryViewController, animated: true)

        }
    }
    
    func entryDoneButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("navigateToUpload", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        videoURL = video!
        generateThumbnail()
        playVideo(video!)
        setupIcons()
        privateSwitch.onTintColor = StyleGuide.Colors.echoBorderGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayer.player?.pause()
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
