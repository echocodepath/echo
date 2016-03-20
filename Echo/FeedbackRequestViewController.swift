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
    
    var currentUser: PFUser?
    var teachers: [PFObject] = []
    var entry: PFObject?
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()
        currentUser?.fetchInBackground()
        
        tableView.dataSource = self
        tableView.delegate = self

        instructorHeadView.backgroundColor = UIColor.clearColor()
        
        let teacher_ids: [String]
        if let favorite_teachers = currentUser!["favorite_teachers"] {
            teacher_ids = favorite_teachers as! [String]
            // TODO: Find better way to reload tableView
            for id in teacher_ids {
                let query = PFUser.query()!
                query.getObjectInBackgroundWithId(id) {
                    (userObject: PFObject?, error: NSError?) -> Void in
                    if error == nil && userObject != nil {
                        self.teachers.append(userObject!)
                        self.tableView.reloadData()
                    } else {
                        print(error)
                    }
                }
//                query.whereKey("facebook_id", equalTo: id)
//                query.findObjectsInBackgroundWithBlock {
//                    (objects: [PFObject]?, error: NSError?) -> Void in
//                    
//                    if error == nil {
//                        if let objects = objects {
//                            for object in objects {
//                                self.teachers.append(object)
//                            }
//                        }
//                        self.tableView.reloadData()
//                    } else {
//                        print("Error: \(error!) \(error!.userInfo)")
//                    }
//                }
            }
        }
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
