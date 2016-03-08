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

class User: NSObject {
    var currentUser: PFUser?
    
    var facebook_id: String?
    var username: String?
    var is_teacher: String?
    var email: String?
    var profilePhotoUrl: String?
    var coverPhotoUrl: String?
    
    // TODO: Redo this model, we're definitely wasting time with our current logic
    init(user: PFUser) {
        currentUser = user
        self.facebook_id = (currentUser?.valueForKey("facebook_id") as! String)
        self.username = currentUser?.username
        self.profilePhotoUrl = (currentUser?.valueForKey("profilePhotoUrl") as! String)
        self.coverPhotoUrl = (currentUser?.valueForKey("coverPhotoUrl") as! String)
        super.init()
        self.is_teacher = "false"
    }
    
    // Moved returnUserData to Home View Controller
    
    // Pretty sure saveLocally didn't actually do anything
    
//    func saveLocally(result: NSDictionary){
//        facebook_id = result.valueForKey("facebook_id") as? String
//        print("FACEBOOK ID")
//        print(facebook_id)
//        username = result.valueForKey("username") as? String
//        print("USERNAME")
//        print(username)
//        email = result.valueForKey("email") as? String
//        profilePhotoUrl = result.valueForKey("profilePhotoUrl") as? String
//        print("profilePhotoUrl")
//        print(profilePhotoUrl)
//        coverPhotoUrl = result.valueForKey("coverPhotoUrl") as? String
//        print("coverPhotoUrl")
//        print(coverPhotoUrl)
//    }
}