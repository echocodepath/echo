//
//  StyleGuide.swift
//  Echo
//
//  Created by Andrew Yu on 3/16/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

struct StyleGuide {
    struct Layout {
        static let someCommonLayoutValue: CGFloat = 10
    }
    struct Fonts {
        static func regularFont(size size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir Next", size: size)!
        }
        static func boldFont(size size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-Black", size: size)!
        }
        static func mediumFont(size size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-Medium", size: size)!
        }
        static func semiBoldFont(size size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-Heavy", size: size)!
        }
    }
    
    struct Colors {
        static let echoOrange = UIColor(red: 249/255, green: 154/255, blue: 64/255, alpha: 1.0)
        static let echoLightOrange = UIColor(red: 0.9922, green: 0.8039, blue: 0.302, alpha: 1.0)
        static let echoTeal = UIColor(red:0.33, green:0.78, blue:0.69, alpha:1.0)
        static let echoBrownGray = UIColor(red: 59/255, green: 59/255, blue: 67/255, alpha: 1.0)
        static let echoLightBrownGray = UIColor(red: 83/255, green: 83/255, blue: 92/255, alpha: 1.0)
        static let echoLightTeal = UIColor(red: 0.3725, green: 0.7137, blue: 0.7804, alpha: 1.0)
        static let echoTranslucentClear = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 0.7)
        static let echoDarkerTranslucentClear = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 0.85)
        static let echoFormGray = UIColor(red: 232/255, green: 233/255, blue: 235/255, alpha: 1.0)
        static let echoBorderGray = UIColor(red: 195/255, green: 195/255, blue: 195/255, alpha: 1.0)
        static let echoDarkerTeal = UIColor(red: 0.2745, green: 0.6549, blue: 0.7333, alpha: 1.0)
        static let echoDarkGray = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        static let echoDarkerGray = UIColor(red: 93/255, green: 93/255, blue: 93/255, alpha: 1.0)
        static let echoNewGray = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        static let echoCellSelectedMint = UIColor(red: 0.8824, green: 0.9373, blue: 0.949, alpha: 1.0)
        static let echoBlue = UIColor(red: 0.2902, green: 0.5647, blue: 0.8863, alpha: 1.0)
        static let echoCharcoal = UIColor(red: 59/255, green: 59/255, blue: 67/255, alpha: 1.0)
        static let echoHighlightGray = UIColor(red: 117/255, green: 117/255, blue: 125/255, alpha: 1.0)
    }
}

struct Utils {
    static func configureDefaultNavigationBar(navBar: UINavigationBar) {
        navBar.translucent = false
        navBar.barTintColor = StyleGuide.Colors.echoOrange
        navBar.tintColor = UIColor.whiteColor()
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    static func createNormalInboxText(name: String, title: String) -> NSAttributedString {
        let nameLength = name.characters.count
        let titleLength = title.characters.count
        let startingString = "\(name) would like feedback on \(title)."
        let totalLength = startingString.characters.count
        let startingTitlePoint = totalLength - titleLength - 1
        let mutableString = NSMutableAttributedString(
            string: startingString,
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(13.0)])
        
        mutableString.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(13, weight: UIFontWeightBold),
            range: NSRange(
                location: 0,
                length: nameLength))
        mutableString.addAttribute(NSForegroundColorAttributeName,
            value: StyleGuide.Colors.echoDarkerTeal,
            range: NSRange(
                location: 0,
                length: nameLength))
        
        mutableString.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(13, weight: UIFontWeightBold),
            range: NSRange(
                location: startingTitlePoint,
                length: titleLength))

        mutableString.addAttribute(NSForegroundColorAttributeName,
            value: StyleGuide.Colors.echoDarkGray,
            range: NSRange(
                location: startingTitlePoint,
                length: titleLength))
    
        return mutableString
    }
    
    static func createSentInboxText(name: String, title: String, status: String) -> NSAttributedString {
        let nameLength = name.characters.count
        let titleLength = title.characters.count
        var startingString = ""
        var titleIndex = 0
        //TODO: use indexOf instead of hard coding numbers
        if status == "pending" {
            startingString = "Awaiting feedback on \(title) from \(name)."
            titleIndex = 21
        } else if status == "accepted" {
            startingString = "Received feedback on \(title) from \(name)."
            titleIndex = 21
        } else {
            startingString = "Feedback request on \(title) was rejected by \(name)."
            titleIndex = 20
        }
        
        let totalLength = startingString.characters.count
        let nameIndex = totalLength - nameLength - 1
        
        let mutableString = NSMutableAttributedString(
            string: startingString,
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(13.0)])
        
        mutableString.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(13, weight: UIFontWeightBold),
            range: NSRange(
                location: titleIndex,
                length: titleLength))
        mutableString.addAttribute(NSForegroundColorAttributeName,
            value: StyleGuide.Colors.echoDarkGray,
            range: NSRange(
                location: titleIndex,
                length: titleLength))
        mutableString.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(13, weight: UIFontWeightBold),
            range: NSRange(
                location: nameIndex,
                length: nameLength))
        mutableString.addAttribute(NSForegroundColorAttributeName,
            value: StyleGuide.Colors.echoDarkerTeal,
            range: NSRange(
                location: nameIndex,
                length: nameLength))
        
        return mutableString
    }
    
    static func createAcceptedInboxText(name: String, title: String) -> NSAttributedString {
        let nameLength = name.characters.count + 2
        let titleLength = title.characters.count + 1
        let startingString = "You accepted \(name)'s request for feedback on \(title)"
        let totalLength = startingString.characters.count
        let startingTitlePoint = totalLength - titleLength - 1
        
        let mutableString = NSMutableAttributedString(
            string: startingString,
            attributes: [NSFontAttributeName:UIFont.systemFontOfSize(13.0)])
        
        mutableString.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(13, weight: UIFontWeightBold),
            range: NSRange(
                location: 13,
                length: nameLength))
        mutableString.addAttribute(NSForegroundColorAttributeName,
            value: StyleGuide.Colors.echoDarkerTeal,
            range: NSRange(
                location: 13,
                length: nameLength))
        
        mutableString.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(13, weight: UIFontWeightBold),
            range: NSRange(
                location: startingTitlePoint + 1,
                length: titleLength))
        
        mutableString.addAttribute(NSForegroundColorAttributeName,
            value: StyleGuide.Colors.echoDarkGray,
            range: NSRange(
                location: startingTitlePoint + 1,
                length: titleLength))
        
        return mutableString
    }
}