//
//  ProfileViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/5/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import AFNetworking
import Parse
import ParseFacebookUtilsV4

class ProfileViewController: UIViewController {
    private var user: User?

    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User(user: PFUser.currentUser()!)
        //user = User.currentUser
        
        print("--------USER----------")
        
        if let user = self.user {
            self.nameLabel.text = user.username!
            print("NAME LABEL")
            print(user.username)
            self.locationLabel.text = "San Francisco, CA"
            self.descriptionLabel.text = "Developer goddess working in San Francisco. When I'm not at Yahoo, you can find me at a dance class or chatting on Slack. Go Bulldogs!"
//            if let profImage = user.profilePhotoUrl {
//                print("PROF IMAGE")
//                print(profImage)
//                self.profilePhoto.setImageWithURL(NSURL(string: profImage)!)
//            }
//            if let coverImage = user.coverPhotoUrl {
//                self.coverPhoto.setImageWithURL(NSURL(string: coverImage)!)
//            }
        }
        
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