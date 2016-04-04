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
    var refreshControlTableView: UIRefreshControl!
    
    var entry: PFObject?
    var feedback: [PFObject] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emptyFeedbackView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let title = entry!.objectForKey("title") as? String

        titleLabel.text = title?.uppercaseString
        titleLabel.font = StyleGuide.Fonts.semiBoldFont(size: 11.0)
        titleLabel.textColor = StyleGuide.Colors.echoDarkerGray
        
        loadFeedback()
        emptyFeedbackView.alpha = 0

        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
    }
    
    @IBAction func onBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onRefresh(){
        loadFeedback()
        self.refreshControlTableView.endRefreshing()
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            return entry!.objectForKey("Title") as? String
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = StyleGuide.Fonts.mediumFont(size: 14.0)
        header.textLabel?.textColor = StyleGuide.Colors.echoDarkerGray
        
    }
    
    func loadFeedback() {
        let entryQuery = PFQuery(className:"Feedback")
        entryQuery.whereKey("entry_id", equalTo: entry!)
        
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.feedback = []
                    self.feedback = objects
                    print("objects!! \(objects)")
                }
                if objects!.count == 0 {
                    UIView.animateWithDuration(0.15, animations: { () -> Void in
                        self.emptyFeedbackView.alpha = 1
                    })
                } else {
                    self.tableView.reloadData()
                }
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
        let feedbackStoryboard = UIStoryboard(name: "FeedbackRecording", bundle: nil)
        let feedbackVC = feedbackStoryboard.instantiateViewControllerWithIdentifier("FeedbackViewController") as! FeedbackViewController
        feedbackVC.feedback = feedbackInstance
        feedbackVC.entry = entry!
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(feedbackVC, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedback.count
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "requestFeedback":
                let vc = segue.destinationViewController  as! FeedbackRequestViewController
                vc.entry = entry!
            default:
                return
            }
        }
    }

}
