//
//  CollectionHeaderFooterView.swift
//  Echo
//
//  Created by Isis Anchalee on 3/31/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import SnapKit

class CollectionHeaderFooterView: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.mediumFont(size: 14.0)
        label.textColor = StyleGuide.Colors.echoDarkerGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.snp_makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).inset(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
