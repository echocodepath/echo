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
            createdAtLabel.text = DateManager.getFriendlyTime(feedback?.createdAt)
            teacherLabel.text = feedback?.objectForKey("teacher_username") as? String
        }
    }
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
