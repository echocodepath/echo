//
//  EntryFeedbackViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/15/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class EntryFeedbackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var entry: PFObject?
    var feedback: [PFObject] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadFeedback()
        // Do any additional setup after loading the view.
    }
    
    func loadFeedback() {
        let entryQuery = PFQuery(className:"Feedback")
        entryQuery.whereKey("entry_id", equalTo: entry!)
        
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.feedback = objects
                    print("objects!! \(objects)")
                }
                self.tableView.reloadData()
                print("FEEDBACK \(self.feedback)")

            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feedbackInstance = feedback[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedbackTableViewCell", forIndexPath: indexPath) as! FeedbackTableViewCell
        cell.feedback = feedbackInstance
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let feedbackInstance = feedback[indexPath.row]
        let feedbackVC = self.storyboard!.instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
        feedbackVC.feedback = feedbackInstance
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedback.count
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
