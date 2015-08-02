//
//  LoginViewController.swift
//  My Swim Schedule
//
//  Created by Reece Jackson on 6/24/15.
//  Copyright (c) 2015 RJ. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: ViewStyle, UITextFieldDelegate {

    /* When somebody registers for an account, match a client in the database with 
    their first and last name. Add a text field to client that stores that ID and 
    keep that in storage when using the app to simplify parse queries */
    
    @IBOutlet var backgroundImage: UIImageView!
    
    @IBOutlet var topView: UIView!
    @IBOutlet var selectionView: UIView!
    var actionSelectionView: UIView!
    
    @IBOutlet var loginBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var textView1: UIView!
    @IBOutlet var textView2: UIView!
    @IBOutlet var textView3: UIView!
    
    @IBOutlet var viewImage1: UIImageView!
    @IBOutlet var viewImage2: UIImageView!
    @IBOutlet var viewImage3: UIImageView!
    
    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!

    @IBOutlet var demoLabel: UILabel!
    
    var textLines = [UIView()]
    
    @IBOutlet var login: UIButton!
    
    @IBOutlet var topHeightConstraint: NSLayoutConstraint!
    @IBOutlet var titleToTopConstraint: NSLayoutConstraint!
    @IBOutlet var buttonsToTitleConstraint: NSLayoutConstraint!
    
    let pTopHeight:CGFloat = 250
    let hTopHeight:CGFloat = 100
    let pTitleToTop:CGFloat = 91
    let hTitleToTop:CGFloat = 29
    let pButtonsToTitle:CGFloat = 98
    let hButtonsToTitle:CGFloat = 10
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var signupActive = false
    var kbHeight: CGFloat!
    var offset:CGFloat = 30.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackground("background.png")
        
        textField1.attributedPlaceholder = NSAttributedString(string: "Username", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField2.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField3.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        addLines()
        
        updateViewConstraints(UIApplication.sharedApplication().statusBarOrientation)
        
        textView3.hidden = true
        
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if textField1.text == "" || textField2.text == "" {
            
            displayAlert("Error", message: "Please fill in all fields")
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if signupActive == true {
                
                if textField3.text == "" {
                    
                    displayAlert("Error", message: "Please fill in all fields")
                    
                } else {
                
                    let user = PFUser()
                    user.username = textField1.text
                    user.setValue(textField2.text, forKey: "name")
                    user.password = textField3.text
                    
                    var errorMessage = "Please try again later"
                
                    user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                        if error == nil {
                        
                            if self.presentingViewController?.presentingViewController != nil {
                            
                                self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                
                            } else {
                                
                                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                
                            }
                        
                        } else {
                        
                            if let errorString = error!.userInfo["error"] as? String {
                            
                                errorMessage = errorString
                            
                            }
                        
                            self.displayAlert("Failed SignUp", message: errorMessage)
                        
                        }
                    
                    })
                
                }
                    
            } else {
                
                PFUser.logInWithUsernameInBackground(textField1.text!, password: textField2.text!, block: { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    var errorMessage = "Please try again later"
                    
                    if user != nil {
                        
                        if let parentView = self.presentingViewController?.presentingViewController {
                            
                            parentView.dismissViewControllerAnimated(true, completion: nil)
                        
                        } else {
                        
                            self.dismissViewControllerAnimated(true, completion: nil)
                        
                        }
                        
                    } else {
                        
                        if let errorString = error!.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                            
                        }
                        
                        self.displayAlert("Failed Log In", message: errorMessage)
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in })))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func loginView(sender: AnyObject) {
        
        textField1.endEditing(true)
        textField2.endEditing(true)
        textField3.endEditing(true)
        
        viewImage2.image = UIImage(named: "passwordIcon.png")
        textView3.hidden = true
        hideDemoLabel(1)
        
        textField1.text = ""
        textField2.text = ""
        textField2.secureTextEntry = true
        textField2.attributedPlaceholder = NSAttributedString(string: "Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField3.text = ""
        
        actionSelectionView.frame.origin.x = 0
        login.setTitle("Login", forState: .Normal)
        signupActive = false
        
    }
    
    @IBAction func signUpView(sender: AnyObject) {
        
        textField1.endEditing(true)
        textField2.endEditing(true)
        textField3.endEditing(true)
    
        viewImage2.image = UIImage(named: "emailIcon.png")
        textView3.hidden = false
        hideDemoLabel(0)
        
        textField1.text = ""
        textField2.text = ""
        textField2.secureTextEntry = false
        textField2.attributedPlaceholder = NSAttributedString(string: "First and Last Name", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        textField3.text = ""
        
        actionSelectionView.frame.origin.x = sender.frame.origin.x
        login.setTitle("Connect", forState: .Normal)
        signupActive = true
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height - offset
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
            self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        let movement = (up ? -kbHeight: kbHeight)
        let barOffset = (up ? offset: -offset)
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
            self.loginBottomConstraint.constant += barOffset
            
        })
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        updateViewConstraints(toInterfaceOrientation)
        actionSelectionView.removeFromSuperview()
        
    }
    
    func addLines() {
        
        textLines.removeAll(keepCapacity: true)
        
        actionSelectionView = UIView(frame: CGRectMake(0, 36, UIScreen.mainScreen().bounds.width / 2.0, 2))
        actionSelectionView.backgroundColor = UIColor.whiteColor()
        selectionView.addSubview(actionSelectionView)
        
        for(var x = 0; x < 3; x++){
            
            textLines.append(UIView(frame: CGRectMake(0, 46, UIScreen.mainScreen().bounds.width - 32, 1)))
            textLines[x].backgroundColor = UIColor(white: 1, alpha: 0.3)
            
        }
        
        textView1.addSubview(textLines[0])
        textView2.addSubview(textLines[1])
        textView3.addSubview(textLines[2])

    }
 
    func updateViewConstraints(orientation: UIInterfaceOrientation) {
    
        if orientation == .Portrait {
            
            topHeightConstraint.constant = pTopHeight
            titleToTopConstraint.constant = pTitleToTop
            buttonsToTitleConstraint.constant = pButtonsToTitle
        
        } else {
            
            topHeightConstraint.constant = hTopHeight
            titleToTopConstraint.constant = hTitleToTop
            buttonsToTitleConstraint.constant = hButtonsToTitle
            
        }
        
    }
    
    func hideDemoLabel(alpha: Int) {
        
        if (alpha == 1) {
        
            UILabel.animateWithDuration(0.2, animations: { () -> Void in
                self.demoLabel.alpha = 1
            })
            
        } else {
            
            UILabel.animateWithDuration(0.2, animations: { () -> Void in
                self.demoLabel.alpha = 0
            })
            
        }
        
    }
    
}
