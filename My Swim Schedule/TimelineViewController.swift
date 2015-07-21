//
//  TimelineViewController.swift
//  My Swim Schedule
//
//  Created by Reece Jackson on 6/24/15.
//  Copyright (c) 2015 RJ. All rights reserved.
//

import UIKit
import Parse

class timelineView: ViewStyle, UIScrollViewDelegate {
    
    @IBOutlet var rightBarItem: UIBarButtonItem!
    @IBOutlet var topView: UIView!
    @IBOutlet var selectionView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var currentButton: UIButton!
    @IBOutlet var allButton: UIButton!
    @IBOutlet var pastButton: UIButton!
    
    var weekdays = [""]
    var userId:String!
    var selection = "current"
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func current(sender: AnyObject) {
        selectionView.frame.origin.x = sender.frame.origin.x
        selection = "current"
        getSelectedLessons("current")
        
        animateNavBarTo(UIApplication.sharedApplication().statusBarFrame.height)
        updateBarButtonItems(1.0)
        rightBarItem.image = UIImage(named: "more.png")
    }
    
    @IBAction func all(sender: AnyObject) {
        selectionView.frame.origin.x = sender.frame.origin.x
        selection = "all"
        getSelectedLessons("all")

        animateNavBarTo(UIApplication.sharedApplication().statusBarFrame.height)
        updateBarButtonItems(1.0)
        rightBarItem.image = UIImage(named: "more.png")
    }
    
    @IBAction func past(sender: AnyObject) {
        selectionView.frame.origin.x = sender.frame.origin.x
        selection = "past"
        getSelectedLessons("past")
        
        animateNavBarTo(UIApplication.sharedApplication().statusBarFrame.height)
        updateBarButtonItems(1.0)
        rightBarItem.image = UIImage(named: "more.png")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() != nil {
            
            userId = PFUser.currentUser()?.objectId
            
        }
        
        scrollView.delegate = self
        scrollView.frame.origin.y = 0
        self.scrollView.contentSize = CGSize(width:320, height:25)
        self.view.addSubview(scrollView)
        scrollViewBottomConstraint.constant = mainViewOffset
        
        lessonArray.removeAll(keepCapacity: true)
        
        self.navigationItem.title = ""
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftNavTitle("My Timeline"))
        
        weekdays.removeAll(keepCapacity: true)
        
        self.view.bringSubviewToFront(selectionView)
        
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        
        if !firstLaunch {
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstLaunch")
            self.performSegueWithIdentifier("demo", sender: self)
            
        }
        
        if PFUser.currentUser() == nil {
            
            performSegueWithIdentifier("login", sender: self)
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if PFUser.currentUser() == nil {
            performSegueWithIdentifier("login", sender: self)
        } else {
            userId = PFUser.currentUser()?.objectId
            getSelectedLessons(selection)
        }
        
    }
    
    func addTimelineElememts() {
        
        var nextY:CGFloat = 0
        var x = 0
        
        let scrollSubviews = scrollView.subviews
        for subview in scrollSubviews {
            
            subview.removeFromSuperview()
            
        }
        
        scrollView.contentSize.height = 15
        
        while(x < lessonArray.count) {
            
            if(x == 0 || lessonArray[x-1].dateString != lessonArray[x].dateString) {
                
                var sameDayLessons = [lessonStruct()]
                sameDayLessons.removeAll(keepCapacity: true)
                
                repeat {
                    sameDayLessons.append(lessonArray[x])
                    x++
                } while(x < lessonArray.count && lessonArray[x-1].dateString == lessonArray[x].dateString)
                
                let newView = day(x: 16.0, y: 15.0 + nextY, lessons: sameDayLessons)

                self.scrollView.addSubview(newView)
                self.scrollView.contentSize.height += (newView.frame.height + 5)
                nextY += newView.frame.size.height + 5
                
            }
            
        }
        
    }
    
    func getParseData(completion: (result: String) -> Void) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        scrollView.alpha = 0.75
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let query = PFQuery(className: "lessons")
        query.whereKey("clientId", equalTo: userId!)
        query.orderByAscending("date")
        
        //link client to family. Can have an unlimited number of family members in the same family. Each family member will have a 
        //corresponding value called a "familyId". This family ID will be what is linked to the lessons instead of the "client Id"
        //Don't need to go back from family to individual member
        
