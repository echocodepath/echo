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
        }
    }
    
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let thumbnailData = entry!["thumbnail"] as! PFFile
        thumbnailData.cancel()
    }
}
