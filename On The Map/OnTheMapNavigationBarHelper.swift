//
//  OnTheMapNavigationBarHelper.swift
//  On The Map
//
//  Created by nacho on 5/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

public class OnTheMapNavigationBarHelper : NSObject {
    
    var navigationBar:UINavigationBar!
    var initialized:Bool = false
    var delegate:StudentDataDelegate?
    var students:[StudentLocation]?
    
    override init() {
        super.init()
        self.navigationBar = UINavigationBar()
    }
    
    func configureNavigationBar() {
        if (self.initialized) {
            return
        }
        navigationBar.pushNavigationItem(UINavigationItem(title: "On The Map"), animated: false)
        navigationBar.pushNavigationItem(UINavigationItem(title: ""), animated: false)
        navigationBar.pushNavigationItem(UINavigationItem(title: ""), animated: false)
        navigationBar.topItem!.title = "On The Map"
        navigationBar.translucent = true
        let logout = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "handleLogout:")
        let pin = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "handlePin:")
        let refresh = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "handleRefresh:")
        
        navigationBar.topItem!.leftBarButtonItems = [logout]
        
        navigationBar.topItem!.rightBarButtonItems = [refresh, pin]
        navigationBar.layoutSubviews()
        self.initialized = true
    }
    
    func handleLogout(button:UIBarButtonItem) {
        self.doLogout()
    }
    
    func handlePin(button:UIBarButtonItem) {
        self.delegate?.doPostData()
    }
    
    func handleRefresh(button:UIBarButtonItem) {
        self.doRefresh()
    }
    
    func doLogout() {
        if (UdacityClient.sharedInstance().udacitySession!.facebookSession) {
            FBSDKLoginManager().logOut()
        }
        UdacityClient.sharedInstance().userData = nil
        UdacityClient.sharedInstance().udacitySession = nil
        UdacityClient.sharedInstance().studentLocation = nil
        ParseClient.sharedInstance().skip = 0
        self.students = nil
        
        self.delegate!.didLogout()
    }
    
    func doRefresh() {
        ParseClient.sharedInstance().getStudentLocationsWithDelegate(self.delegate!)
    }
    
    func doUpdate() {
        
    }
    
    public func getStudentsSize() -> Int {
        var result = 0
        if let students = self.students {
            result = students.count
        }
        return result
    }
    
    public class func sharedInstance() -> OnTheMapNavigationBarHelper {
        
        struct Singleton {
            static var sharedInstance = OnTheMapNavigationBarHelper()
        }
        
        return Singleton.sharedInstance
    }
}
