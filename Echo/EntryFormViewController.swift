//
//  EntryFormViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation

class EntryFormViewController: UIViewController {
    var video: NSURL?
    
    @IBOutlet weak var entryThumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var songTextField: UITextField!
    
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
