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
                self.requestsSent = []
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
        cell.accessoryType = .DisclosureIndicator
        let request = self.requestsSent[indexPath.row]
        let teacher_name = request.objectForKey("user_name") as! String
        let title = request.objectForKey("entry_name") as! String
        let teacherPictureUrl = request.objectForKey("user_picture") as! String
        cell.avatarImageView.setImageWithURL(NSURL(string: teacherPictureUrl)!)
        cell.inboxTextLabel.attributedText = Utils.createSentInboxText(teacher_name, title: title)

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */
    

}
