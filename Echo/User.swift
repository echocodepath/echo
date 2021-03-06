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

var currentUser: User?
var currentPfUser: PFUser?

class User: NSObject {
    var id: String?
    var facebook_id: String?
    var username: String?
    var is_teacher: String?
    var email: String?
    var profilePhotoUrl: String?
    var coverPhotoUrl: String?
    
    init(user: PFUser) {
        super.init()
        self.id = user.valueForKey("objectId") as? String
        self.facebook_id = user.valueForKey("facebook_id") as? String
        self.username = user.username
        self.is_teacher = "false"
        currentPfUser = PFUser.currentUser()
        returnUserData()
    }
    
    func returnUserData() {
        if currentPfUser?.valueForKey("profilePhotoUrl") == nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil) {
                    print("Error: \(error)")
                } else {
                    var responseDict: [String: String]! = Dictionary<String,String>()
                    let id: String? = result.valueForKey("id") as? String
//                    let location : NSDictionary? = result.valueForKey("location") as? NSDictionary
//                    let city : String? = location!.valueForKey("name") as? String
                    self.facebook_id = id!
                    responseDict["facebook_id"] = id!
                    responseDict["username"] = result.valueForKey("name") as? String
                    responseDict["email"] =  result.valueForKey("email") as? String
                    responseDict["profilePhotoUrl"] = "https://graph.facebook.com/\(self.facebook_id!)/picture?width=300&height=300"
                    self.profilePhotoUrl = responseDict["profilePhotoUrl"]
                    responseDict["coverPhotoUrl"] = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID!)?fields=cover"
                    self.coverPhotoUrl = responseDict["coverPhotoUrl"]
                    self.saveToParse(responseDict)
                    currentUser = self
                }
            })
        }
    }
    
    func saveToParse(dict: NSDictionary){
        ParseClient.sharedInstance.setCurrentUserWithDict(dict)
    }
}