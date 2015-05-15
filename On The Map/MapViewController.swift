//
//  MapViewController.swift
//  On The Map
//
//  Created by nacho on 5/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public class MapViewController: UIViewController, StudentDataDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var alertView:OnTheMapAlertViewController?
    var activityView:OnTheMapActivityViewController?
    
    //MARK: - LifeCycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController!.tabBar.translucent = true
        
        self.mapView.delegate = self
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        self.view.addSubview(OnTheMapNavigationBarHelper.sharedInstance().navigationBar)
        OnTheMapNavigationBarHelper.sharedInstance().configureNavigationBar()
        OnTheMapNavigationBarHelper.sharedInstance().delegate = self
        OnTheMapNavigationBarHelper.sharedInstance().doRefresh()
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
        self.refreshAnnotations()
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapRecognizer!)
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
    
    //MARK: - StudentDataDelegate
    
    public func didRefresh(success:Bool, errorString:String?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView?.closeView()
            self.activityView = nil
            if (success) {
                self.refreshAnnotations()
            } else {
                self.setupNewAlert(errorString!, retry: false)
            }
        }
    }
    
    private func refreshAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        if let studentLocations = OnTheMapNavigationBarHelper.sharedInstance().students {
            for next in studentLocations {
                self.mapView.addAnnotation(StudentLocationMapAnnotation(studentLocation: next))
            }
        }
    }
    
    public func didLogout() {
        self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func didUpdateData(success:Bool, errorString:String?) {
        //do nothings
    }
    
    public func doRefresh() {
        self.activityView = OnTheMapActivityViewController()
        self.activityView?.show(self, text: "Processing...")
    }
    
    public func doPostData() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("OnTheMapPositioning") as? PostingViewController {
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
}
