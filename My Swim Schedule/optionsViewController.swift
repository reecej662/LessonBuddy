//
//  optionsViewController.swift
//  My Swim Schedule
//
//  Created by Reece Jackson on 7/9/15.
//  Copyright (c) 2015 RJ. All rights reserved.
//

import UIKit
import Parse

class optionsViewController: ViewStyle {
    
    @IBOutlet var loggedInLabel: UILabel!
    
    @IBOutlet var topToLogoutConstraint: NSLayoutConstraint!
    @IBOutlet var logoutToMySwimScheduler: NSLayoutConstraint!
    @IBOutlet var backTo2015: NSLayoutConstraint!
    
    let vTopToLogout:CGFloat = 121
    let vLogoutToMSS:CGFloat = 80
    let vBackTo2015:CGFloat = 63
    let hTopToLogout:CGFloat = 60
    let hLogoutToMSS:CGFloat = 40
    let hBackTo2015:CGFloat = 30
    
    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOut()
        
    }
    
    @IBAction func back(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        setBackground("background.png")
        let userFullName = PFUser.currentUser()?.valueForKey("name") as! String
        loggedInLabel.text = "Logged in as " + userFullName
        
        updateViewConstraints(UIApplication.sharedApplication().statusBarOrientation)
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        updateViewConstraints(toInterfaceOrientation)
        
    }
    
    func updateViewConstraints(orientation: UIInterfaceOrientation) {
        
        if orientation == .Portrait {
            
            topToLogoutConstraint.constant = vTopToLogout
            logoutToMySwimScheduler.constant = vLogoutToMSS
            backTo2015.constant = vBackTo2015
            
        } else {
            
            topToLogoutConstraint.constant = hTopToLogout
            logoutToMySwimScheduler.constant = hLogoutToMSS
            backTo2015.constant = hBackTo2015
            
        }
        
    }
    
}
