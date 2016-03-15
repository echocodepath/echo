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

class InboxDetailsViewController: UIViewController {
    var inboxUser: PFUser?
    var request : [String: String]?
    var currentEntry : PFObject?
    var entryId: String?
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var requestedUserLabel: UILabel!
    @IBOutlet weak var requestBodyLabel: UILabel!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        do {
            try inboxUser?.fetch()
        } catch {
            print("Error fetching inbox user")
        }
        entryId = self.request!["entry_id"]
        self.requestBodyLabel.text = self.request!["request_body"]
        
        let query = PFQuery(className:"Entry")
        query.getObjectInBackgroundWithId(entryId!) {
            (currentEntry: PFObject?, error: NSError?) -> Void in
            if error == nil && currentEntry != nil {
                self.currentEntry = currentEntry
                self.songTitleLabel.text = self.currentEntry!["song"] as? String
                self.requestedUserLabel.text = self.currentEntry!["username"] as? String
            } else {
                print(error)
            }
        }
    }
    
    func setFeedbackRequest(request: Dictionary<String,String>) {
        self.request = request
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: add accepted request for user
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
