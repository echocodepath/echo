//
//  DualHomeViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/25/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class DualHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var studentEntry: PFObject?
    var teacherEntry: PFObject?
    var dualFeedbacks: Array<PFObject?> = []
    var refreshControlTableView: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "journal_bg_1x_1024"))
        tableView.delegate = self
        tableView.dataSource = self
        loadDualFeedbacks()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
        
    }
    
    func loadDualFeedbacks() {
        let entryQuery = PFQuery(className:"DualFeedback")
        entryQuery.whereKey("student_entry", equalTo: studentEntry!)
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.dualFeedbacks = []
                    for object in objects {
                        self.dualFeedbacks.append(object)
                        self.tableView.reloadData()
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    func onRefresh(){
        loadDualFeedbacks()
        self.refreshControlTableView.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EntryTableViewCell", forIndexPath: indexPath) as! EntryTableViewCell
        let dualFeedback = dualFeedbacks[indexPath.row]
        //TODO: do I really need to create an entry object just to do this?
        let entry = PFObject(className:"Entry")
        entry["title"] = dualFeedback?.objectForKey("teacher_title") as! String
        entry["song"] = dualFeedback?.objectForKey("teacher_song") as! String
        entry["artist"] = dualFeedback?.objectForKey("teacher_artist") as! String
        entry["thumbnail"] = dualFeedback?.objectForKey("teacher_thumbnail") as! PFFile
        entry["teacher_createdAt"] = dualFeedback?.objectForKey("teacher_createdAt") as! NSDate
        cell.entry = entry
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dualFeedbacks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        teacherEntry = dualFeedbacks[indexPath.row]?.objectForKey("teacher_entry") as? PFObject
        teacherEntry?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if object != nil {
                self.teacherEntry = object
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("DualVideoViewController") as! DualVideoViewController
                vc.studentEntry = self.studentEntry
                vc.teacherEntry = self.teacherEntry
                self.navigationController!.pushViewController(vc, animated: true)
            }
        })
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "selectDualVideo":
                    let vc = segue.destinationViewController as! DualSelectViewController
                    vc.studentEntry = studentEntry
                    
                default:
                    return
            }
        }

    }
    

}
