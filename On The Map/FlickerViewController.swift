//
//  FlickerViewController.swift
//  On The Map
//
//  Created by nacho on 5/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class FlickerViewController: UIViewController, FlickerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var alertView:OnTheMapAlertViewController?
    var activityView:OnTheMapActivityViewController?
    var studentLocation:StudentLocation?
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var showMore: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.titleLabel.text = self.studentLocation!.mapString
        self.view.addGestureRecognizer(self.tapRecognizer!)
        self.showMore.layer.cornerRadius = 4
        self.closeButton.layer.cornerRadius = 4
        if (self.imageView.image == nil) {
            self.loadPicture()
        }
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    @IBAction func showMore(sender: UIButton) {
        self.loadPicture()
    }
    
    func loadPicture() {
        self.activityView = OnTheMapActivityViewController()
        self.activityView?.show(self, text: "Processing...")
        FlickerClient.sharedInstance().getImageFromFlickerSearch(self.studentLocation!, delegate: self)
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func didSearchStudentLocationImage(success:Bool, imageURL: NSURL?, errorString: String?) {
        let validAPI = FLICKR_API_KEY.rangeOfString("FLICKER_API") == nil
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView?.closeView()
            self.activityView = nil
            if (success) {
                if let imageData = NSData(contentsOfURL: imageURL!) {
                    self.imageView.image = UIImage(data: imageData)
                } else {
                    if (validAPI) {
                        self.setupNewAlert(errorString!, retry: true)
                    } else {
                        self.setupNewAlert("Invalid Flicker api key", retry: false)
                    }
                }
            } else {
                if (validAPI) {
                    self.setupNewAlert(errorString!, retry: true)
                } else {
                    self.setupNewAlert("Invalid Flicker api key", retry: false)
                }
            }
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
        if let alertView = self.alertView {
            if (alertView.shouldRetry) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadPicture()
                }
            }
        }
        self.alertView = nil
    }
}
