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
    
//    var entry: PFObject!{
//        didSet {
//            titleLabel.text = entry.valueForKey("title") as? String
//            songLabel.text = entry.valueForKey("song") as? String
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 0.4)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
