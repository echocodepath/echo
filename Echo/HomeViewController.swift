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

        returnUserData()
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error)")
            } else {
                var responseDict: [String: String]! = Dictionary<String,String>()
                let id: String? = result.valueForKey("id") as? String
                responseDict["facebook_id"] = id!
                responseDict["username"] = result.valueForKey("name") as? String
                responseDict["email"] =  result.valueForKey("email") as? String
                responseDict["profilePhotoUrl"] = "https://graph.facebook.com/\(id!)/picture?width=300&height=300"
                responseDict["coverPhotoUrl"] = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID!)/cover?"
                //self.saveLocally(responseDict)
                self.saveToParse(responseDict)
            }
        })
    }
    
    func saveToParse(dict: NSDictionary){
        ParseClient.sharedInstance.setCurrentUserWithDict(dict)
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
