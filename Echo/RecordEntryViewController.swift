//
//  RecordEntryViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/6/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary

class RecordEntryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let cameraPicker: UIImagePickerController = UIImagePickerController()
    let albumPicker: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openAlbum(sender: AnyObject) {
        albumPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        albumPicker.mediaTypes = [kUTTypeMovie as String]
        albumPicker.delegate = self
        self.presentViewController(albumPicker, animated: true, completion: nil)
    }

    @IBAction func onBackPress(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func recordVideo(sender: AnyObject) {
        
        // 1 Check if project runs on a device with camera available
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            // 2 Present UIImagePickerController to take video
            cameraPicker.sourceType = .Camera
            cameraPicker.mediaTypes = [kUTTypeMovie as String]
            cameraPicker.delegate = self
            cameraPicker.videoMaximumDuration = 10.0
            self.presentViewController(cameraPicker, animated: true, completion: nil)
        } else {
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        var videoUrl: NSURL?
        let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
        
        if let type:AnyObject = mediaType {
            if type is String {
                let stringType = type as! String
                if stringType == kUTTypeMovie as String {
                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                    if let url = urlOfVideo {
                        videoUrl = url
                        print("URL!!!!! \(url)")
                    }
                }
            }
        }
        
        picker.dismissViewControllerAnimated(true) { () -> Void in
            let entryViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EntryFormViewController") as! EntryFormViewController
            entryViewController.video = videoUrl!
            let entryNav = UINavigationController(rootViewController: entryViewController)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = entryNav
        }

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
