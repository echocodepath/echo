//
//  InboxDetailsViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/8/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AFNetworking

class InboxDetailsViewController: UIViewController {
    var inboxUser: PFUser?
    var request : [String: String]?
    var currentEntry : PFObject?
    var entryId: String?
    var userId: String? // id of user who sent request
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var requestBodyLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        entryId = self.request!["entry_id"]! as String
        self.requestBodyLabel.text = self.request!["request_body"]
        self.setEntryLabels()
    }
    
    func setEntryLabels() {
        let query = PFQuery(className:"Entry")
        query.getObjectInBackgroundWithId(self.entryId!) {
            (currentEntry: PFObject?, error: NSError?) -> Void in
            if error == nil && currentEntry != nil {
                self.currentEntry = currentEntry
                self.songTitleLabel.text = self.currentEntry!["title"] as? String
//                self.dateLabel.text = self.currentEntry!["created_at"] as? String
                self.userId = self.currentEntry!["user_id"] as? String
                self.setUserLabels()
            } else {
                print(error)
            }
        }
    }
    
    func setUserLabels(){
        let query = PFUser.query()!
        query.getObjectInBackgroundWithId(self.userId!) {
            (userObject: PFObject?, error: NSError?) -> Void in
            if error == nil && userObject != nil {
                let user = userObject as! PFUser
                self.usernameLabel.text = user["username"] as? String
                self.locationLabel.text = user["location"] as? String
                let profUrl = user["profilePhotoUrl"] as? String
                self.userImageView.setImageWithURL(NSURL(string: profUrl!)!)
            } else {
                print(error)
            }
        }
//        query.whereKey("facebook_id", equalTo: "IZwCMs11i9")
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            if error == nil {
//                if let objects = objects {
//                    for object in objects {
//                        let user = object as! PFUser
//                        self.usernameLabel.text = user["username"] as? String
//                        self.locationLabel.text = user["location"] as? String
//                        let profUrl = user["profilePhotoUrl"] as? String
//                        self.userImageView.setImageWithURL(NSURL(string: profUrl!)!)
//                    }
//                }
//            } else {
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
    }

    @IBAction func onBack(sender: AnyObject) {
        performSegueWithIdentifier("returnInbox", sender: self)
    }
    
    // MARK: add rejected request for user
    @IBAction func onReject(sender: AnyObject) {
        if let requests_received = inboxUser!["requests_received"] {
            var requestsReceived = requests_received as! Array<Dictionary<String,String>>
            let index = requestsReceived.indexOf({$0["entry_id"] == self.entryId})
            requestsReceived.removeAtIndex(index!)
            // update requests_received for user
            inboxUser!["requests_received"] = requestsReceived
            inboxUser!.saveInBackground()
            // add to requests_rejected for user
            addReject()
        }
        performSegueWithIdentifier("returnInbox", sender: self)
    }

    func addReject() {
        // add to requests_rejected array for current user
        if let requests_rejected = inboxUser!["requests_rejected"] {
            var array = requests_rejected as! Array<Dictionary<String,String>>
            array.append(request!)
            inboxUser!["requests_rejected"] = array
        } else {
            let array = [request!]
            inboxUser!["requests_rejected"] = array
        }
        inboxUser!.saveInBackground()
    }
    
    // MARK: Accept feedback request
    func addAcceptedRequest() {
        // add to requests_rejected array for current user
        if let requests_accepted = inboxUser!["requests_accepted"] {
            var array = requests_accepted as! Array<Dictionary<String,String>>
            array.append(self.request!)
            inboxUser!["requests_accepted"] = array
        } else {
            let array = [request!]
            inboxUser!["requests_accepted"] = array
        }
        inboxUser!.saveInBackground()
    }
    
    func onAccept() {
        if let requests_received = inboxUser!["requests_received"] {
            var requestsReceived = requests_received as! Array<Dictionary<String,String>>
            let index = requestsReceived.indexOf({$0["entry_id"] == self.entryId})
            requestsReceived.removeAtIndex(index!)
            // update requests_received for user
            inboxUser!["requests_received"] = requestsReceived
            inboxUser!.saveInBackground()
            // add to requests_accepted for user
            addAcceptedRequest()
        }
    }
    
    // MARK: sets current feedback request
    func setFeedbackRequest(request: Dictionary<String,String>) {
        self.request = request
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "AcceptFeedbackSegue":
                    let navController = segue.destinationViewController as! UINavigationController
                    let acceptFeedbackRequestViewController = navController.topViewController as! AcceptFeedbackRequestViewController
                    acceptFeedbackRequestViewController.entry = currentEntry
                    onAccept()

                default:
                    return
            }
        }
        
    }

}
