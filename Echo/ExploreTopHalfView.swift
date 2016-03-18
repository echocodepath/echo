//
//  ExploreTopHalfView.swift
//  Echo
//
//  Created by Andrew Yu on 3/16/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class ExploreTopHalfView: UICollectionReusableView  {

    var headerView: UIView? {
        willSet {
            if let headerView = headerView {
                headerView.removeConstraints(headerView.constraints)
                headerView.removeFromSuperview()
            }
        }
        didSet {
            if let headerView = headerView {
                addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                headerView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
                headerView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
                headerView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
                headerView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headerView = nil
    }
}
