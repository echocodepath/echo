//
//  User.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

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
    var user_id: Int?
    var name: String?
    var is_teacher: Bool?
    var email: String?
    var description: String?
    var location: String?
    var profilePhotoUrl: String?
    var coverPhotoUrl: String?
    var estimated_wait: Int?
    var cost: Int?
    
    // TODO: Fake hardcoded User info to be filled for real by Isis later
    init(userDict: NSDictionary) {
        print(userDict)
    }
    
    class var currentUser: User? {
        get {
            if let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData {
            do {
                let data = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as! NSDictionary
                User.currentUser = User(dictionary: data)
            } catch {
                print("Failed getting JSON object with data")
            }
        }
        
        return _currentUser
        }
        
        set(user) {
            _currentUser = user
            if user != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject((user?.dictionary)!, options: NSJSONWritingOptions(rawValue: 0))
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print("Failed getting data with JSON object")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}
