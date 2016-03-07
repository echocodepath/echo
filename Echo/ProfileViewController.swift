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
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = User(user: PFUser.currentUser()!)
        
        if let user = self.user {
            self.nameLabel.text = user.username!
            self.locationLabel.text = "San Francisco, CA"
            self.descriptionLabel.text = "Developer goddess working in San Francisco. When I'm not at Yahoo, you can find me at a dance class or chatting on Slack. Go Bulldogs!"
            
            if let profImage = user.profilePhotoUrl {
                if let url  = NSURL(string: profImage),
                    data = NSData(contentsOfURL: url)
                {
                    self.profilePhoto.image = UIImage(data: data)
                }
                //self.profilePhoto.setImageWithURL(NSURL(string: profImage)!)
            }
            if let coverImage = user.coverPhotoUrl {
                print("coverPhotoUrl")
                print(coverImage)
                if let url  = NSURL(string: coverImage),
                    data = NSData(contentsOfURL: url)
                {
                    self.coverPhoto.image = UIImage(data: data)
                }
                //self.coverPhoto.setImageWithURL(NSURL(string: coverImage)!)
            }
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