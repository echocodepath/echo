//
//  VideoViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/29/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController: AVPlayerViewController {
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.view.addGestureRecognizer(pan)
        return pan
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var panGestureTime: Double = 0
    func handlePan(sender: UIPanGestureRecognizer) {
        guard let player = player else {
            return
        }
        
        switch sender.state {
        case .Began:
            panGestureTime = player.currentTime().seconds
            
        case .Changed:
            let translation = -sender.translationInView(view).x
            let offset = panGestureTime + Double(translation / view.frame.width) * (player.currentItem?.duration.seconds)! * 0.25
            player.seekToTime(CMTime(seconds: offset, preferredTimescale: 1))
            
            print(offset)
            debugPrint(offset)
            
        default: break
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
