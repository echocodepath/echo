//
//  EntryViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/6/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation

class EntryViewController: UIViewController {
    var video: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func generateThumbnail(){
//        var err: NSError? = nil
//        let asset = AVURLAsset(URL: video!, options: nil)
//        let imgGenerator = AVAssetImageGenerator(asset: asset)
//        let cgImage = imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil, error: &err)
//        // !! check the error before proceeding
//        let uiImage = UIImage(CGImage: cgImage)
//        let imageView = UIImageView(image: uiImage)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
