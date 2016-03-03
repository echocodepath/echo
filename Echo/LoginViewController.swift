//
//  ViewController.swift
//  Echo
//
//  Created by Christine Hong on 2/29/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginBtn: FBSDKLoginButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.delegate = self
        loginBtn.readPermissions = ["public_profile", "email", "user_friends"]
        
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print("user is not logged in")
        } else {
            let authenticatedSetupViewController = self.storyboard!.instantiateViewControllerWithIdentifier("AuthenticatedSetupViewController") as! AuthenticatedSetupViewController
            let authSetupPageNav = UINavigationController(rootViewController: authenticatedSetupViewController)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = authSetupPageNav
        }
    }
    

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        print("user is logged out")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil) {
            print(error.localizedDescription)
            return
        }
        
        if let userToken = result.token {
            //Get user access token
            let token:FBSDKAccessToken = result.token
            
            print("User ID = \(FBSDKAccessToken.currentAccessToken().userID)")
            
            let authenticatedSetupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AuthenticatedSetupViewController") as! AuthenticatedSetupViewController
            
            let authSetupPageNav = UINavigationController(rootViewController: authenticatedSetupViewController)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.window?.rootViewController = authSetupPageNav
            
        }
        
    }
}

