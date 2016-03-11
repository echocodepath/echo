//
//  EntryCollectionViewCell.swift
//  Echo
//
//  Created by Christine Hong on 3/8/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class EntryCollectionViewCell: UICollectionViewCell {
    var entry: PFObject? {
        didSet {
            let thumbnailData = entry!["thumbnail"] as! PFFile
            do {
                let rawData = try thumbnailData.getData()
                let thumbnailImage = UIImage(data: rawData)
                thumbnailImageView.image = thumbnailImage
            } catch {
                
            }

        }
    }
    
    @IBOutlet weak var entryLabel: UILabel!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
