//
//  HomeTabViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/30/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class HomeTabViewController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return nil
    }
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentUser == nil {
            currentUser = User(user: PFUser.currentUser()!)
        }
        self.tabBar.translucent = false
        self.tabBar.barTintColor = StyleGuide.Colors.echoDarkBrownGray
        self.tabBar.tintColor = UIColor.whiteColor()
        
        // set black as selected background color
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(StyleGuide.Colors.echoDarkDarkGray, size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 4
        tabBar.frame.origin.x = -2
        
        let tabItems = self.tabBar.items! as [UITabBarItem]
        let iconImages = ["Journal - Selected", "Inbox", "White Camera", "Find Teacher Icon", "Explore Icon"]
        for index in 0...4  {
            let item = tabItems[index] as UITabBarItem
            item.image = UIImage(named: iconImages[index])
            item.title = nil
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(StyleGuide.Colors.echoIconGray).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
