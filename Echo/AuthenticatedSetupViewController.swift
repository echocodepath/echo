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
        let loginNav = NavigationController(rootViewController: loginViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginNav
    }
    
//    func openHomePage() {
//        let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
//        let homePageNav = NavigationController(rootViewController: homeViewController)
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window?.rootViewController = homePageNav
//    }
    
    func openHomeTab(){
        let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeTabViewController") as! HomeTabViewController
        //let homePageNav = NavigationController(rootViewController: homeViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = homeViewController
    }
    
    @IBAction func onSelectDanceTeacher(sender: AnyObject) {
        let responseDict: [String: String] = ["is_teacher": "true"]
        ParseClient.sharedInstance.setCurrentUserWithDict(responseDict)
        //openHomePage()
        openHomeTab()
    }
    
    @IBAction func onSelectDanceStudent(sender: AnyObject) {
        let responseDict: [String: String] = ["is_teacher": "false"]
        ParseClient.sharedInstance.setCurrentUserWithDict(responseDict)
        //openHomePage()
        openHomeTab()
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
