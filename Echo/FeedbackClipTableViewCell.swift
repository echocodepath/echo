//
//  FeedbackClipTableViewCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/11/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class FeedbackClipTableViewCell: UITableViewCell {
    var audioClip: AudioClip? {
        didSet {
            durationLabel.text = "\(Int(audioClip!.duration!))s"
            timestampLabel.text = "\(audioClip!.offset!)"
        }
    }
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
