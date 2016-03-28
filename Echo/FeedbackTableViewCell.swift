//
//  FeedbackTableViewCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/15/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class FeedbackTableViewCell: UITableViewCell {
    var feedback: PFObject? {
        didSet {
            createdAtLabel.alpha = 0
            teacherLabel.alpha = 0
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.createdAtLabel.text = DateManager.defaultFormatter.stringFromDate((self.feedback?.createdAt)!)
                self.teacherLabel.text = self.feedback?.objectForKey("teacher_username") as? String
                self.teacher = self.feedback?.objectForKey("teacher_id") as? PFObject
                self.createdAtLabel.alpha = 1
                self.teacherLabel.alpha = 1
            })

        }
    }
    
    var teacher: PFObject? {
        didSet {
            teacherProfileImageView.alpha = 0
            teacher!.fetchIfNeededInBackgroundWithBlock {
                (teacher: PFObject?, error: NSError?) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    let url  = NSURL(string: (teacher?.objectForKey("profilePhotoUrl") as? String)!)
                    self.teacherProfileImageView.setImageWithURL(url!)
                    self.teacherProfileImageView.alpha = 1
                })

            }

        }
    }


    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var teacherProfileImageView: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        createdAtLabel.textColor = StyleGuide.Colors.echoBorderGray
        createdAtLabel.font = StyleGuide.Fonts.regularFont(size: 10.0)

        teacherLabel.textColor = StyleGuide.Colors.echoDarkerTeal
        teacherLabel.font = StyleGuide.Fonts.semiBoldFont(size: 13.0)
        
        fromLabel.textColor = StyleGuide.Colors.echoDarkerGray
        fromLabel.font = StyleGuide.Fonts.mediumFont(size: 10.0)
        
        teacherProfileImageView.layer.masksToBounds = false
        teacherProfileImageView.layer.cornerRadius = teacherProfileImageView.frame.height/2
        teacherProfileImageView.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
