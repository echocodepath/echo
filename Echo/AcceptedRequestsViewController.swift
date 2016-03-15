//
//  AcceptedRequestsViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/14/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class AcceptedRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var acceptedRequestsTableView: UITableView!

    var inboxUser: PFUser?
    var acceptedRequests: Array<Dictionary<String,String>> = []
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        acceptedRequestsTableView.delegate = self
        acceptedRequestsTableView.dataSource = self
        
        fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        acceptedRequestsTableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        do {
            try inboxUser?.fetch()
        } catch {
            print("Error fetching inbox user")
        }
        if let rejected_requests = inboxUser!["requests_accepted"] {
            self.acceptedRequests = rejected_requests as! Array<Dictionary<String,String>>
        }
        acceptedRequestsTableView.reloadData()
    }
    
    func onRefresh(){
        fetchRequests()
        self.refreshControlTableView.endRefreshing()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.acceptedRequests.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AcceptedRequest", forIndexPath: indexPath) as! InboxCell
        let request = self.acceptedRequests[indexPath.row]
        
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
            var student_name = ""
            let studentQuery = PFUser.query()!
            studentQuery.whereKey("facebook_id", equalTo: student_id)
            studentQuery.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    var student_picture = ""
                    if let objects = objects {
                        for object in objects {
                            student_name = object["username"] as! String
                            student_picture = object["profilePhotoUrl"] as! String
                        }
                    }
                    cell.inboxTextLabel.text = "You accepted " + student_name + "'s request for feedback on " + song
                    if let url  = NSURL(string: student_picture),
                        data = NSData(contentsOfURL: url)
                    {
                        cell.avatarImageView.image = UIImage(data: data)
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