        lessonArray.removeAll(keepCapacity: true)
        
        query.findObjectsInBackgroundWithBlock { (lessons, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            self.scrollView.alpha = 1.0
            //UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if error == nil && lessons != nil{
                
                if let lessons = lessons as? [PFObject] {
                    for lesson in lessons {
                        
                        let lessonDate = lesson.valueForKey("date") as! NSDate
                        let optionalKid = lesson.valueForKey("studentName") as? String
                        var kid:String!
                        
                        if(optionalKid != nil) {
                            kid = optionalKid!
                        } else {
                            kid = ""
                        }
                        
                        let clientName = lesson.valueForKey("clientName") as! String
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                        let stringDate: String = dateFormatter.stringFromDate(lessonDate)
                        
                        dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
                        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                        let stringTime: String = dateFormatter.stringFromDate(lessonDate)
                        
                        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        let myComponents = myCalendar.components(.Weekday, fromDate: lessonDate)
                        let weekday = self.dayOfWeek(myComponents.weekday)
                    
                        let newLesson = lessonStruct(time: stringTime, dateString: stringDate, date: lessonDate, weekday: weekday, client: clientName, student: kid, instructor: lesson.valueForKey("instructorName") as! String)
                        super.lessonArray.append(newLesson)
                        
                    }
                }
                
                completion(result: "complete")
                
            }
            
        }
        
    }
    
    func getSelectedLessons(selection: String) {
        
        switch selection {
            
        case "current":
            
            getParseData(){
                
                (result: String) in
                
                for var x = 0; x < self.lessonArray.count; x++ {
                    
                    let lessonDate = self.lessonArray[x].date as NSDate!
                    
                    if lessonDate.timeIntervalSinceNow.isSignMinus {
                        
                        self.lessonArray.removeAtIndex(x)
                        x--
                        
                    }
                    
                }
                
                self.addTimelineElememts()
                
            }

        case "past":
            
            getParseData(){
                
                (result: String) in

                for var x = 0; x < self.lessonArray.count; x++ {
                    
                    let lessonDate = self.lessonArray[x].date as NSDate!
                    
                    if lessonDate.timeIntervalSinceNow.isSignMinus {
                        
                    } else {
                        
                        self.lessonArray.removeAtIndex(x)
                        x--
                        
                    }
                    
                }
                
                self.addTimelineElememts()
            }
            
        default:
            
            getParseData(){
                
                (result: String) in
                
                self.addTimelineElememts()
                
            }
            
        }
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        getSelectedLessons(selection)
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var frame = self.navigationController!.navigationBar.frame;
        var mainViewFrame = self.view.frame
        
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        let size = frame.size.height - statusBarHeight - 1
        let framePercentageHidden = ((statusBarHeight - frame.origin.y) / (frame.size.height - 1)) * 1.5
        let scrollOffset = scrollView.contentOffset.y
        let scrollDiff = scrollOffset - self.previousScrollViewYOffset
        let scrollHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        let statusBarHidden = UIApplication.sharedApplication().statusBarHidden
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            
            //refresher in middle of page while loading names
            /*
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            */
            
            frame.origin.y = statusBarHeight
            mainViewFrame.origin.y = 0
            
            /*
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.refresher.endRefreshing()
            */
            
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            
            frame.origin.y = -size
            mainViewFrame.origin.y = mainViewOffset + (statusBarHidden ? 15 : 0)
            
        } else {
            
            frame.origin.y = min(statusBarHeight, max(-size, frame.origin.y - scrollDiff))
            let mainScrollOffset = min(0, max(mainViewOffset + (statusBarHidden ? 15 : 0), mainViewFrame.origin.y - scrollDiff))
            mainViewFrame.origin.y = mainScrollOffset
            
        }
        
        self.navigationController!.navigationBar.frame = frame
        self.view.frame = mainViewFrame
        self.updateBarButtonItems(1 - framePercentageHidden)
        self.previousScrollViewYOffset = scrollOffset;
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(!decelerate) {
            stoppedScrolling()
        }
    }
    
    func stoppedScrolling()
    {
        let frame = self.navigationController!.navigationBar.frame;
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
        
        if (frame.origin.y < statusBarHeight) {
            self.animateNavBarTo(-(UIApplication.sharedApplication().statusBarHidden ? 8 : frame.size.height - 21))
        }
    }
    
    func updateBarButtonItems(alpha: CGFloat)
    {
        let leftBarItems:NSArray = self.navigationItem.leftBarButtonItems! as NSArray
        
        for item in leftBarItems {
            if let barItem = item as? UIBarButtonItem {
                barItem.customView?.alpha = alpha
            }
        }
        
        if alpha == 1 {
            rightBarItem.image = UIImage(named: "more.png")
        } else {
            rightBarItem.image = UIImage()
        }
        
    }
    
    
    func animateNavBarTo(y: CGFloat)
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var frame = self.navigationController!.navigationBar.frame
            var mainViewFrame = self.view.frame
            let statusBarHidden = UIApplication.sharedApplication().statusBarHidden
            
            let alpha:CGFloat = (frame.origin.y >= y ? 0 : 1)
            
            frame.origin.y = y + (statusBarHidden ? -20 : 0)
            mainViewFrame.origin.y = y - 21
            
            self.navigationController!.navigationBar.frame = frame
            self.view.frame = mainViewFrame
            
            self.updateBarButtonItems(alpha)
        })
    }

    
    func dayOfWeek(day: Int) -> String{
        
        switch day{
            
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return String(day)
        
        }
        
    }
    
}

