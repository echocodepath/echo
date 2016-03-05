//
//  ParseClient.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4


class ParseClient: NSObject {
    var currentUser : PFUser = PFUser.currentUser()!
    
    class var sharedInstance: ParseClient {
        struct Static {
            static let instance =  ParseClient()
        }
        return Static.instance
    }
    
    func setUserValue(key: String, value: String) {
        currentUser[key] = value
        currentUser.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }

    }

}
