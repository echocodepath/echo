//
//  InboxTabBarController.swift
//  Echo
//
//  Created by Christine Hong on 3/14/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class InboxTabBarController: UITabBarController {
    @IBOutlet weak var inboxTabBar: UITabBar!
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabItems = self.inboxTabBar.items! as [UITabBarItem]
        let tabItem0 = tabItems[0] as UITabBarItem
        let tabItem1 = tabItems[1] as UITabBarItem
        let tabItem2 = tabItems[2] as UITabBarItem
        let tabItem3 = tabItems[3] as UITabBarItem
        tabItem0.title = "Inbox"
        tabItem1.title = "Sent"
        tabItem2.title = "Accepted"
        tabItem3.title = "Rejected"
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
