//
//  ParseClient.swift
//  Echo
//
//  Created by Isis Anchalee on 3/4/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4


class ParseClient: NSObject {
    var currentUser : PFUser = PFUser.currentUser()!
    
    class var sharedInstance: ParseClient {
        struct Static {
            static let instance =  ParseClient()
        }
        return Static.instance
    }
    
    func setUserValue(key: String, value: String) {
        currentUser[key] = value
        currentUser.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    func setCurrentUserWithDict(dict: NSDictionary) {
        for (key, val) in dict {
            currentUser[key as! String] = val
        }
        currentUser.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("success!!")
                // The object has been saved.
            } else {
                print("there was a problem saving asset")
                // There was a problem, check error.description
            }
        }
    }
    
    func createEntryWithCompletion(dict: NSDictionary, completion: (entry: PFObject?, error: NSError?) -> ()) {
        
        let entry = PFObject(className:"Entry")
        for (key, val) in dict {
            entry[key as! String] = val
        }
        
        entry.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(entry: entry, error: error)
                print("in parse client")
            } else {
                // There was a problem, check error.description
            }
        }
        
    }
    
    func createFeedbackWithCompletion(dict: NSDictionary, completion: (feedback: PFObject?, error: NSError?) -> ()) {
        
        let feedback = PFObject(className:"Feedback")
        for (key, val) in dict {
            feedback[key as! String] = val
        }
        
        feedback.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(feedback: feedback, error: error)
            } else {
            }
        }
        
    }
    
    func createFeedbackRequestWithCompletion(dict: NSDictionary, completion: (feedbackRequest: PFObject?, error: NSError?) -> ()) {
        let feedbackRequest = PFObject(className:"FeedbackRequest")
        for (key, val) in dict {
            feedbackRequest[key as! String] = val
        }
        
        feedbackRequest.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(feedbackRequest: feedbackRequest, error: error)
            } else {
            }
        }
        
    }
    
    func createFavoriteWithCompletion(dict: NSDictionary, completion: (favorite: PFObject?, error: NSError?) -> ()) {
        let favorite = PFObject(className:"Favorite")
        for (key, val) in dict {
            favorite[key as! String] = val
        }
        
        favorite.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(favorite: favorite, error: error)
            } else {
            }
        }
        
    }
    
//    func createDualFeedbackWithCompletion(dict: NSDictionary, completion: (feedback: PFObject?, error: NSError?) -> ()) {
//        
//        let feedback = PFObject(className:"DualFeedback")
//        for (key, val) in dict {
//            feedback[key as! String] = val
//        }
//        
//        feedback.saveInBackgroundWithBlock {
//            (success: Bool, error: NSError?) -> Void in
//            if (success) {
//                completion(feedback: feedback, error: error)
//            } else {
//            }
//        }
//        
//    }
    
    func createAudioClipWithCompletion(dict: NSDictionary, completion: (audioClip: PFObject?, error: NSError?) -> ()) {
        
        let audioClip = PFObject(className:"AudioClip")
        for (key, val) in dict {
            audioClip[key as! String] = val
        }
        
        audioClip.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                completion(audioClip: audioClip, error: error)
            } else {
            }
        }
        
    }
}
