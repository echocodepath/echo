//
//  FeedbackSendReceiptViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/20/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class FeedbackSendReceiptViewController: UIViewController {
    var studentName : String?

    @IBOutlet weak var studentNameLabel: UILabel!

    func navigateToJournal(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBarHidden = true
        studentNameLabel.text = "\(studentName!)."
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "navigateToJournal", userInfo: nil, repeats: false)
        
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
