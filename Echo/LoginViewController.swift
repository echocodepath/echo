//
//  ViewController.swift
//  Echo
//
//  Created by Christine Hong on 2/29/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import Parse

class LoginViewController: UIViewController {
//, FBSDKLoginButtonDelegate
    lazy var carousel = CarouselView()

    @IBOutlet weak var loginButton: UIButton!
//    func generateRandomColor() -> UIColor {
//        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
//        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
//        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
//        
//        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
//        view.addSubview(carousel)
//        let views = ["carousel" : carousel]
//        carousel.translatesAutoresizingMaskIntoConstraints = false
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[carousel]|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[carousel]|", options: [], metrics: nil, views: views))
//        
//        for index in 0...3 {
//            let view = UIImageView(image: UIImage(named: "help_\(index)"))
//            view.contentMode = .ScaleAspectFit
//            view.backgroundColor = generateRandomColor()
//            carousel.views.append(view)
//        }
        view.bringSubviewToFront(loginButton)
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print("user is not logged in")
        } else {
            //openHomePage()
            openHomeTab()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                //let echoUser = User(user: user)
                if user.isNew {
                    self.openSetupPage()
                } else {
                    //self.openHomePage()
                    self.openHomeTab()
                }
            } else {
            }
        }
    }
    
    func openSetupPage(){
        let authenticatedSetupViewController = self.storyboard!.instantiateViewControllerWithIdentifier("AuthenticatedSetupViewController") as! AuthenticatedSetupViewController
        let authSetupPageNav = NavigationController(rootViewController: authenticatedSetupViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = authSetupPageNav
    }
    
//    func openHomePage(){
//        let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
//        let homePageNav = NavigationController(rootViewController: homeViewController)
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window?.rootViewController = homePageNav
//    }
    
    func openHomeTab(){
        let homeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeTabViewController") as! HomeTabViewController
        //let homePageNav = NavigationController(rootViewController: homeViewController)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = homeViewController
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        print("user is logged out")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

