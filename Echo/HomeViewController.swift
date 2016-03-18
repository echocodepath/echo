//
//  HomeViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

class HomeViewController: UIViewController {
    
    @IBOutlet weak var inspirationalQuoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        let quoteAndAuthor = InspirationGenerator.sharedInstance.pickRandomQuote()
        let quote = quoteAndAuthor[0]
        let author = quoteAndAuthor[1]
        
        inspirationalQuoteLabel.text = quote
        authorLabel.text = "- \(author)"
        if currentUser == nil {
            currentUser = User(user: PFUser.currentUser()!)
        }
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
