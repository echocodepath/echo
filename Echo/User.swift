//
//  User.swift
//  Echo
//
//  Created by Christine Hong & Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"

class User: NSObject {
    var currentUser: PFUser?
    
    var facebook_id: String?
    var username: String?
    var is_teacher: String?
    var email: String?
    var profilePhotoUrl: String?
    var coverPhotoUrl: String?
    
    init(user: PFUser) {
        currentUser = user
        self.username = currentUser?.username
        self.profilePhotoUrl = (currentUser?.valueForKey("profilePhotoUrl") as! String)
        self.coverPhotoUrl = (currentUser?.valueForKey("coverPhotoUrl") as! String)
        super.init()
        self.is_teacher = "false"
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
                self.facebook_id = id!
                responseDict["facebook_id"] = id!
                responseDict["username"] = result.valueForKey("name") as? String
                responseDict["email"] =  result.valueForKey("email") as? String
                responseDict["profilePhotoUrl"] = "https://graph.facebook.com/\(self.facebook_id!)/picture?width=300&height=300"
                responseDict["coverPhotoUrl"] = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID!)/cover?"
                self.saveLocally(responseDict)
                self.saveToParse(responseDict)
            }
        })
    }
    
    func saveLocally(result: NSDictionary){
        facebook_id = result.valueForKey("facebook_id") as? String
        print("FACEBOOK ID")
        print(facebook_id)
        username = result.valueForKey("username") as? String
        print("USERNAME")
        print(username)
        email = result.valueForKey("email") as? String
        profilePhotoUrl = result.valueForKey("profilePhotoUrl") as? String
        print("profilePhotoUrl")
        print(profilePhotoUrl)
        coverPhotoUrl = result.valueForKey("coverPhotoUrl") as? String
        print("coverPhotoUrl")
        print(coverPhotoUrl)
        _currentUser = self
    }
    
    func saveToParse(dict: NSDictionary){
        ParseClient.sharedInstance.setCurrentUserWithDict(dict)
    }
    
    //    class var currentUser: User? {
    //        get {
    //            if _currentUser == nil {
    //                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
    //                if data != nil {
    //                    do {
    //                        if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue:0)) as? NSDictionary {
    //                        _currentUser = User(result: dictionary)
    //                        }
    //                    } catch {
    //                        print("JSON error")
    //                    }
    //                }
    //            }
    //            return _currentUser
    //        }
    //        set(user) {
    //            _currentUser = user
    //            if _currentUser != nil {
    //                do {
    //                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions(rawValue:0)) as NSData
    //                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
    //                } catch {
    //                    print("JSON error")
    //                }
    //            } else {
    //                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
    //            }
    //            NSUserDefaults.standardUserDefaults().synchronize()
    //        }
    //    }
}