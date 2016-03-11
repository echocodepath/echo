//
//  InboxDetailsViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/8/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class InboxDetailsViewController: UIViewController {

//    var request: Dictionary<String,String>?
    var request : [String: String]?
    var currentEntry : PFObject?
    
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var requestedUserLabel: UILabel!

    @IBAction func onBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("the request on inbox details view")
        print(self.request)
        let entryId = self.request!["entry_id"]
        
        let query = PFQuery(className:"Entry")
        query.getObjectInBackgroundWithId(entryId!) {
            (currentEntry: PFObject?, error: NSError?) -> Void in
            if error == nil && currentEntry != nil {
                print(" THIS IS THE CURRENT ENTRY")
                print(currentEntry!)
                
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
