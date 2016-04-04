//
//  JournalCollectionViewCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/26/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class JournalCollectionViewCell: UICollectionViewCell {
    
    var entry: PFObject? {
        didSet {
            let thumbnailData = entry!["thumbnail"] as! PFFile
            thumbnailData.getDataInBackgroundWithBlock({ (data, error) -> Void in
                let thumbnailImage = UIImage(data: data!)
                self.thumbnailImageView?.alpha = 0
                self.thumbnailImageView?.image = thumbnailImage
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.thumbnailImageView?.alpha = 1
                })
            })
            
            fullDateLabel.text =
                "\((DateManager.wordDayFormatter.stringFromDate(entry!.createdAt!)).uppercaseString)"
            dateNumberLabel.text = DateManager.onlyDayFormatter.stringFromDate(entry!.createdAt!)
            timeLabel.text = DateManager.timeOnlyFormatter.stringFromDate(entry!.createdAt!)
        }
    }
    
    
    @IBOutlet weak var fullDateLabel: UILabel!
    @IBOutlet weak var dateNumberLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let labels = [fullDateLabel, dateNumberLabel, timeLabel]
//        labels.forEach({ formatName($0) })
        
//        fullDateLabel.font = StyleGuide.Fonts.regularFont(size: 19.0)
//        dateNumberLabel.font = StyleGuide.Fonts.semiBoldFont(size: 60.0)
//        timeLabel.font = StyleGuide.Fonts.regularFont(size: 19.0)
    }
    
    func formatName(label: UILabel){
        label.layer.shadowColor = UIColor.blackColor().CGColor
        label.layer.shadowOffset = CGSizeMake(2, 2)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let thumbnailData = entry!["thumbnail"] as! PFFile
        thumbnailData.cancel()
    }
}
