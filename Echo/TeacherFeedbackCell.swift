//
//  TeacherFeedbackCell.swift
//  Echo
//
//  Created by Christine Hong on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class TeacherFeedbackCell: UITableViewCell {
    var teacher: PFObject? {
        didSet {
            profileImageLabel.alpha = 0
            let url  = NSURL(string: (teacher?.objectForKey("profilePhotoUrl") as? String)!)
            teacherName.text = teacher!["username"] as? String
            locationLabel.text = teacher!["location"] as? String
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.profileImageLabel.setImageWithURL(url!)
                self.profileImageLabel.alpha = 1
            })
        }
    }
    
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var profileImageLabel: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageLabel.layer.masksToBounds = false
        profileImageLabel.layer.cornerRadius = profileImageLabel.frame.height/2
        profileImageLabel.clipsToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let view = UIView()
        view.backgroundColor = StyleGuide.Colors.echoCellSelectedMint
        selectedBackgroundView = view
    }

}
