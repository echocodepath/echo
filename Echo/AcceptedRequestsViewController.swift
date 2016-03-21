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
    var parentNavigationController : UINavigationController?
    var inboxUser: PFUser?
    var acceptedRequests: Array<Dictionary<String,String>> = []
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.fetchRequests()
            }
        })
        self.title = "Accepted"
        acceptedRequestsTableView.delegate = self
        acceptedRequestsTableView.dataSource = self
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        acceptedRequestsTableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        if let rejected_requests = inboxUser!["requests_accepted"] {
            self.acceptedRequests = rejected_requests as! Array<Dictionary<String,String>>
        }
        acceptedRequestsTableView.reloadData()
    }
    
    func onRefresh(){
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.fetchRequests()
                self.refreshControlTableView.endRefreshing()
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.acceptedRequests.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AcceptedRequest", forIndexPath: indexPath) as! InboxCell
        let request = self.acceptedRequests[indexPath.row]
        
        if let id = request["entry_id"] {
            let entry_id = id as String
            var title = ""
            let entryQuery = PFQuery(className:"Entry")
            let student_id = request["user_id"]! as String
            var student_name = ""
            let studentQuery = PFUser.query()!
            studentQuery.getObjectInBackgroundWithId(student_id) {
                (userObject: PFObject?, error: NSError?) -> Void in
                if error == nil && userObject != nil {
                    let object = userObject as! PFUser
                    var student_picture = ""
                    student_name = object["username"] as! String
                    student_picture = object["profilePhotoUrl"] as! String
                    cell.avatarImageView.setImageWithURL(NSURL(string: student_picture)!)
                    entryQuery.getObjectInBackgroundWithId(entry_id) {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error == nil && object != nil {
                            let entry = object
                            title = entry!["title"] as! String
                            cell.inboxTextLabel.attributedText = Utils.createAcceptedInboxText(student_name, title: title)
                        } else {
                            print(error)
                        }
                    }
                } else {
                    print(error)
                }
            }
//            studentQuery.whereKey("facebook_id", equalTo: student_id)
//            studentQuery.findObjectsInBackgroundWithBlock {
//                (objects: [PFObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    var student_picture = ""
//                    if let objects = objects {
//                        for object in objects {
//                            student_name = object["username"] as! String
//                            student_picture = object["profilePhotoUrl"] as! String
//                        }
//                    }
//                    cell.inboxTextLabel.text = "You accepted " + student_name + "'s request for feedback on " + song
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRequest = acceptedRequests[indexPath.row]
        let selectedId = selectedRequest["entry_id"]
        let entryQuery = PFQuery(className:"Entry")
        entryQuery.getObjectInBackgroundWithId(selectedId!) {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                let selectedEntry = object!
                let feedbackStoryboard = UIStoryboard(name: "FeedbackRecording", bundle: nil)
                let feedbackVC = feedbackStoryboard.instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
                feedbackVC.entry = selectedEntry
                
                let feedbackQuery = PFQuery(className:"Feedback")
                feedbackQuery.whereKey("entry_id", equalTo: selectedEntry)
                feedbackQuery.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        if let objects = objects {
                            for object in objects {
                                feedbackVC.feedback = object
                                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                                self.navigationController?.pushViewController(feedbackVC, animated: true)
                                return
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            } else {
                print(error)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
