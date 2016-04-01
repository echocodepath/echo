//
//  JournalEntriesViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/6/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class JournalEntriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    struct Constants {
        static let collectionHeaderViewID = "headerViewId"
    }
    
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
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var gridIcon: UIBarButtonItem!
    
    var gridViewEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.registerClass(CollectionHeaderFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constants.collectionHeaderViewID)
        
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
            layout.headerReferenceSize = CGSize(width: 0, height: 30)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 12
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { (_, indexPath) -> Void in

            // Delete from parse
            // Remove from journals collection
            
            // ANIMATE!
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
        return [delete]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (entryDict[section] != nil && entryDict[section]?.count > 0) ? 30 : 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CollectionHeaderFooterView()
        view.backgroundColor = UIColor.whiteColor()
        view.label.text = {
            if entryDict[section] != nil {
                if entryDict[section]?.count == 0 {
                    return nil
                } else {
                    return "\(months[section]!) 2016"
                }
            } else {
                return nil
            }
            }()
        return view
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
        self.navigationController?.navigationBarHidden = true
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("JournalCollectionViewCell", forIndexPath: indexPath) as! JournalCollectionViewCell
        
        let entry = self.entries[indexPath.row]
        cell.entry = entry
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.collectionHeaderViewID, forIndexPath: indexPath) as! CollectionHeaderFooterView
        view.label.text = {
            if entryDict[indexPath.section] != nil {
                if entryDict[indexPath.section]?.count == 0 {
                    return nil
                } else {
                    return "\(months[indexPath.section]!) 2016"
                }
            } else {
                return nil
            }
        }()
        return view
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return (entryDict[section] != nil && entryDict[section]?.count > 0) ? CGSize(width: 0, height: 30) : CGSize.zero
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("JournalCollectionViewCell", forIndexPath: indexPath) as! JournalCollectionViewCell
        
        let entry = entryDict[indexPath.section]![indexPath.row]
        let entryVC = self.storyboard?.instantiateViewControllerWithIdentifier("EntryViewController") as! EntryViewController
        entryVC.entry = entry
        self.navigationController?.pushViewController(entryVC, animated: true)
    }
    

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EntryTableViewCell", forIndexPath: indexPath) as! EntryTableViewCell
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
                case "journalToEntrySegue":
                    if let indexPath = self.tableView.indexPathForSelectedRow{
                        let vc = segue.destinationViewController as! EntryViewController
                        vc.entry = self.entries[indexPath.row]
                    }
        
                    
                default:
                    return
            }
        }
    }

}
