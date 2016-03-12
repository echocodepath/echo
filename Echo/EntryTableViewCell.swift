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

    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
//    var entry: PFObject!{
//        didSet {
//            titleLabel.text = entry.valueForKey("title") as? String
//            songLabel.text = entry.valueForKey("song") as? String
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
