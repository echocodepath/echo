//
//  FeedbackRequestSentViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/7/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4

class FeedbackRequestSentViewController: UIViewController {
    
    @IBOutlet weak var teacherLabel: UILabel!
    
    @IBAction func onTapAnywhere(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func navToHome(){
        print("Nav to home invoked")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController
        self.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    private var teacherName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.teacherLabel.text = self.teacherName
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "navToHome", userInfo: nil, repeats: true)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTeacher(teacher: PFObject) {
        self.teacherName = teacher["username"] as? String
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
