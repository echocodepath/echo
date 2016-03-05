//
//  HomeViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class HomeViewController: UIViewController {

    @IBAction func onLogout(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let loginNav = UINavigationController(rootViewController: loginViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginNav
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
