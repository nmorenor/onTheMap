//
//  PostingViewController.swift
//  On The Map
//
//  Created by nacho on 5/10/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public class PostingViewController: UIViewController, UITextFieldDelegate, StudentDataUpdateDelegate {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var topView: UIView!
    var button: BorderedButton!
    var testLinkButton: BorderedButton?
    var buttonLabel:UILabel!
    @IBOutlet weak var textField: UITextField!
    private var location:Bool = false
    var alertView:OnTheMapAlertViewController?
    var activityView:OnTheMapActivityViewController?
    var map:MKMapView?
    var tapRecognizer: UITapGestureRecognizer? = nil
    var showMap:Bool = false
    var blue = UIColor(red: 64.0/255.0, green: 116.0/255.0, blue: 167.0/255.0, alpha: 1.0)
    var annotation:StudentLocationMapAnnotation?
    var regex:Regex = Regex(pattern: "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)")
    
    //MARK: - LifeCycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField(self.textField)
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        self.textField.tintColor = UIColor.whiteColor()
        if (UdacityClient.sharedInstance().studentLocation == nil) {
            if let uData = UdacityClient.sharedInstance().userData {
                var params:[String:AnyObject] = [String:AnyObject]()
                params[ParseClient.StudendLocationKeys.UniqueKey] = "\(uData.id!)"
                params[ParseClient.StudendLocationKeys.FirstName] = uData.firstName
                params[ParseClient.StudendLocationKeys.LastName] = uData.lastName
                UdacityClient.sharedInstance().studentLocation = StudentLocation(student: params)
            }
        }
        self.button = BorderedButton()
        configureButton(self.button, title:"Find On The Map", selector: "findOntTheMap:")
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func findOntTheMap(sender: UIButton) {
        if (self.showMap) {
            if (self.regex.test(self.textField!.text!)) {
                UdacityClient.sharedInstance().studentLocation?.mediaURL = NSURL(string: self.textField!.text!)!
                ParseClient.sharedInstance().postStudentLocationWithDelegate(UdacityClient.sharedInstance().studentLocation!, delegate: self)
                self.activityView = OnTheMapActivityViewController()
                self.activityView?.show(self, text: "Processing...")
            } else {
                self.setupNewAlert("Invalid URL please verify it", retry: false)
            }
        } else {
            self.performGeoLocation()
        }
    }
    
    func performGeoLocation() {
        let geod:CLGeocoder = CLGeocoder()
        self.activityView = OnTheMapActivityViewController()
        self.activityView?.show(self, text: "Processing...")
        geod.geocodeAddressString(textField.text!) { placemark, error in
            if (error == nil) {
                if let placemarks = placemark {
                    for next in placemarks {
                        let location = next.location
                        UdacityClient.sharedInstance().studentLocation?.longitude = location!.coordinate.longitude
                        UdacityClient.sharedInstance().studentLocation?.latitude = location!.coordinate.latitude
                        UdacityClient.sharedInstance().studentLocation?.mapString = self.textField!.text
                    }
                }
                if let mediaURL = UdacityClient.sharedInstance().studentLocation?.mediaURL {
                    self.textField.text = mediaURL.absoluteString
                } else {
                    self.textField.text = "https://www.udacity.com"
                }
                self.activityView?.closeView()
                self.activityView = nil
                self.showMap = true
            } else {
                self.activityView?.closeView()
                self.activityView = nil
                self.setupNewAlert("Can not find location", retry: true)
            }
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (self.showMap) {
            self.layoutForMap()
        } else {
            let size = UIScreen.mainScreen().bounds.size
            let yPos = self.midView.frame.origin.y + self.midView.frame.height + (self.bottomView.frame.size.height / 2)
            let labelRect = calculateButtonLabelRect(self.button.titleLabel!.text!, font:self.button.titleLabel!.font!)
            self.button.frame = CGRect(x: (size.width - (labelRect.width + 25)) / 2 , y: yPos - (ceil(labelRect.size.height + 8) / 2), width: labelRect.width + 25, height: ceil(labelRect.size.height + 8))
        }
    }
    
    //MARK: - Controller
    
    func configureButton(button:BorderedButton, title:String, selector:Selector) {
        button.highlightedBackingColor = blue
        button.backingColor = UIColor.whiteColor()
        button.backgroundColor = UIColor.whiteColor()
        button.setTitleColor(blue, forState: UIControlState.Normal)
        button.setTitle(title, forState: UIControlState.Normal)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        self.view.addSubview(button)
    }
    
    func calculateButtonLabelRect(label:String, font:UIFont) -> CGRect {
        let size = UIScreen.mainScreen().bounds.size
        let labelString = label as NSString
        let labelAttr = [NSFontAttributeName:font]
        let labelSize = CGSize(width: size.width, height: 36)
        let labelRect:CGRect = labelString.boundingRectWithSize(labelSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: labelAttr, context: nil)
        return labelRect
    }
    
    func layoutForMap() {
        _ = self.topView.frame.height
        let targetMidHeight = self.midView.frame.height + 25
        let size = UIScreen.mainScreen().bounds.size
        let targetBottomHeight = size.height - targetMidHeight
        self.button.setTitle("Submit", forState: UIControlState.Normal)
        let labelRect = calculateButtonLabelRect(self.button.titleLabel!.text!, font:self.button.titleLabel!.font!)
        let labelLinkRect = calculateButtonLabelRect("Test Media URL", font:self.button.titleLabel!.font!)
        let targetButtonYPos = (targetMidHeight + targetBottomHeight) - ((targetBottomHeight / 4) - (ceil(labelRect.size.height + 8) / 2))
        let targetLinkButtonYPos = ((targetMidHeight - 25) - (ceil(labelLinkRect.size.height + 8) / 2))
        if (self.map == nil) {
            
            self.button.removeFromSuperview()
            self.map = MKMapView(frame: CGRectMake(0, size.height, size.width, targetBottomHeight))
            self.map!.delegate = self
            self.annotation = StudentLocationMapAnnotation(studentLocation: UdacityClient.sharedInstance().studentLocation!)
            self.view.addSubview(self.map!)
            self.view.addSubview(self.button)
            
            self.testLinkButton = BorderedButton()
            self.configureButton(self.testLinkButton!, title:"Test Media URL", selector:"testMediaURL:");
            self.view.addSubview(self.testLinkButton!)
        
            UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: { finished in
            
                self.midView.frame = CGRectMake(0, 0, size.width, targetMidHeight)
                self.bottomView.frame = CGRectMake(0, targetMidHeight, size.width, targetBottomHeight)
                self.map!.frame = CGRectMake(0, targetMidHeight, size.width, targetBottomHeight)
                self.button.frame = CGRect(x: (size.width - (labelRect.width + 25)) / 2 , y: targetButtonYPos - (ceil(labelRect.size.height + 8) / 2), width: labelRect.width + 25, height: ceil(labelRect.size.height + 8))
                
                self.testLinkButton!.frame = CGRect(x: (size.width - (labelLinkRect.width + 25)) / 2 , y: targetLinkButtonYPos - (ceil(labelLinkRect.size.height + 8) / 2), width: labelLinkRect.width + 25, height: ceil(labelLinkRect.size.height + 8))
            }, completion: { finished in
                    self.map!.removeAnnotations(self.map!.annotations)
                    self.map!.addAnnotation(self.annotation!)
            })
        } else {
            self.midView.frame = CGRectMake(0, 0, size.width, targetMidHeight)
            self.bottomView.frame = CGRectMake(0, targetMidHeight, size.width, targetBottomHeight)
            self.map!.frame = CGRectMake(0, targetMidHeight, size.width, targetBottomHeight)
            self.button.frame = CGRect(x: (size.width - (labelRect.width + 25)) / 2 , y: targetButtonYPos - (ceil(labelRect.size.height + 8) / 2), width: labelRect.width + 25, height: ceil(labelRect.size.height + 8))
            self.testLinkButton!.frame = CGRect(x: (size.width - (labelLinkRect.width + 25)) / 2 , y: targetLinkButtonYPos - (ceil(labelLinkRect.size.height + 8) / 2), width: labelLinkRect.width + 25, height: ceil(labelLinkRect.size.height + 8))
        }
    }
    
    func testMediaURL(button:UIButton) {
        if (self.regex.test(self.textField!.text!)) {
            UIApplication.sharedApplication().openURL(NSURL(string: self.textField!.text!)!)
        } else {
            self.setupNewAlert("Invalid URL please verify it", retry: false)
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
                    self.findOntTheMap(self.button)
                }
            }
        }
        self.alertView = nil
    }
    
    func setupTextField(textField:UITextField) {
        textField.delegate = self
    }
    
    //MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    //MARK: - StudentDataUpdateDelegate
    
    public func didUpdateData(success:Bool, errorString:String?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView?.closeView()
            if (success) {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                if (self.alertView == nil) {
                    self.setupNewAlert(errorString!, retry: true)
                }
            }
        }
    }
}