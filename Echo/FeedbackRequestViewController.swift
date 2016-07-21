//
//  FeedbackRequestViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class FeedbackRequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructorHeadView: UIView!
    var refreshControlTableView: UIRefreshControl!
    
    var teachers: [PFObject] = []
    var entry: PFObject?
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        fetchTeachers()
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
    }
    
    func fetchTeachers() {
        let entryQuery = PFQuery(className:"Favorite")
        entryQuery.whereKey("favoriter", equalTo: currentPfUser!)
        
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.teachers = []
                    self.teachers = objects
                }
                self.tableView.reloadData()
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    func onRefresh(){
        fetchTeachers()
        self.refreshControlTableView.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFeedbackEntry(entry: PFObject?) {
        self.entry = entry
    }
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.teachers.count > 0 {
            return self.teachers.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TeacherFeedbackCell", forIndexPath: indexPath) as! TeacherFeedbackCell
        if self.teachers.count > 0 {
            let teacher = self.teachers[indexPath.row]
            cell.profileImageLabel.alpha = 0
            let url = NSURL(string: (teacher.objectForKey("profileUrl") as? String)!)
            cell.teacherName.text = teacher.objectForKey("username") as? String
            cell.locationLabel.text = teacher.objectForKey("location") as? String
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.profileImageLabel.setImageWithURL(url!)
                cell.profileImageLabel.alpha = 1
            })
        } else {
            cell.teacherName.text = "Please add some favorite teachers below"
        }
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.teachers.count > 0 {
            performSegueWithIdentifier("feedbackDetailsSegue", sender: self)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "feedbackDetailsSegue":
                    if let indexPath = self.tableView.indexPathForSelectedRow {
                        let vc = segue.destinationViewController as! FeedbackRequestDetailsViewController
                        let favorite = self.teachers[indexPath.row].objectForKey("favorited") as! PFUser
                        vc.updateTeacher(favorite)
                        vc.entry = self.entry!
//                        vc.updateEntry(self.entry!)
                    }
                    
                default:
                    return
            }
        }
        
    }
    

}
