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
import SnapKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout {
    var videoEdgeInset: CGFloat = 396
    
    @IBDesignable
    class ProfileHeader: UIView {
        let guideView: UIView = UIView()
        let favoriteButton: UIButton = {
            let button = UIButton(type: .System)
            button.setTitle("Favorite", forState: .Normal)
            button.backgroundColor = StyleGuide.Colors.echoTeal
            button.tintColor = UIColor.whiteColor()
            button.contentEdgeInsets = UIEdgeInsetsMake(4,12,4,12)
            button.layer.masksToBounds = false
            button.layer.cornerRadius = 14
            button.titleLabel?.font = UIFont(name: button.titleLabel!.font.fontName, size: 13)
            return button
        }()
        let coverPhoto: UIImageView = {
            let view = UIImageView()
            view.contentMode = .ScaleAspectFill
            
            // TODO: Shadow won't work unless this is set to false
            // But that will cause the image to not be clipped
            // Need to add a container view for this for shadowing.
            view.clipsToBounds = true
            view.image = UIImage(named: "login_background")
            return view
        }()
        let profilePhotoFrame: UIView = {
            let view = UIView()
            return view
        }()
        let profilePhoto: UIImageView = {
            let view = UIImageView()
            view.contentMode = .ScaleAspectFit
            return view
        }()
        let nameLabel: UILabel = {
            let label = UILabel()
            label.textColor = StyleGuide.Colors.echoTranslucentClear
            label.font = label.font.fontWithSize(18)
            label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
            return label
        }()
        let locationLabel: UILabel = {
            let label = UILabel()
            label.textColor = StyleGuide.Colors.echoTranslucentClear
            label.font = label.font.fontWithSize(13)
            return label
        }()
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.textColor = StyleGuide.Colors.echoTranslucentClear
            label.numberOfLines = 0
            label.font = label.font.fontWithSize(13)
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        let headerHeight: CGFloat = 180
        let profilePhotoDiameter: CGFloat = 100
        let padding: CGFloat = 8
        
        private var scrollConstraint: Constraint?
        var constraintsToHideFavorite = Array<Constraint>()
        
        var scrollOffset: CGFloat = 0 {
            didSet {
                scrollConstraint?.updateOffset(scrollOffset)
                coverPhoto.layer.shadowOpacity = Float(max(0.0, min(0.4, abs(scrollOffset / headerHeight))))
            }
        }
        
        private func setupLayout() {
            backgroundColor = UIColor(patternImage: UIImage(named: "profile_background")!)
            addSubview(guideView)
            addSubview(coverPhoto)
            addSubview(profilePhotoFrame)
            profilePhotoFrame.addSubview(profilePhoto)
            addSubview(nameLabel)
            addSubview(locationLabel)
            addSubview(descriptionLabel)
            addSubview(favoriteButton)
            
            guideView.snp_makeConstraints { make in
                scrollConstraint = make.top.equalTo(self).constraint
                make.left.right.equalTo(self)
                make.height.equalTo(headerHeight)
            }
            
            
            coverPhoto.snp_makeConstraints { make in
                make.top.equalTo(self).priority(UILayoutPriorityDefaultHigh - 1)
                make.height.equalTo(headerHeight).priority(UILayoutPriorityDefaultHigh + 1)
                make.left.right.equalTo(self)
                make.bottom.equalTo(guideView).priority(UILayoutPriorityDefaultHigh)
                make.bottom.greaterThanOrEqualTo(self.snp_top).offset(64).priority(UILayoutPriorityDefaultHigh + 1)
            }
            profilePhotoFrame.snp_makeConstraints { make in
                make.centerX.equalTo(self)
                make.centerY.equalTo(guideView.snp_bottom)
                make.height.width.equalTo(profilePhotoDiameter + 6)
            }
            profilePhoto.snp_makeConstraints { make in
                make.edges.equalTo(profilePhotoFrame).inset(6)
            }
            nameLabel.snp_makeConstraints { make in
                make.centerX.equalTo(self)
                make.top.equalTo(profilePhotoFrame.snp_bottom).offset(padding)
            }
            locationLabel.snp_makeConstraints { make in
                make.centerX.equalTo(self)
                make.top.equalTo(nameLabel.snp_bottom)
            }
            descriptionLabel.snp_makeConstraints { make in
                make.top.equalTo(locationLabel.snp_bottom).offset(6)
                make.centerX.equalTo(self)
                make.left.greaterThanOrEqualTo(self).inset(padding)
                make.right.lessThanOrEqualTo(self).inset(padding)
                constraintsToHideFavorite.append(make.bottom.equalTo(self).inset(padding).priority(UILayoutPriorityDefaultHigh + 1).constraint)
            }
            
            favoriteButton.snp_makeConstraints { make in
                make.centerX.equalTo(self)
                make.top.equalTo(descriptionLabel.snp_bottom).offset(padding)
                make.bottom.equalTo(self).inset(padding)
            }
            
            constraintsToHideFavorite.forEach({ $0.deactivate() })
            bringSubviewToFront(coverPhoto)
            bringSubviewToFront(profilePhotoFrame)
            
            let layer = coverPhoto.layer
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 5
            
            scrollOffset = 0
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let layer = coverPhoto.layer
            layer.shadowPath = UIBezierPath(rect: coverPhoto.bounds).CGPath
            profilePhotoFrame.backgroundColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.4)
            profilePhotoFrame.layer.borderWidth = 2
            profilePhotoFrame.layer.masksToBounds = false
            profilePhotoFrame.layer.borderColor = StyleGuide.Colors.echoLightOrange.CGColor
            profilePhotoFrame.layer.cornerRadius = profilePhotoFrame.frame.height / 2
            profilePhoto.clipsToBounds = true
            
            profilePhoto.layer.masksToBounds = false
            profilePhoto.layer.borderColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.7).CGColor
            profilePhoto.layer.cornerRadius = 50
            profilePhoto.layer.masksToBounds = true
        }
    }
    
    
    let DESCRIPTION_PLACEHOLDER = "Add a description"
    
    private var currentUser: PFUser?
    private var profileUser: PFUser? // user depicted in profile NOT current user
    private var isMyProfile: Bool?
    private var isTeacher: String?
    private var entryQuery: PFQuery?

    var entries: [PFObject] = []
    var hiddenProfilePhoto = false
    private var lastContentOffset: CGFloat = 0
    
    @IBOutlet weak var videosCollectionView: UICollectionView!
    lazy var header: ProfileHeader = ProfileHeader(frame: CGRect.zero)
    
    @IBAction func onBackPress(sender: AnyObject) {
        // Save text to user description
        if let currentUser = self.profileUser {
            currentUser["description"] = self.header.descriptionLabel.text
            currentUser.saveInBackground()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func addFavorite(sender: AnyObject) {
        let id = self.profileUser?.objectId as String!
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
        if header.scrollOffset == 0 {
            videosCollectionView.contentInset = UIEdgeInsets(top: header.bounds.height + 2, left: 0, bottom: 0, right: 0)
        } else {
            videosCollectionView.contentInset = UIEdgeInsets(top: videoEdgeInset - topLayoutGuide.length + 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(header)
        header.snp_makeConstraints { make in
            make.top.left.right.equalTo(view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videosCollectionView.backgroundColor = UIColor.whiteColor()
        if let layout = videosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
        }
        
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
            self.header.nameLabel.text = name as? String
        }
        
        if let location = profileUser!["location"] {
            self.header.locationLabel.text = location as? String
        }
        
        if self.profileUser!["description"] != nil {
            self.header.descriptionLabel.text = self.profileUser!["description"] as? String
        }
        
        if let profImage =  self.profileUser!["profilePhotoUrl"] {
            self.header.profilePhoto.setImageWithURL(NSURL(string: profImage as! String)!)
            // Set profile to circle

        }
        if let coverImage =  self.profileUser!["coverPhotoUrl"] {
            self.header.coverPhoto.setImageWithURL(NSURL(string: coverImage as! String)!)
        }
        
        if isMyProfile! == true || isTeacher! == "false" {
            self.header.favoriteButton.hidden = true
            self.header.constraintsToHideFavorite.forEach({ $0.activate() })
        }
        
//            self.favoriteButton.setImage(UIImage(named: "add-favorite") as UIImage?, forState: .Normal)
//            self.favoriteButton.setImage(UIImage(named: "added-favorite") as UIImage?, forState: .Selected)
        
        if isMyProfile == true {
//            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
//            self.header.descriptionLabel.layer.borderWidth = 0.5
//            self.header.descriptionLabel.layer.borderColor = borderColor.CGColor
//            self.header.descriptionLabel.layer.cornerRadius = 5.0
            if self.profileUser!["description"] == nil {
                self.header.descriptionLabel.text = DESCRIPTION_PLACEHOLDER
            }
        }
        
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        fetchEntries()
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
                        self.videosCollectionView.reloadData()
                    }
                }
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

        let kWidth = (collectionView.frame.width * 0.3333) - 1
//        return CGSizeMake(collectionView.bounds.size.width, kHeight)
        return CGSizeMake(kWidth, kWidth)
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
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // moving up
            if hiddenProfilePhoto == true && offset > -50 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.header.profilePhotoFrame.alpha = 1
                    self.hiddenProfilePhoto = false
                })
            }
        } else if (self.lastContentOffset < scrollView.contentOffset.y){
        // moving down
            if hiddenProfilePhoto == false && offset < -125 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.header.profilePhotoFrame.alpha = 0
                    self.hiddenProfilePhoto = true
                })
            }
        }
    
        self.lastContentOffset = scrollView.contentOffset.y
        
        header.scrollOffset = min(0, offset)
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
            if textView == self.header.descriptionLabel && textView.text == DESCRIPTION_PLACEHOLDER
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
        if aTextView == self.header.descriptionLabel && aTextView.text == DESCRIPTION_PLACEHOLDER
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