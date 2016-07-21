//
//  TeacherViewController.swift
//  Echo
//
//  Created by Christine Hong on 6/24/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class TeacherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var teachers: [PFUser] = []
    @IBOutlet weak var tableView: UITableView!
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTeachers()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    func onRefresh(){
        loadTeachers()
        self.refreshControlTableView.endRefreshing()
    }
    
    func loadTeachers() {
        let teacherQuery = PFUser.query()!
        teacherQuery.whereKey("is_teacher", equalTo: "true")
        teacherQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.teachers = []
                    let myId = currentPfUser!.objectId
                    for object in objects {
                        let user = object as! PFUser
                        if user.objectId! != myId! {
                            self.teachers.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TeacherTableViewCell", forIndexPath: indexPath) as! TeacherTableViewCell
        let teacher = self.teachers[indexPath.row]
        cell.teacher = teacher
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teachers.count ?? 0
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        performSegueWithIdentifier("teacherToProfileSegue", sender: self)
//        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
            case "teacherToProfileSegue":
                if let indexPath = self.tableView.indexPathForSelectedRow{
                    let vc = segue.destinationViewController as! ProfileViewController
                    vc.profileUser = self.teachers[indexPath.row]
                }
                
                
            default:
                return
            }
        }
    }
    

}
