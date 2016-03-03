//
//  User.swift
//  Echo
//
//  Created by Christine Hong on 3/3/16.
//  Copyright © 2016 echo. All rights reserved.
//

var _currentUser: User?

class User {
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
    init() {
        self.user_id = 1
        self.name = "Christine Hong"
        self.is_teacher = false
        self.email = "christinehong802@yahoo.com"
        
        self.description = "Developer goddess working in San Francisco. When I'm not at Yahoo, you can find me at dance class or chatting on Slack. Go Bulldogs!"
        self.location = "San Francisco, CA"
            
        self.profilePhotoUrl = "https://scontent.xx.fbcdn.net/hphotos-xfp1/v/t1.0-9/12644925_10156509229420300_8758902001126843590_n.jpg?oh=c4ddbe9693d71c03f6c30f43c6a6b360&oe=576A4774"
        self.coverPhotoUrl = "http://farm3.static.flickr.com/2696/4493696552_25a70c44dd.jpg"
        
        if (self.is_teacher != nil) {
            print("HI I'M A TEACHER")
            self.estimated_wait = 10
            self.cost = 10
        }
    }
    
}

