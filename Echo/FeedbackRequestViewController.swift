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
    var teachers: [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let teacher_ids = PFUser.currentUser()?.objectForKey("favorite_teachers") as! NSArray
        
        // TODO: Find better way to reload tableView
        for id in teacher_ids {
            let query = PFUser.query()!
            query.whereKey("facebook_id", equalTo: id)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) teachers.")
                    // Do something with the found objects
                    if let objects = objects {
                        for object in objects {
                            self.teachers.append(object)
                        }
                    }
                    self.tableView.reloadData()
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            cell.teacherName.text = self.teachers[indexPath.row]["username"] as? String
        } else {
            cell.teacherName.text = "Please add some favorite teachers"
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.teachers.count > 0 {
            performSegueWithIdentifier("feedbackSentSegue", sender: self)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "feedbackSentSegue":
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let vc = segue.destinationViewController as! FeedbackRequestSentViewController
                    vc.setTeacher(self.teachers[indexPath.row])
                }
                
            default:
                return
        }
        
    }
    

}
