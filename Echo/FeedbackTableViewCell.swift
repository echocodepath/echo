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
            createdAtLabel.text = DateManager.defaultFormatter.stringFromDate((feedback?.createdAt)!)
            teacherLabel.text = feedback?.objectForKey("teacher_username") as? String
        }
    }
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 0.3)
        createdAtLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
        teacherLabel.textColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.8)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
