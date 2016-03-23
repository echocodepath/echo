//
//  SentViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/14/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class SentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var requestsSentTableView: UITableView!
    
    var requestsSent: Array<PFObject> = []
    
    var refreshControlTableView: UIRefreshControl!
    var parentNavigationController : UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sent"
        requestsSentTableView.delegate = self
        requestsSentTableView.dataSource = self
        self.fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        requestsSentTableView.insertSubview(refreshControlTableView, atIndex: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        let userId = currentPfUser?.objectId
        let predicate  = NSPredicate(format:"userId = '\(userId!)'")
        let requestQuery = PFQuery(className:"FeedbackRequest", predicate: predicate)
        requestQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.requestsSent = []
                    self.requestsSent = objects
                    self.requestsSentTableView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func onRefresh(){
        currentPfUser?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.fetchRequests()
                self.refreshControlTableView.endRefreshing()
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsSent.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentRequests", forIndexPath: indexPath) as! InboxCell
        let request = self.requestsSent[indexPath.row]
        let teacher_name = request.objectForKey("teacher_name") as! String
        let title = request.objectForKey("entry_name") as! String
        let teacherPictureUrl = request.objectForKey("teacher_picture") as! String
        cell.avatarImageView.setImageWithURL(NSURL(string: teacherPictureUrl)!)
        
        let accepted = request.objectForKey("accepted") as! String
        let rejected = request.objectForKey("rejected") as! String
        if accepted == "false" && rejected == "false" {
            cell.inboxTextLabel.attributedText = Utils.createSentInboxText(teacher_name, title: title, status: "pending")
        } else if accepted == "true" {
            cell.inboxTextLabel.attributedText = Utils.createSentInboxText(teacher_name, title: title, status: "accepted")
            cell.accessoryType = .DisclosureIndicator
        } else if rejected == "true" {
            cell.inboxTextLabel.attributedText = Utils.createSentInboxText(teacher_name, title: title, status: "rejected")
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRequest = requestsSent[indexPath.row]
        let accepted = selectedRequest.objectForKey("accepted") as! String
        if accepted == "true" {
            let selectedEntry = selectedRequest.objectForKey("entry") as! PFObject
            let selectedTeacher = selectedRequest.objectForKey("teacher") as! PFObject
            
            selectedEntry.fetchInBackgroundWithBlock({ (entryObject: PFObject?, error:NSError?) -> Void in
                let feedbackStoryboard = UIStoryboard(name: "FeedbackRecording", bundle: nil)
                let feedbackVC = feedbackStoryboard.instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
                feedbackVC.entry = entryObject
                
                //get feedback for entry from specific teacher
                let feedbackQuery = PFQuery(className:"Feedback")
                feedbackQuery.whereKey("entry_id", equalTo: selectedEntry)
                feedbackQuery.whereKey("teacher_id", equalTo: selectedTeacher)
                feedbackQuery.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
                    if error == nil && object != nil {
                        feedbackVC.feedback = object
                        tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        self.parentNavigationController!.pushViewController(feedbackVC, animated: true)
                    }
                }
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */
    

}
