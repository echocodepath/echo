//
//  TeacherTableViewCell.swift
//  Echo
//
//  Created by Christine Hong on 6/24/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import AFNetworking

class TeacherTableViewCell: UITableViewCell {
    @IBOutlet weak var teacherImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var teacher: PFUser!{
        didSet {
            self.nameLabel.text = self.teacher.valueForKey("username") as? String
            self.locationLabel.text = self.teacher.valueForKey("location") as? String
            if self.teacher!["description"] != nil {
                self.infoLabel.text = self.teacher!["description"] as? String
            }
            
            if let profUrl =  self.teacher.valueForKey("profilePhotoUrl") {
                self.teacherImage.setImageWithURL(NSURL(string: profUrl as! String)!)
            }
            
            self.teacherImage.layer.borderColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.7).CGColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
