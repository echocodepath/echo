//
//  EntryViewController.swift
//  Echo
//
//  Created by Isis Anchalee on 3/6/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    var entry: Entry?
    
    @IBOutlet weak var entryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: fill dynamically, just hardcoded in Entry.swift   
        self.entry = Entry()
        entryLabel.text = self.entry!.entry_title! + "\nSong: " + self.entry!.song! + "\nArtist: " + self.entry!.song_artist!
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
                case "requestFeedback":
                    let vc = segue.destinationViewController as! FeedbackRequestViewController
                    vc.setFeedbackEntry(self.entry)
                
                default:
                    return
            }
        }
    }


}
