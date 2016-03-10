//
//  EntryFormViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class EntryFormViewController: UIViewController {
    var video: NSURL?
    
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var entryThumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var songTextField: UITextField!
    
    @IBAction func onCancel(sender: AnyObject) {
        let homeViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        let homeNav = UINavigationController(rootViewController: homeViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = homeNav
    }
    
    @IBAction func onEntrySave(sender: AnyObject) {
        let user_id = currentUser!.id
        let username =  currentUser!.username
        let title = titleTextField.text
        let song = songTextField.text
        var responseDict: [String: NSObject] = Dictionary<String,NSObject>()
        let videoData = NSData(contentsOfURL: video!)
        let videoFile = PFFile(name: "Entry", data: videoData!)
        
        responseDict["username"] = username
        responseDict["user_id"] = user_id
        responseDict["title"] = title
        responseDict["song"] = song
        responseDict["video"] = videoFile
        if privateSwitch.on{
            responseDict["private"] = true
        } else {
            responseDict["private"] = false
        }
        
        ParseClient.sharedInstance.createEntryWithCompletion(responseDict) { (entry, error) -> () in
            let entryViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryViewController") as! EntryViewController
            entryViewController.entry = entry
            let entryNav = UINavigationController(rootViewController: entryViewController)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = entryNav
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I SEE U \(video!)")
        generateThumbnail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