class day: UIView {
    
    init(x: CGFloat, y: CGFloat, lessons: [lessonStruct]) {
        
        let width = UIScreen.mainScreen().bounds.width - 32
        let dayView:CGRect = CGRectMake(x, y, width, 35)

        super.init(frame: dayView)

        alpha = 1.0
        
        let dayLabel = UILabel(frame: CGRectMake(0, 0, 80, 20))
        dayLabel.textAlignment = NSTextAlignment.Left
        dayLabel.font = UIFont(name: dayLabel.font.fontName, size: 14)
        dayLabel.textColor = UIColor.whiteColor()
        dayLabel.text = lessons[0].weekday
        
        let dateLabel = UILabel(frame: CGRectMake(width - 120, 0, 120, 20))
        dateLabel.textAlignment = NSTextAlignment.Right
        dateLabel.font = UIFont(name: dateLabel.font.fontName, size: 14)
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.text = lessons[0].dateString
        
        self.addSubview(dayLabel)
        self.addSubview(dateLabel)
        
        var y:CGFloat = 35
        for var x = 0; x < lessons.count; ++x{
            
            let view = event(x: 0, y: y, lesson: lessons[x])
            self.addSubview(view)
            y += 85
            self.frame.size.height += 85
            
            let views = Dictionary(dictionaryLiteral: ("newEvent", view))
            let horrizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[newEvent]|", options: [], metrics: nil, views: views)
            self.addConstraints(horrizontalConstraint)
            
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class event: UIView {
    
    init(x: CGFloat, y: CGFloat, lesson: lessonStruct) {
        
        let width = UIScreen.mainScreen().bounds.width - 32
        let eventView:CGRect = CGRectMake(x, y, width, 75)
        super.init(frame: eventView)
        
        self.backgroundColor = UIColor(white: 1, alpha: 0.3)
        
        let timeLabel = UILabel(frame: CGRectMake(45, 11, 80, 20))
        timeLabel.textAlignment = NSTextAlignment.Left
        timeLabel.font = UIFont(name: timeLabel.font.fontName, size: 14)
        timeLabel.textColor = UIColor(white: 1, alpha: 1)
        timeLabel.text = lesson.time
        self.addSubview(timeLabel)
        
        let nameLabel = UILabel(frame: CGRectMake(17, 33, 200, 40))
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 16)
        nameLabel.textColor = UIColor(white: 1, alpha: 1)
        nameLabel.text = lesson.student
        self.addSubview(nameLabel)
        
        let kidLabel = UILabel(frame: CGRectMake(width - 164, 10, 150, 20))
        kidLabel.textAlignment = NSTextAlignment.Right
        kidLabel.font = UIFont(name: kidLabel.font.fontName, size: 14)
        kidLabel.textColor = UIColor(white: 1, alpha: 1)
        kidLabel.text = lesson.instructor
        self.addSubview(kidLabel)
        
        let clockIcon = "clockImage.png"
        let clockImage = UIImage(named: clockIcon)
        let clockImageView = UIImageView(image: clockImage!)
        clockImageView.frame = CGRectMake(16, 12, 18, 18)
        self.addSubview(clockImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}