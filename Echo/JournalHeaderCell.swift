

//
//  JournalHeaderCell.swift
//  Echo
//
//  Created by Isis Anchalee on 3/27/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class JournalHeaderCell: UICollectionReusableView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = StyleGuide.Colors.echoDarkerGray
        label.font = StyleGuide.Fonts.mediumFont(size: 14.0)
        return label
    }()
    
    private func setupLayout() {
        addSubview(titleLabel)

        titleLabel.snp_makeConstraints { make in
//            make.centerX.equalTo(self)
//            make.top.equalTo(profilePhotoFrame.snp_bottom).offset(padding)
        }

    }
}
