//
//  InboxCell.swift
//  Echo
//
//  Created by Andrew Yu on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var inboxTextLabel: UILabel!
    @IBOutlet weak var cellChevron: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Make into circle
//        cellChevron.alpha = 0.2
//        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
//        avatarImageView.layer.borderColor = UIColor.blackColor().CGColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let view = UIView()
        view.backgroundColor = StyleGuide.Colors.echoCellSelectedMint
        selectedBackgroundView = view
    }

}
