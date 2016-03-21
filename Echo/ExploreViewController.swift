//
//  ExploreViewController.swift
//  Echo
//
//  Created by Andrew Yu on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AVKit
import AVFoundation
import AFNetworking

class ExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var teachersGridView: UICollectionView!
    @IBOutlet weak var entriesGridView: UICollectionView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    var refreshControlTableView: UIRefreshControl!

    var controller: AVPlayerViewController?
    
    var teachers: [PFUser] = []
    var entries: [PFObject] = []
    
    var videoUrl: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        convertVideoDataToNSURL()
        
        teachersGridView.delegate   = self
        teachersGridView.dataSource = self
        entriesGridView.delegate    = self
        entriesGridView.dataSource  = self
        
        // TODO: Implement Parse caching for teachers and entries, way too slow
        fetchInstructors()
        fetchEntries()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        teachersGridView?.insertSubview(refreshControlTableView, atIndex: 0)
        entriesGridView?.insertSubview(refreshControlTableView, atIndex: 0)
        
        teachersGridView.backgroundColor = UIColor.whiteColor()
        entriesGridView.backgroundColor = UIColor.whiteColor()

        if let teacherTayout = teachersGridView.collectionViewLayout as? UICollectionViewFlowLayout {
            teacherTayout.minimumInteritemSpacing = 1
            teacherTayout.minimumLineSpacing = 1
        }
        if let entriesLayout = entriesGridView.collectionViewLayout as? UICollectionViewFlowLayout {
            entriesLayout.minimumInteritemSpacing = 1
            entriesLayout.minimumLineSpacing = 1
        }
    }
    
    @IBAction func onImageTap(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.coverImageView.alpha = 0.0
            self.playVideo(self.videoUrl!)
            
            }, completion: nil)
    }
    
    
    
    private func convertVideoDataToNSURL() {

        let query = PFQuery(className:"Videos")
        query.getObjectInBackgroundWithId("kh5wfqasij") {
            (Video: PFObject?, error: NSError?) -> Void in
            if error == nil && Video != nil {
                print("---------video")
                print(Video)

                let rawData: NSData?
                let videoData = Video!["video"] as! PFFile

                do {
                    rawData = try videoData.getData()
                    self.videoUrl = FileProcessor.sharedInstance.writeVideoDataToFile(rawData!)
//                    self.playVideo(self.videoUrl!)
                } catch {
                    
                }
                
            } else {
                print(error)
            }
        }
    }
    
    
    func fetchInstructors(){
        let teacherQuery = PFUser.query()!
        teacherQuery.whereKey("is_teacher", equalTo: "true")
        teacherQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        let user = object as! PFUser
                        self.teachers.append(user)
                        self.teachersGridView.reloadData()
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    func fetchEntries(){
        let entryQuery = PFQuery(className:"Entry")
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.entries.append(object)
                        self.entriesGridView.reloadData()
                    }
//                    print("These are the entries")
//                    print(self.entries)
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }


        
    }
    func onRefresh(){
        print("I just got refreshed")
        
        self.refreshControlTableView.endRefreshing()
    }
    
    // MARK: Video
    private func playVideo(url: NSURL){
        
        controller = AVPlayerViewController()
        controller!.willMoveToParentViewController(self)
        addChildViewController(controller!)
        view.addSubview(controller!.view)
        controller!.didMoveToParentViewController(self)
        controller!.view.translatesAutoresizingMaskIntoConstraints = false
        controller!.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        controller!.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        controller!.view.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        controller!.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        controller!.view.heightAnchor.constraintEqualToAnchor(controller!.view.widthAnchor, multiplier: 1, constant: 1)
        
        
        
        let player = AVPlayer(URL: url)
        controller!.player = player
        controller!.player!.play()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == teachersGridView {
            return self.teachers.count ?? 0
        } else {
            return self.entries.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView != teachersGridView {
            let kWidth = (collectionView.frame.width * 0.3333) - 1
            return CGSizeMake(kWidth, kWidth)
        } else {
            let kWidth: CGFloat = 100
            return CGSizeMake(kWidth, kWidth)
        }

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == teachersGridView {
            let cell = teachersGridView.dequeueReusableCellWithReuseIdentifier("TeacherCollectionViewCell", forIndexPath: indexPath) as! TeacherCollectionViewCell
            let teacherImage = self.teachers[indexPath.row]["profilePhotoUrl"] as? String
            
            cell.teacherImage.alpha = 0
            cell.teacherImage.setImageWithURL(NSURL(string: teacherImage!)!)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.teacherImage.alpha = 1.0
            })
            
            return cell
        } else {
            let cell = entriesGridView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell
            let entry = self.entries[indexPath.row]
            cell.entry = entry
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if collectionView == teachersGridView {
            let cell = teachersGridView.dequeueReusableCellWithReuseIdentifier("TeacherCollectionViewCell", forIndexPath: indexPath) as! TeacherCollectionViewCell
            performSegueWithIdentifier("exploreToProfile", sender: cell)
        } else {
            let cell = entriesGridView.dequeueReusableCellWithReuseIdentifier("EntryCollectionViewCell", forIndexPath: indexPath) as! EntryCollectionViewCell
            performSegueWithIdentifier("exploreToEntry", sender: cell)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "exploreToProfile":
                    let cell = sender as! TeacherCollectionViewCell
                    if let indexPath = self.teachersGridView.indexPathForCell(cell) {
                        let nc = segue.destinationViewController as! UINavigationController
                        let vc = nc.topViewController as! ProfileViewController
                        vc.setProfile(self.teachers[indexPath.row])
                    }
                
                case "exploreToEntry":
                    let cell = sender as! EntryCollectionViewCell
                    if let indexPath = self.entriesGridView.indexPathForCell(cell) {
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
