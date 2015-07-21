//
//  ViewStyle.swift
//  My Swim Schedule
//
//  Created by Reece Jackson on 6/24/15.
//  Copyright (c) 2015 RJ. All rights reserved.
//

import UIKit

class ViewStyle: UIViewController {
    
    var statusBarView: UIView!
    var statusBarImageView: UIImageView!
    var tabBarView: UIView!
    var backgroundImageView: UIImageView!
    
    var refresher: UIRefreshControl!
    
    var lessonArray = [lessonStruct()]
    
    var previousScrollViewYOffset:CGFloat = 0.0
    var mainViewOffset:CGFloat = -44
    
    override func viewDidLoad() {
        
        setBackground("background.png")
        
    }
    
    func setBackground(backgroundImage: String) {
        
        let backgroundImage = UIImage(named: backgroundImage)
        backgroundImageView = UIImageView(image: backgroundImage!)
        backgroundImageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - mainViewOffset)
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImageView.alpha = 1.0
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        let views = Dictionary(dictionaryLiteral: ("backgroundView", backgroundImageView))
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[backgroundView]|", options: [], metrics: nil, views: views)
        self.view.addConstraints(horizontalConstraints)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func leftNavTitle(title: String) -> UIView {
        
        let width = CGFloat(320.0)
        let height = CGFloat(20.0)
        let xOffset = CGFloat(-8)
        
        let customView = UIView(frame: CGRectMake(0, 0, width, height))
        let titleView = UIView(frame: CGRectMake(xOffset, 0, 100, height))
        let titleText = UILabel(frame: CGRectMake(0, 0, 150, height))
        
        titleText.text = title
        titleText.font = UIFont(name: titleText.font.fontName, size: 18)
        titleText.textColor = UIColor.whiteColor()
        titleText.textAlignment = NSTextAlignment.Left
        
        titleView.addSubview(titleText)
        customView.addSubview(titleView)
        
        return customView
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

struct lessonStruct {
    
    var time:String!
    var dateString:String!
    var date:NSDate!
    var weekday: String!
    var client:String!
    var student:String!
    var instructor:String!
    
    init(){}
    
    init(time: String, dateString: String, date: NSDate, weekday: String, client: String, student: String, instructor:String){
        
        self.time = time
        self.dateString = dateString
        self.date = date
        self.weekday = weekday
        self.client = client
        self.student = student
        self.instructor = instructor
        
    }
    
}
