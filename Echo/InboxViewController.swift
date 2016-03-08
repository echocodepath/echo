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

class InboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var currentUser: PFUser?
    var requestsReceived: Array<Dictionary<String,String>> = []
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        currentUser = PFUser.currentUser()
        // retriveve requests_received
        if let requests_received = currentUser!["requests_received"] {
            self.requestsReceived = requests_received as! Array<Dictionary<String,String>>
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.requestsReceived.count > 0 {
            return self.requestsReceived.count
        }
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InboxCell", forIndexPath: indexPath) as! InboxCell
        if self.requestsReceived.count > 0 {
            let request = self.requestsReceived[indexPath.row]
            
            let entry_id = request["entry_id"]! as String
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
                    cell.inboxTextLabel.text = student_name + " would like feedback on " + song
                    if let url  = NSURL(string: student_picture),
                        data = NSData(contentsOfURL: url)
                    {
                        cell.avatarImageView.image = UIImage(data: data)
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        } else {
            cell.inboxTextLabel.text = "You have no feedback requests"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.requestsReceived.count > 0 {
            performSegueWithIdentifier("inboxDetails", sender: self)
        }
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
