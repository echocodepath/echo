//
//  JournalEntriesViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/6/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class JournalEntriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControlTableView: UIRefreshControl!
    
    var entries: [PFObject] = []
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        tableView.backgroundView = UIImageView(image: UIImage(named: "journal_bg_1x_1024"))
        tableView.delegate = self
        tableView.dataSource = self
        loadEntries()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
    }
    
    func onRefresh(){
        loadEntries()
        self.refreshControlTableView.endRefreshing()
    }
    
    @IBAction func onBackBtn(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.navigationBarHidden = true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EntryTableViewCell", forIndexPath: indexPath) as! EntryTableViewCell
        let entry = self.entries[indexPath.row]
        let createdAt = DateManager.defaultFormatter.stringFromDate(entry.createdAt!)
        cell.titleLabel.alpha = 0
        cell.songLabel.alpha = 0
        cell.thumbnailImageView.alpha = 0
        cell.createdAtLabel.alpha = 0
        cell.artistLabel.alpha = 0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            cell.titleLabel.text = entry.valueForKey("title") as? String
            cell.songLabel.text = entry.valueForKey("song") as? String
            cell.artistLabel.text = entry.valueForKey("artist") as? String
            cell.createdAtLabel.text = createdAt
            let thumbnailData = entry["thumbnail"] as! PFFile
            thumbnailData.getDataInBackgroundWithBlock({ (data
                , error) -> Void in
                let thumbnailImage = UIImage(data: data!)
                cell.thumbnailImageView.image = thumbnailImage
                cell.thumbnailIconImageView.image = UIImage(named: "Play Icon")
                cell.titleLabel.alpha = 1
                cell.songLabel.alpha = 1
                cell.thumbnailImageView.alpha = 1
                cell.artistLabel.alpha = 1
                cell.createdAtLabel.alpha = 1
            })
            
        })

        //cell.entry = entry
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("journalToEntrySegue", sender: self)
        
//        let entryViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EntryViewController") as! EntryViewController
//        let entry = entries[indexPath.row]
//        entryViewController.entry = entry
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        self.navigationController?.pushViewController(entryViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadEntries() {
        let entryQuery = PFQuery(className:"Entry")
        entryQuery.whereKey("user_id", equalTo: (currentUser?.id)!)
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    self.entries = []
                    for object in objects {
                        self.entries.append(object)
                        self.tableView.reloadData()
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "journalToEntrySegue":
                    if let indexPath = self.tableView.indexPathForSelectedRow{
                        let vc = segue.destinationViewController as! EntryViewController
                        vc.updateEntry(self.entries[indexPath.row])
                    }
                    
                default:
                    return
            }
        }
    }

}
