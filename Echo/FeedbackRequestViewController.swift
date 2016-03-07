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

class FeedbackRequestViewController: UIViewController {
    
    @IBOutlet weak var teacherFeedbackList: UITableView!
    @IBOutlet weak var teacherFeedback: UITableViewCell!
    
    var teachers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let query = PFQuery(className:"User")
//        query.whereKey("is_teacher", equalTo: true)
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                // The find succeeded.
//                print("Successfully retrieved \(objects!.count) teachers.")
//                // Do something with the found objects
//                if let objects = objects {
//                    for object in objects {
//                        let user = User(user: object as! PFUser)
//                        self.teachers.append(user)
//                        print(object.objectId)
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
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
            cell.teacherName.text = self.teachers[indexPath.row].username
        } else {
            cell.teacherName.text = "Please add some favorite teachers"
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("feedbackSentSegue", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "feedbackSentSegue":
                if let indexPath = self.teacherFeedbackList.indexPathForSelectedRow {
                    let vc = segue.destinationViewController as! FeedbackRequestSentViewController
                    vc.setTeacher(self.teachers[indexPath.row])
                }
                
            default:
                return
        }
        
    }
    

}
