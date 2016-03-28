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
    
    var entry: PFObject!{
        didSet {
// For saving dual feedback
//            let createdAtDate: NSDate
//            if entry.objectForKey("teacher_createdAt") != nil {
//                createdAtDate = entry.objectForKey("teacher_createdAt") as! NSDate
//            } else {
//                createdAtDate = entry.createdAt!
//            }
//            let createdAt = DateManager.defaultFormatter.stringFromDate(createdAtDate)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.titleLabel.text = self.entry.valueForKey("title") as? String
                self.songLabel.text = self.entry.valueForKey("song") as? String
                let artist = self.entry.valueForKey("artist") as? String
                self.byLabel.text = "by \(artist!)"
                let dayWord = DateManager.wordDayFormatter.stringFromDate(self.entry.createdAt!)
                let onlyDay = DateManager.onlyDayFormatter.stringFromDate(self.entry.createdAt!)
                
                self.dayOnlyLabel.text = onlyDay
                self.timeLabel.text = DateManager.timeOnlyFormatter.stringFromDate(self.entry.createdAt!)
                self.createdAtLabel.text = "\(dayWord.uppercaseString)"
                
                let thumbnailData = self.entry["thumbnail"] as! PFFile
                thumbnailData.getDataInBackgroundWithBlock({ (data
                    , error) -> Void in
                    let thumbnailImage = UIImage(data: data!)
                    self.thumbnailImageView.image = thumbnailImage
                    self.titleLabel.alpha = 1
                    self.songLabel.alpha = 1
                    self.byLabel.alpha = 1
                    self.dayOnlyLabel.alpha = 1
                    self.songLabel.alpha = 1
                    self.thumbnailImageView.alpha = 1
                    self.createdAtLabel.alpha = 1
                })
                
            })
        }
    }
    
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
        
        titleLabel.alpha = 0
        songLabel.alpha = 0
        thumbnailImageView.alpha = 0
        createdAtLabel.alpha = 0
        byLabel.alpha = 0
        dayOnlyLabel.alpha = 0
        weekDayLabel.alpha = 0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
