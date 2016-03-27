//
//  DualHomeViewController.swift
//  Echo
//
//  Created by Christine Hong on 3/25/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse

class DualHomeViewController: UIViewController {
    var studentEntry: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "selectedDualVideo":
                let vc = segue.destinationViewController as! DualSelectViewController
                vc.studentEntry = self.studentEntry
                
            default:
                return
            }
        }

    }
    

}
