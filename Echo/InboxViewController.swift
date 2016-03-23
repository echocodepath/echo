//
//  InboxViewController.swift
//  Echo
//
//  Created by Andrew Yu on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AFNetworking

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var requestsReceived: Array<PFObject> = []
    
    var refreshControlTableView: UIRefreshControl!
    var parentNavigationController : UINavigationController?

    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Received"
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchRequests()
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        let userId = currentPfUser?.objectId
        let predicate  = NSPredicate(format:"teacherId = '\(userId!)' AND accepted = 'false' AND rejected = 'false'")
        let requestQuery = PFQuery(className:"FeedbackRequest", predicate: predicate)
        requestQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.requestsReceived = []
                    self.requestsReceived = objects
                    self.tableView.reloadData()
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
    
    
    // MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsReceived.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceivedRequests", forIndexPath: indexPath) as! InboxCell
        let request = self.requestsReceived[indexPath.row]
        let student_name = request.objectForKey("user_name") as! String
        let title = request.objectForKey("entry_name") as! String
        let studentPictureUrl = request.objectForKey("user_picture") as! String
        cell.avatarImageView.setImageWithURL(NSURL(string: studentPictureUrl)!)
        cell.inboxTextLabel.attributedText = Utils.createNormalInboxText(student_name, title: title)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let inboxDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InboxDetailsViewController") as! InboxDetailsViewController
        let request = requestsReceived[indexPath.row]
        inboxDetailsViewController.request = request
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.parentNavigationController!.pushViewController(inboxDetailsViewController, animated: true)
    }
    
    
    /*
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "inboxDetails":
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let nc = segue.destinationViewController as! UINavigationController
                    let vc = nc.topViewController as! InboxDetailsViewController
                    vc.setFeedbackRequest(self.requestsReceived[indexPath.row])
                }
                
            default:
                return
            }
        }
    }
    */
    

}
