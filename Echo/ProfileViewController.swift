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
import AFNetworking

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout {
    let DESCRIPTION_PLACEHOLDER = "Add a description"
    
    private var currentUser: PFUser?
    private var profileUser: PFUser? // user depicted in profile NOT current user
    private var isMyProfile: Bool?
    private var isTeacher: String?
    private var entryQuery: PFQuery?

    var entries: [PFObject] = []
    var headerHeight: CGFloat = 334
    var bottomHeaderHeight: CGFloat = 178
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomHeaderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topHeaderComponent: UIView!
    @IBOutlet weak var bottomHeaderComponent: UIView!
    
    @IBOutlet weak var videosCollectionView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func onBackPress(sender: AnyObject) {
        // Save text to user description
        if let currentUser = self.profileUser {
            currentUser["description"] = descriptionTextView.text
            currentUser.saveInBackground()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func addFavorite(sender: AnyObject) {
        let id = profileUser!["facebook_id"] as! String
        if let favorite_teachers = currentUser!["favorite_teachers"] {
            var array = favorite_teachers as! Array<String>
            if !array.contains(id) {
                array.append(id)
                currentUser!["favorite_teachers"] = array
            }
        } else {
            let array = [id]
            currentUser!["favorite_teachers"] = array
        }
        currentUser!.saveInBackground()
    }
    
    func setProfile(user: PFUser?) {
        self.profileUser = user
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videosCollectionView.contentInset = UIEdgeInsets(top: headerHeight - topLayoutGuide.length + 10, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let constraint = NSLayoutConstraint(item: topHeaderComponent, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 74)
        constraint.priority = UILayoutPriorityRequired
        constraint.active = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        
        currentUser = PFUser.currentUser()
        automaticallyAdjustsScrollViewInsets = false
        do {
            try currentUser!.fetch()
        } catch {
            
        }
        
        if let pfUser = self.profileUser {
            isMyProfile = false
            isTeacher = pfUser["is_teacher"] as? String
        } else {
            self.profileUser = currentUser
            isMyProfile = true
            isTeacher = self.profileUser!["is_teacher"] as? String
        }
        
        if let name = self.profileUser!["username"] {
            self.nameLabel.text = name as? String
        }
        
        if let location = profileUser!["location"] {
            self.locationLabel.text = location as? String
        }
        
        if let desc = self.profileUser!["description"] {
            self.descriptionTextView.text = desc as? String
        }
        
        if let profImage =  self.profileUser!["profilePhotoUrl"] {
//            if let url  = NSURL(string: profImage as! String),
//                data = NSData(contentsOfURL: url)
//            {
//                self.profilePhoto.image = UIImage(data: data)
//            }
            self.profilePhoto.setImageWithURL(NSURL(string: profImage as! String)!)
            // Set profile to circle
            self.profilePhoto.layer.borderWidth = 3
            self.profilePhoto.layer.masksToBounds = false
            self.profilePhoto.layer.borderColor = UIColor.blackColor().CGColor
            self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.height/2
            self.profilePhoto.clipsToBounds = true
        }
        if let coverImage =  self.profileUser!["coverPhotoUrl"] {
//            if let url  = NSURL(string: coverImage as! String),
//                data = NSData(contentsOfURL: url)
//            {
//                self.coverPhoto.image = UIImage(data: data)
//            }
            self.coverPhoto.setImageWithURL(NSURL(string: coverImage as! String)!)
        }
        
        if isMyProfile! == true || isTeacher! == "false" {
            favoriteButton.hidden = true
            headerHeight -= 20
            bottomHeaderHeight -= 20
            headerHeightConstraint.constant = headerHeight
            bottomHeaderHeightConstraint.constant = bottomHeaderHeight
        }
        
//            self.favoriteButton.setImage(UIImage(named: "add-favorite") as UIImage?, forState: .Normal)
//            self.favoriteButton.setImage(UIImage(named: "added-favorite") as UIImage?, forState: .Selected)
        
        //if my profile, text view styling and make text view editable
        if isMyProfile == true {
            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            descriptionTextView.layer.borderWidth = 0.5
            descriptionTextView.layer.borderColor = borderColor.CGColor
            descriptionTextView.layer.cornerRadius = 5.0
            self.descriptionTextView.delegate = self
            if self.profileUser!["description"] == nil {
                applyPlaceholderStyle(self.descriptionTextView, placeholderText: DESCRIPTION_PLACEHOLDER)
            }
        } else {
            descriptionTextView.userInteractionEnabled = false
        }
        
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        fetchEntries()
        
        coverPhoto.superview?.sendSubviewToBack(coverPhoto)
    }
    
    // MARK: Entries
    
    func fetchEntries(){

        // Define query for entires for user and NOT private
        let userId = self.profileUser?.objectId as String!

        // Show all user's own videos
        if isMyProfile == true {
            let predicate  = NSPredicate(format:"user_id = '\(userId)' ")
            entryQuery = PFQuery(className:"Entry", predicate: predicate)
        }
        // Only show public videos
        else {
            let predicate  = NSPredicate(format:"user_id = '\(userId)' AND private = false ")
            entryQuery = PFQuery(className:"Entry", predicate: predicate)
        }
        
        
        entryQuery!.findObjectsInBackgroundWithBlock {
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
    
    // MARK: Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.entries.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        let kWidth = 100 as! CGFloat
        let kHeight = 100 as! CGFloat
//        return CGSizeMake(collectionView.bounds.size.width, kHeight)
        return CGSizeMake(kWidth, kHeight)
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = -1 * (scrollView.contentOffset.y + scrollView.contentInset.top)
        
        headerHeightConstraint.constant = max(0, min(headerHeight, headerHeight + offset))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    // MARK: Text View
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 // have text, so don't show the placeholder
        {
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == descriptionTextView && textView.text == DESCRIPTION_PLACEHOLDER
            {
                if text.utf16.count == 0 // they hit the back button
                {
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        }
        else  // no text, so show the placeholder
        {
            applyPlaceholderStyle(textView, placeholderText: DESCRIPTION_PLACEHOLDER)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewShouldBeginEditing(aTextView: UITextView) -> Bool
    {
        if aTextView == descriptionTextView && aTextView.text == DESCRIPTION_PLACEHOLDER
        {
            // move cursor to start
            moveCursorToStart(aTextView)
        }
        return true
    }
    
    func moveCursorToStart(aTextView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(), {
            aTextView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func applyPlaceholderStyle(aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor.lightGrayColor()
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkTextColor()
        aTextview.alpha = 1.0
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