//
//  FeedbackClipTableViewCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/11/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class FeedbackClipTableViewCell: UITableViewCell {
    static var count = 0
    
    var audioClip: AudioClip? {
        didSet {
            durationLabel.text = "\(Int(audioClip!.duration!))s"
            timestampLabel.text = "\(String(format: "%02d:%02d", ((lround(audioClip!.offset!) / 60) % 60), lround(audioClip!.offset!) % 60))"
        }
    }
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var audioClipImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        FeedbackClipTableViewCell.count += 1
        audioClipImageView.image = UIImage(named: "Sound Waves")
        locationImageView.image = UIImage(named: "timestamp_icon")
        contentView.backgroundColor = StyleGuide.Colors.echoLightBrownGray
        durationLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
        timestampLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
        noteLabel.textColor = UIColor(red: 199/255, green: 161/255, blue: 129/255, alpha: 1.0)
        noteLabel.text = "NOTE \(FeedbackClipTableViewCell.count)"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
