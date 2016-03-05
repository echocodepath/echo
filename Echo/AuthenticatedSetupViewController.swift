//
//  AuthenticatedSetupViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/2/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class AuthenticatedSetupViewController: UIViewController {

    @IBAction func onLogout(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        openLoginPage()
    }
    
    func openLoginPage() {
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let loginNav = UINavigationController(rootViewController: loginViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginNav
    }
    
    func openHomePage() {
        let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        let homePageNav = UINavigationController(rootViewController: homeViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = homePageNav
    }
    
    @IBAction func onSelectDanceTeacher(sender: AnyObject) {
        ParseClient.sharedInstance.setUserValue("is_teacher", value: "true")
        openHomePage()
    }
    
    @IBAction func onSelectDanceStudent(sender: AnyObject) {
        ParseClient.sharedInstance.setUserValue("is_teacher", value: "false")
        openHomePage()
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
