//
//  ProfileViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/5/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    private var user: User?
    private var profileUser: PFUser?
    private var isMyProfile: Bool?
    private var isTeacher: String?

    var entries: [PFObject] = []

    @IBOutlet weak var videosCollectionView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addFavorite(sender: AnyObject) {
        if let currentUser = PFUser.currentUser() {
            if let user = self.user {
                let id = user.facebook_id!
                if let favorite_teachers = currentUser["favorite_teachers"] {
                    var array = favorite_teachers as! Array<String>
                    if !array.contains(id) {
                        array.append(id)
                        currentUser["favorite_teachers"] = array
                    }
                } else {
                    let array = [id]
                    currentUser["favorite_teachers"] = array
                }
                currentUser.saveInBackground()
            }
        }
    }
    
    func setProfile(user: PFUser?) {
        self.profileUser = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pfUser = self.profileUser {
            user = User(user: pfUser)
            isMyProfile = false
            isTeacher = pfUser["is_teacher"] as?String
        } else {
            self.profileUser = PFUser.currentUser()
            user = User(user: self.profileUser!)
            isMyProfile = true
            isTeacher = self.profileUser!["is_teacher"] as?String
        }
        
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
            
            if isMyProfile! == true || isTeacher! == "false" {
                favoriteButton.hidden = true
            }
            
//            self.favoriteButton.setImage(UIImage(named: "add-favorite") as UIImage?, forState: .Normal)
//            self.favoriteButton.setImage(UIImage(named: "added-favorite") as UIImage?, forState: .Selected)
        }
        

        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        fetchEntries()
    }
    
    func fetchEntries(){

        // Define query for entires for user and NOT private
        let userId     = self.profileUser?.objectId as String!
        let predicate  = NSPredicate(format:"user_id = '\(userId)' AND private = false ")
        let entryQuery = PFQuery(className:"Entry", predicate: predicate)

        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.entries.append(object)
                    }
                }
                self.videosCollectionView.reloadData()
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.entries.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = videosCollectionView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell

        let entry = self.entries[indexPath.row]
        cell.entry = entry

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = videosCollectionView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell
        performSegueWithIdentifier("profileToEntry", sender: cell)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "profileToEntry":
                    let cell = sender as! EntryCollectionViewCell
                    if let indexPath = self.videosCollectionView.indexPathForCell(cell) {
                        let nc = segue.destinationViewController as! UINavigationController
                        let vc = nc.topViewController as! EntryViewController
                        vc.updateEntry(self.entries[indexPath.row])
                    }
                    
                default:
                    return
            }
        }
    }
    

}