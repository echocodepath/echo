//
//  VideoPlayerContainable.swift
//  Echo
//
//  Created by Isis Anchalee on 3/24/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SnapKit

protocol VideoPlayerContainable: class {
    /// The default aspect ratio for the video player
    /// Default value is 1:1
    static var videoPlayerDefaultAspectRatio: CGSize { get }
    
    var videoPlayer: AVPlayerViewController { get }
    
    var videoURL: NSURL? { get }
    
    /// Add the video player controller as a subview
    /// :param: view     Superview of the video player
    /// :param: videoURL The URL of the video. Used to determine aspect ratio
    func videoPlayer(addToView view: UIView, videoURL: NSURL?)
    
    func videoPlayerHeight(forWidth width: CGFloat) -> CGFloat
}

extension VideoPlayerContainable where Self : UIViewController {
    static var videoPlayerDefaultAspectRatio: CGSize {
        return CGSize(width: 4, height: 3) // Default to square
    }
    
    func videoPlayer(addToView view: UIView, videoURL: NSURL?) {
        videoPlayer.willMoveToParentViewController(self)
        addChildViewController(videoPlayer)
        view.addSubview(videoPlayer.view)
        
        let size: CGSize = {
            if let url = videoURL, size = resolutionForLocalVideo(url) {
                return size
            } else {
                return self.dynamicType.videoPlayerDefaultAspectRatio
            }
        }()
        
        videoPlayer.view.snp_makeConstraints { make in
            make.edges.equalTo(view)
            make.height.equalTo(videoPlayer.view.snp_width).multipliedBy(size.height / size.width)
        }
        videoPlayer.didMoveToParentViewController(self)
    }
    
    func videoPlayerHeight(forWidth width: CGFloat) -> CGFloat {
        let size: CGSize = {
            if let url = videoURL, size = resolutionForLocalVideo(url) {
                return size
            } else {
                return self.dynamicType.videoPlayerDefaultAspectRatio
            }
        }()
        
        print("size is \(size.width) \(size.height)")
        return width * size.height / size.width
    }
    
    func resolutionForLocalVideo(url:NSURL) -> CGSize? {
        guard let track = AVAsset(URL: url).tracksWithMediaType(AVMediaTypeVideo).first else { return nil }
        let size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}