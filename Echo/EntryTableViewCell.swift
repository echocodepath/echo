//
//  EntryTableViewCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/8/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class EntryTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailIconImageView: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayOnlyLabel: UILabel!
    
    @IBOutlet weak var weekDayLabel: UILabel!
    
//    var entry: PFObject!{
//        didSet {
//            titleLabel.text = entry.valueForKey("title") as? String
//            songLabel.text = entry.valueForKey("song") as? String
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = StyleGuide.Colors.echoNewGray

        weekDayLabel.font = StyleGuide.Fonts.regularFont(size: 11.0)
        weekDayLabel.textColor = StyleGuide.Colors.echoDarkerGray
        dayOnlyLabel.font = StyleGuide.Fonts.boldFont(size: 27.0)
        dayOnlyLabel.textColor = StyleGuide.Colors.echoDarkerGray
        timeLabel.font = StyleGuide.Fonts.regularFont(size: 11.0)
        timeLabel.textColor = StyleGuide.Colors.echoDarkerGray
        songLabel.font = StyleGuide.Fonts.semiBoldFont(size: 11.0)
        songLabel.textColor = StyleGuide.Colors.echoDarkerGray
        byLabel.font = StyleGuide.Fonts.mediumFont(size: 11.0)
        byLabel.textColor = StyleGuide.Colors.echoDarkerGray
        titleLabel.font = StyleGuide.Fonts.semiBoldFont(size: 14.0)
        titleLabel.textColor = StyleGuide.Colors.echoDarkerGray
        createdAtLabel.font = StyleGuide.Fonts.regularFont(size: 10.0)
        createdAtLabel.textColor = StyleGuide.Colors.echoDarkerGray
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
