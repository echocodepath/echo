//
//  FBClient.swift
//  Echo
//
//  Created by Isis Anchalee on 3/8/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class FBClient: NSObject {
    class var sharedInstance: FBClient {
        struct Static {
            static let instance =  FBClient()
        }
        return Static.instance
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
}
