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
                    let data = NSData(contentsOfURL: url!)
                    self.teacherProfileImageView.image = UIImage(data: data!)
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
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 0.3)
        createdAtLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
        teacherLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
        fromLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
