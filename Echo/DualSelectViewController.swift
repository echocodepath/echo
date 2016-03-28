//
//  DualSelectViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/24/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class DualSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var refreshControlTableView: UIRefreshControl!
    var entryDict = [Int: [PFObject]]()
    let months = [
        1: "January",
        2: "Februrary",
        3: "March",
        4: "April",
        5: "May",
        6: "June",
        7: "July",
        8: "August",
        9: "September",
        10: "October",
        11: "November",
        12: "December"
    ]
    
    var entries: [PFObject] = []
    var studentEntry: PFObject?
    var selectedEntry: PFObject?
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var gridIcon: UIBarButtonItem!
    
    var gridViewEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.navigationController?.navigationBarHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.alpha = 1
        
        loadEntries()
        
        // Add pull to refresh functionality
        refreshControlTableView = UIRefreshControl()
        refreshControlTableView.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControlTableView, atIndex: 0)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 12
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = StyleGuide.Fonts.mediumFont(size: 14.0)
        header.textLabel?.textColor = StyleGuide.Colors.echoDarkerGray
        
    }
    
    func tableView(tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            if entryDict[section] != nil {
                if entryDict[section]?.count == 0 {
                    return nil
                } else {
                    return "\(months[section]!) 2016"
                }
            } else {
                return nil
            }
    }
    
    func onRefresh(){
        loadEntries()
        self.refreshControlTableView.endRefreshing()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int   {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entryDict[section]?.count ?? 0
    }
    
    @IBAction func onBackBtn(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        //self.navigationController?.navigationBarHidden = true
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SelectEntryCollectionViewCell", forIndexPath: indexPath) as! JournalCollectionViewCell
        
        let entry = self.entries[indexPath.row]
        cell.entry = entry
        
        return cell
    }
    
    @IBAction func onToggleGridListView(sender: AnyObject) {
        if gridViewEnabled == true {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.tableView.alpha = 1
                self.gridIcon.image = UIImage(named: "Grid View")
            })
            gridViewEnabled = false
        } else {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.tableView.alpha = 0
                self.gridIcon.image = UIImage(named: "List View")
            })
            gridViewEnabled = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedEntry = entryDict[indexPath.section]![indexPath.row]
        performSegueWithIdentifier("playDualVideo", sender: self)
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectEntryTableViewCell", forIndexPath: indexPath) as! EntryTableViewCell
        let entry = self.entries[indexPath.row]
        cell.entry = entry
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryDict[section]?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let kWidth = (collectionView.frame.width * 0.5) - 0.5
        //        return CGSizeMake(collectionView.bounds.size.width, kHeight)
        return CGSizeMake(kWidth, kWidth)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedEntry = entries[indexPath.row]
        performSegueWithIdentifier("playDualVideo", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadEntries() {
        for monthIndex in 1...12 {
            entryDict[monthIndex] = []
        }
        
        let entryQuery = PFQuery(className:"Entry")
        entryQuery.whereKey("user_id", equalTo: (currentUser?.id)!)
        entryQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                let calendar = NSCalendar.currentCalendar()
                if let objects = objects {
                    self.entries = []
                    for object in objects {
                        let date = object.createdAt!
                        let month = calendar.components([.Month], fromDate: date).month
                        self.entryDict[month]!.append(object)
                        self.entries.append(object)
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                    }
                }
                // TODO SORT DICTIONARY BASED ON DATE HERE
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if gridViewEnabled == false {
            self.gridIcon.image = UIImage(named: "Grid View")
        } else {
            self.gridIcon.image = UIImage(named: "List View")
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "playDualVideo":
                    let vc = segue.destinationViewController as! DualVideoViewController
                    vc.teacherEntry = self.selectedEntry
                    vc.studentEntry = self.studentEntry
                
            default:
                return
            }
        }
    }

}


