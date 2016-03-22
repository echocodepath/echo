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
    
    var acceptedRequests: Array<PFObject> = []
    
    var refreshControlTableView: UIRefreshControl!
    var parentNavigationController : UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Accepted"
        acceptedRequestsTableView.delegate = self
        acceptedRequestsTableView.dataSource = self
        self.fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        acceptedRequestsTableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        let userId = currentPfUser?.objectId
        let predicate  = NSPredicate(format:"teacherId = '\(userId!)' AND accepted = 'true'")
        let requestQuery = PFQuery(className:"FeedbackRequest", predicate: predicate)
        requestQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.acceptedRequests = objects
                    self.acceptedRequestsTableView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func onRefresh(){
        currentPfUser?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.acceptedRequests = []
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
        cell.accessoryType = .DisclosureIndicator
        let request = self.acceptedRequests[indexPath.row]
        let student_name = request.objectForKey("user_name") as! String
        let title = request.objectForKey("entry_name") as! String
        let studentPictureUrl = request.objectForKey("user_picture") as! String
        cell.avatarImageView.setImageWithURL(NSURL(string: studentPictureUrl)!)
        cell.inboxTextLabel.attributedText = Utils.createAcceptedInboxText(student_name, title: title)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRequest = acceptedRequests[indexPath.row]
        let selectedEntry = selectedRequest.objectForKey("entry") as! PFObject

        let feedbackStoryboard = UIStoryboard(name: "FeedbackRecording", bundle: nil)
        let feedbackVC = feedbackStoryboard.instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
        feedbackVC.entry = selectedEntry
        
        //get feedback for entry from specific teacher
        let feedbackQuery = PFQuery(className:"Feedback")
        feedbackQuery.whereKey("entry_id", equalTo: selectedEntry)
        feedbackQuery.whereKey("teacher_id", equalTo: currentPfUser!)
//        feedbackQuery.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
//            if error == nil && object != nil {
//                feedbackVC.feedback = object
//                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//                self.parentNavigationController!.pushViewController(feedbackVC, animated: true)
//            }
//        }
        feedbackQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        feedbackVC.feedback = object
                        tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        self.parentNavigationController!.pushViewController(feedbackVC, animated: true)
                        return
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
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
