//
//  User.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

//
//  User.swift
//  Echo
//
//  Created by Christine Hong on 3/3/16.
//  Copyright © 2016 echo. All rights reserved.
//

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"

class User: NSObject {
    var facebook_id: String?
    var username: String?
    var is_teacher: Bool?
    var email: String?
    var profilePhotoUrl: String?
    var coverPhotoUrl: String?
    
    init(user: PFUser) {
        super.init()
        returnUserData()
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil) {
                print("Error: \(error)")
            } else {
                self.facebook_id = result.valueForKey("id") as? String
                self.username = result.valueForKey("name") as? String
                self.email = result.valueForKey("email") as? String
                self.profilePhotoUrl = "https://graph.facebook.com/\(self.facebook_id)/picture?width=300&height=300"
                self.coverPhotoUrl = "https://graph.facebook.com/\(FBSDKAccessToken.currentAccessToken().userID)/cover?"
            }
        })
    }
}
