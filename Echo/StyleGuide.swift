//
//  StyleGuide.swift
//  Echo
//
//  Created by Andrew Yu on 3/16/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

struct StyleGuide {
    struct StyleGuide {
        struct Layout {
            static let someCommonLayoutValue: CGFloat = 10
        }
        struct Fonts {
            static func regularFont(size size: CGFloat) -> UIFont {
                return UIFont(name: "your-font", size: size)!
            }
            static func demiBoldFont(size size: CGFloat) -> UIFont {
                return UIFont(name: "your-font-demiBold", size: size)!
            }
        }
        struct Colors {
            let echoOrange = UIColor(red:0.96, green:0.65, blue:0.14, alpha:1.0)
            let echoTeal = UIColor(red:0.33, green:0.78, blue:0.69, alpha:1.0)
        }
    }
}