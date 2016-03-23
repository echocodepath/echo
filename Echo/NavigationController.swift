//
//  NavigationController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/22/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

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
}
