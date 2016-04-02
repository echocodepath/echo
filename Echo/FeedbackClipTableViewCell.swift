//
//  FeedbackClipTableViewCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/11/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import SCWaveformView

class FeedbackClipTableViewCell: UITableViewCell {
    static var count = 0
    
    var audioClip: AudioClip? {
        didSet {
            guard let audioClip = audioClip else {
                return
            }
            
            let asset = AVURLAsset(URL: audioClip.path!)
            waveformView.asset = asset
            
            durationLabel.text = "\(Int(audioClip.duration!))s"
            timestampLabel.text = "\(String(format: "%02d:%02d", ((lround(audioClip.offset!) / 60) % 60), lround(audioClip.offset!) % 60))"

        }
    }
    
    @IBOutlet weak var waveformView: SCWaveformView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        FeedbackClipTableViewCell.count += 1
        locationImageView.image = UIImage(named: "timestamp_icon")
        contentView.backgroundColor = StyleGuide.Colors.echoLightBrownGray
        durationLabel.textColor = StyleGuide.Colors.echoTranslucentClear
        timestampLabel.textColor = StyleGuide.Colors.echoTranslucentClear
        noteLabel.textColor = UIColor(red: 199/255, green: 161/255, blue: 129/255, alpha: 1.0)
        noteLabel.text = "NOTE \(FeedbackClipTableViewCell.count)"
        waveformView.backgroundColor = StyleGuide.Colors.echoLightBrownGray
        waveformView.normalColor = StyleGuide.Colors.echoTranslucentClear
        waveformView.progressColor = StyleGuide.Colors.echoDarkerTeal
        waveformView.precision = 0.7
        waveformView.lineWidthRatio = 1
        waveformView.alpha = 0.8
        
//        selectionStyle = .None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
