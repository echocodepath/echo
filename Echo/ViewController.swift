//
//  ViewController.swift
//  Echo
//
//  Created by Christine Hong on 2/29/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print("user is not logged in")
        } else {
            print("user logged in!!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

