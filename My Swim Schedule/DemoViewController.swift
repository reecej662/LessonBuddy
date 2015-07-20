//
//  DemoViewController.swift
//  My Swim Schedule
//
//  Created by Reece Jackson on 7/15/15.
//  Copyright (c) 2015 RJ. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    var pages:NSArray = []
    var currentIndex: Int = 0 {
        
        didSet {
            
            updateParentButtons()
            
        }
     
    }
    
    var parentController: ScrollContainerView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
            
        var page1:AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("demoPage1ID")
        var page2:AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("demoPage2ID")
        var page3:AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("demoPage3ID")
        var page4:AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("demoPage4ID")
        var page5:AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("demoPage5ID")
        
        pages = [page1, page2, page3, page4, page5]
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        setViewControllers([page1], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController {
        
        if(index < pages.count) {
            return pages[index] as! UIViewController
        } else {
            return UIViewController()
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        currentIndex = pages.indexOfObject(viewController)

        --currentIndex
        
        if(currentIndex != -1) {
            
            return pages.objectAtIndex(currentIndex) as? UIViewController
    
        } else {
            
            return nil
            
        }

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        currentIndex = pages.indexOfObject(viewController)

        ++currentIndex
       
        if(currentIndex < pages.count && currentIndex != 5) {
        
            return pages.objectAtIndex(currentIndex) as? UIViewController
        
        } else {
            
            return nil
            
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        currentIndex = pages.indexOfObject(previousViewControllers[0])
    
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    func changePage (direction: UIPageViewControllerNavigationDirection) {
    
        currentIndex = pages.indexOfObject(self.viewControllers[0])
        
        if (direction == UIPageViewControllerNavigationDirection.Forward) {
            currentIndex++
            currentIndex = (currentIndex == 5 ? 4 : currentIndex)
        } else {
            --currentIndex
            currentIndex = (currentIndex == -1 ? 0 : currentIndex)
        }
        
        if(currentIndex < pages.count) {
            setViewControllers([pages[currentIndex]], direction: direction, animated: true, completion: nil)
        }

    }
    
    func updateParentButtons() {
        
        var tempCurrentIndex = (pages.count > 0 ? pages.indexOfObject(self.viewControllers[0]) : 0)
        
        if parentController != nil {
            
            parentController!.hideButtons(tempCurrentIndex)
            
        }
        
    }
    
}

class DemoViewController: ViewStyle {
    
    @IBOutlet var topConstraint1: NSLayoutConstraint!
    @IBOutlet var topConstraint2: NSLayoutConstraint!
    @IBOutlet var topConstraint3: NSLayoutConstraint!
    @IBOutlet var topConstraint4: NSLayoutConstraint!
    @IBOutlet var topConstraint5: NSLayoutConstraint!
    
    @IBOutlet var menuPictureHeight: NSLayoutConstraint!
    @IBOutlet var menuPictureWidth: NSLayoutConstraint!
    @IBOutlet var samplePictureHeight: NSLayoutConstraint!
    @IBOutlet var samplePictureWidth: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.clearColor()
        
        var topConstraints = [topConstraint1, topConstraint2, topConstraint3, topConstraint4, topConstraint5]
        var pictureConstraints = [[menuPictureHeight, menuPictureWidth], [samplePictureHeight, samplePictureWidth]]
        
        var screenSize = UIScreen.mainScreen().bounds.height
        
        for constraint in topConstraints {
            
            if constraint != nil {
                
                if screenSize > 670 {
                
                    constraint.constant += 40
                
                } else if screenSize < 600 {
                
                    constraint.constant -= 50
                
                }
            
            }
            
        }
        
        for constraint in pictureConstraints {
            
            if constraint[0] != nil {
                
                if screenSize < 600 {
                
                    constraint[0].constant -= 20
                    constraint[1].constant -= 50
                
                }
                
            }
            
        }
        
    }
    
}

class ScrollContainerView: ViewStyle {
    
    @IBOutlet var leftScrollButton: UIButton!
    @IBOutlet var rightScrollButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    var pageView:PageViewController!
    var currentIndex = 0
    
    @IBAction func rightScroll(sender: AnyObject) {
        
        pageView.changePage(UIPageViewControllerNavigationDirection.Forward)
        hideButtons(pageView.currentIndex)

    }
    
    @IBAction func leftScroll(sender: AnyObject) {

        pageView.changePage(UIPageViewControllerNavigationDirection.Reverse)
        hideButtons(pageView.currentIndex)
        
    }
    
    @IBAction func completeDemo(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        setBackground("background.png")

        var leftScrollImage = UIImage(named: "leftIcon.png")
        var rightScrollImage = UIImage(named: "rightIcon.png")
        
        var insets = UIEdgeInsetsMake(15, 0, 15, 15)
        
        rightScrollButton.setImage(rightScrollImage, forState: .Normal)
        leftScrollButton.setImage(leftScrollImage, forState: .Normal)
        
        leftScrollButton.imageEdgeInsets = UIEdgeInsetsMake(15, 0, 15, 15)
        rightScrollButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 0)

        hideButtons(pageView.currentIndex)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? PageViewController
            where segue.identifier == "EmbedSegue" {
                
                pageView = vc
                vc.parentController = self
        }
    }
    
    func hideButtons(currentIndex: Int) {
        
        if currentIndex == 0 {
            
            leftScrollButton.hidden = true
            rightScrollButton.hidden = false
            
            self.signUpButton.hidden = true
            self.signUpButton.alpha = 0
            
        } else if currentIndex >= 4 {
            
            leftScrollButton.hidden = false
            rightScrollButton.hidden = true
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.signUpButton.hidden = false
                self.signUpButton.alpha = 1
            })
            
        } else {
            
            leftScrollButton.hidden = false
            rightScrollButton.hidden = false
            
            self.signUpButton.hidden = true
            self.signUpButton.alpha = 0
            
        }
        
    }
    
}
