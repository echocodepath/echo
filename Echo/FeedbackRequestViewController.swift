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
    
    var teachers: Array<PFUser> = []
    var entry: PFObject?
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        if let favorite_teachers = currentPfUser!["favorite_teachers"] {
            self.teachers = []
            self.teachers = favorite_teachers as! Array<PFUser>
            self.tableView.reloadData()
        }
    }
    
    func onRefresh(){
        currentPfUser?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.fetchTeachers()
                self.refreshControlTableView.endRefreshing()
            }
        })
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
            cell.teacher = self.teachers[indexPath.row]
        } else {
            cell.teacherName.text = "Please add some favorite teachers"
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
                        let nc = segue.destinationViewController as! UINavigationController
                        let vc = nc.topViewController as! FeedbackRequestDetailsViewController
                        vc.updateTeacher(self.teachers[indexPath.row])
                        vc.updateEntry(self.entry!)
                    }
                    
                default:
                    return
            }
        }
        
    }
    

}
