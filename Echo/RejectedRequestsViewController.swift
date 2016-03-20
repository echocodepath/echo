//
//  RejectedRequestsViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/14/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class RejectedRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var rejectedRequestsTableView: UITableView!

    var inboxUser: PFUser?
    var rejectedRequests: Array<Dictionary<String,String>> = []
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        rejectedRequestsTableView.delegate = self
        rejectedRequestsTableView.dataSource = self
        
        fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        rejectedRequestsTableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        if let rejected_requests = inboxUser!["requests_rejected"] {
            self.rejectedRequests = rejected_requests as! Array<Dictionary<String,String>>
        }
        rejectedRequestsTableView.reloadData()
    }
    
    func onRefresh(){
        fetchRequests()
        self.refreshControlTableView.endRefreshing()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rejectedRequests.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RejectedRequest", forIndexPath: indexPath) as! InboxCell
        
        var request = self.rejectedRequests[indexPath.row]
        
        if let id = request["entry_id"] {
            let entry_id = id as String
            var song = ""
            let entryQuery = PFQuery(className:"Entry")
            do {
                let entry = try entryQuery.getObjectWithId(entry_id)
                song = entry["song"] as! String
            } catch {
                print("Error getting entry from inbox")
            }
            
            let student_id = request["user_id"]! as String
            let studentQuery = PFUser.query()!
            studentQuery.getObjectInBackgroundWithId(student_id) {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    var student_name = ""
                    var student_picture = ""
                    student_name = object!["username"] as! String
                    student_picture = object!["profilePhotoUrl"] as! String
                    cell.inboxTextLabel.text = "Rejected request on " + song + " from " + student_name
                    cell.avatarImageView.setImageWithURL(NSURL(string: student_picture)!)
                } else {
                    print(error)
                }
            }
//            studentQuery.whereKey("facebook_id", equalTo: student_id)
//            studentQuery.findObjectsInBackgroundWithBlock {
//                (objects: [PFObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    var student_name = ""
//                    var student_picture = ""
//                    if let objects = objects {
//                        for object in objects {
//                            student_name = object["username"] as! String
//                            student_picture = object["profilePhotoUrl"] as! String
//                        }
//                    }
//                    cell.inboxTextLabel.text = "Rejected request on " + song + " from " + student_name
//                    if let url  = NSURL(string: student_picture),
//                        data = NSData(contentsOfURL: url)
//                    {
//                        cell.avatarImageView.image = UIImage(data: data)
//                    }
//                } else {
//                    print("Error: \(error!) \(error!.userInfo)")
//                }
//            }
        }
        return cell
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */


}
