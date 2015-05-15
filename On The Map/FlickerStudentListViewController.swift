//
//  FlickerStudentListViewController.swift
//  On The Map
//
//  Created by nacho on 5/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class FlickerStudentListViewController:UIViewController, StudentDataDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var alertView:OnTheMapAlertViewController?
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //MARK: - lifeCycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.tabBar.translucent = true
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        self.tapRecognizer?.delegate = self
        
        self.view.addSubview(OnTheMapNavigationBarHelper.sharedInstance().navigationBar)
        OnTheMapNavigationBarHelper.sharedInstance().configureNavigationBar()
        OnTheMapNavigationBarHelper.sharedInstance().delegate = self
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutNavigationBar()
    }
    
    func layoutNavigationBar() {
        let size = UIScreen.mainScreen().bounds.size
        OnTheMapNavigationBarHelper.sharedInstance().navigationBar.frame = CGRect(x: 0, y: UIApplication.sharedApplication().statusBarFrame.size.height, width: size.width, height: 44)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        OnTheMapNavigationBarHelper.sharedInstance().delegate = self
        self.view.addSubview(OnTheMapNavigationBarHelper.sharedInstance().navigationBar)
        self.layoutNavigationBar()
        self.tableView.reloadData()
        self.view.addGestureRecognizer(self.tapRecognizer!)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    //MARK: - StudentDataDelegate
    
    public func didRefresh(success:Bool, errorString:String?) {
        dispatch_async(dispatch_get_main_queue()) {
            if (success) {
                self.tableView.reloadData()
            }
        }
    }
    
    public func didLogout() {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func didUpdateData(success:Bool, errorString:String?) {
        //do nothings
    }
    
    public func doPostData() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OnTheMapPositioning") as? PostingViewController {
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.alertView?.closeView(true)
    }
    
    func setupNewAlert(message:String, retry:Bool) {
        self.alertView = OnTheMapAlertViewController()
        self.alertView!.addCloseAction(self.closeAlert)
        self.alertView!.show(self, text: message, retry:retry)
    }
    
    func closeAlert() {
        self.alertView = nil
    }
    
    //MARK: UITableViewDelegate and UITableViewDataSource
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OnTheMapNavigationBarHelper.sharedInstance().getStudentsSize()
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "flickerStudentCell"
        
        let student = OnTheMapNavigationBarHelper.sharedInstance().students![indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        cell.textLabel!.text = student.getFullName()
        cell.detailTextLabel!.text = student.mapString
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let student = OnTheMapNavigationBarHelper.sharedInstance().students?[indexPath.row] {
            if let viewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("FlickerView") as? FlickerViewController {
                viewController.studentLocation = student
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (self.alertView == nil) {
            return false
        }
        return true
    }
}