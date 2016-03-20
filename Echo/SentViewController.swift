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
    
    var inboxUser: PFUser?
    var requestsSent: Array<Dictionary<String,String>> = []
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        requestsSentTableView.backgroundView = UIImageView(image: UIImage(named: "journal_bg_1x_1024"))
        requestsSentTableView.delegate = self
        requestsSentTableView.dataSource = self
        
        fetchRequests()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        requestsSentTableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchRequests(){
        inboxUser = PFUser.currentUser()
        inboxUser?.fetchInBackground()
        if let requests_sent = inboxUser!["requests_sent"] {
            self.requestsSent = requests_sent as! Array<Dictionary<String,String>>
        }
        requestsSentTableView.reloadData()
    }
    
    func onRefresh(){
        fetchRequests()
        self.refreshControlTableView.endRefreshing()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsSent.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SentRequests", forIndexPath: indexPath) as! InboxCell

        var request = self.requestsSent[indexPath.row]
        
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
            
            let teacher_id = request["teacher_id"]! as String
            let teacherQuery = PFUser.query()!
            teacherQuery.getObjectInBackgroundWithId(teacher_id) {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil && object != nil {
                    var teacher_name = ""
                    var teacher_picture = ""
                    teacher_name = object!["username"] as! String
                    teacher_picture = object!["profilePhotoUrl"] as! String
                    cell.inboxTextLabel.text = "Awaiting feedback on " + title + " from " + teacher_name
                    cell.avatarImageView.setImageWithURL(NSURL(string: teacher_picture)!)
                } else {
                    print(error)
                }
            }
//            teacherQuery.whereKey("facebook_id", equalTo: teacher_id)
//            teacherQuery.findObjectsInBackgroundWithBlock {
//                (objects: [PFObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    var teacher_name = ""
//                    var teacher_picture = ""
//                    if let objects = objects {
//                        for object in objects {
//                            teacher_name = object["username"] as! String
//                            teacher_picture = object["profilePhotoUrl"] as! String
//                        }
//                    }
//                    cell.inboxTextLabel.text = "Awaiting feedback on " + song + " from " + teacher_name
//                    if let url  = NSURL(string: teacher_picture),
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    */
    

}
