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
    
    var inboxUser: PFUser?
    var requestsReceived: Array<Dictionary<String,String>> = []
    var refreshControlTableView: UIRefreshControl!
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "journal_bg_1x_1024"))
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        if let requests_received = inboxUser!["requests_received"] {
            self.requestsReceived = requests_received as! Array<Dictionary<String,String>>
        }
        tableView.reloadData()
    }
    
    func onRefresh(){
        print("I just got refreshed")
        fetchRequests()
        self.refreshControlTableView.endRefreshing()
    }
    
    
    // MARK: Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsReceived.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReceivedRequests", forIndexPath: indexPath) as! InboxCell
        let request = self.requestsReceived[indexPath.row]
        
        if let id = request["entry_id"] {
            let entry_id = id as String
            var title = ""
            let entryQuery = PFQuery(className:"Entry")
            entryQuery.getObjectInBackgroundWithId(entry_id) {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    let entry = object
                    title = entry!["title"] as! String
                } else {
                    print(error)
                }
            }
            
            let student_id = request["user_id"]! as String
            var student_name = ""
            let studentQuery = PFUser.query()!
            studentQuery.getObjectInBackgroundWithId(student_id) {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    var student_picture = ""
                    student_name = object!["username"] as! String
                    student_picture = object!["profilePhotoUrl"] as! String
                    cell.inboxTextLabel.text = student_name + " would like feedback on " + title
                    cell.avatarImageView.setImageWithURL(NSURL(string: student_picture)!)
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
//                    cell.inboxTextLabel.text = student_name + " would like feedback on " + song
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
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//
//        let inboxDetailsViewController = self.storyboard!.instantiateInitialViewController("InboxDetailsViewController") as! InboxDetailsViewController
//
//        let request = requestsReceived[indexPath.row]
////        InboxDetailsViewController.request = request
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        self.navigationController?.pushViewController("InboxDetailsViewController", animated: true)
//        
//        
//
//        if self.requestsReceived.count > 0 {
//            performSegueWithIdentifier("inboxDetails", sender: self)
//        }
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let inboxDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InboxDetailsViewController") as! InboxDetailsViewController
//        let entry = entries[indexPath.row]
//        entryViewController.entry = entry
        
        let request = requestsReceived[indexPath.row]

        inboxDetailsViewController.request = request
        
        print("this is the request")
        print(request)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(inboxDetailsViewController, animated: true)
    }
    

    
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
    

}
