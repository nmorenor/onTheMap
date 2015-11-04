//
//  LoginViewController.swift
//  On The Map
//
//  Created by nacho on 4/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

public class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate, UdacitySessionDelegate {

    private var orangeGradient:CAGradientLayer!
    public var sessionDelegate:UdacitySessionDelegate?
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet public weak var facebookLoginButton: FBSDKLoginButton!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var alertView:OnTheMapAlertViewController?
    var activityView:OnTheMapActivityViewController?
    
    @IBOutlet weak var emailTextField: BorderedTextField!
    @IBOutlet weak var passwordTextField: BorderedTextField!

    //MARK: - LifeCycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.facebookLoginButton.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        setupTextField(emailTextField)
        setupTextField(passwordTextField)
        
        self.sessionDelegate = self
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardDismissRecognizer()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeKeyboardDismissRecognizer()
    }
    
    //MARK: - TapRecognizer
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.alertView?.closeView(true)
    }

    @IBAction func login(sender: UIButton) {
        
        if (emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty) {
            self.setupNewAlert("Email and password can not be empty", retry:false)
            return
        }
        self.activityView = OnTheMapActivityViewController()
        self.activityView?.show(self, text: "Processing...")
        UdacityClient.sharedInstance().getSessionIDWithDelegate(self.emailTextField.text!, password: self.passwordTextField.text!, udacitySessionDelegate: self.sessionDelegate!, button: self.loginButton)
        
        self.loginButton.enabled = false
    }
    
    @IBAction func signUp(sender: UIButton) {
        UIApplication.sharedApplication().openURL(UdacityClient.Constants.SignUpURL)
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
                    self.login(self.loginButton)
                }
            }
        }
        self.alertView = nil
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - LoginViewController
    
    func configureUI() {
        orangeGradient = CAGradientLayer.orangeColor();
        orangeGradient.frame = self.view.bounds
        self.view.layer.insertSublayer(orangeGradient, atIndex: 0)
        
        self.setupButtonFont(loginButton, fontName: "Roboto-Medium")
        loginButton.highlightedBackingColor = UIColor(red: 240.0/255.0, green: 62.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        loginButton.backingColor = UIColor(red: 240.0/255.0, green: 72.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        loginButton.backgroundColor = UIColor(red: 240.0/255.0, green: 72.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        self.setupLabelFont(self.loginLabel, fontName:"AvenirNext-Medium")
        self.setupLabelFont(self.accountLabel, fontName:"Roboto-Regular")
        self.setupButtonFont(self.signUpButton, fontName: "Roboto-Regular")
    }
    
    func setupLabelFont(label:UILabel, fontName:String) {
        label.font = UIFont(name: fontName, size: 17.0)
    }
    
    func setupButtonFont(button:UIButton, fontName:String) {
        button.titleLabel?.font = UIFont(name: fontName, size: 17.0)
    }
    
    func setupTextField(textField:BorderedTextField) {
        textField.delegate = self
    }
    
    //MARK: - FacebookLogin
    
    public func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) == nil) {
            if let _ = result {
                if let facebookToken = FBSDKAccessToken.currentAccessToken() {
                    if let token = facebookToken.tokenString {
                        UdacityClient.sharedInstance().getSessionIDWithDelegate(token, udacitySessionDelegate: self.sessionDelegate!, button: self.facebookLoginButton)
                    }
                }
            }
        } else {
            self.sessionDelegate?.loginDidCompleteWithError("Error on Facebook login", retry:false, button:self.facebookLoginButton)
        }
    }
    
    public func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //do nothing
    }
    
    //MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    //MARK: - UdacitySessionDelegate
    
    public func loginDidComplete(button:UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView?.closeView()
            self.activityView = nil
            button.enabled = true
            self.passwordTextField.text = ""
            self.emailTextField.text = ""
            self.performSegueWithIdentifier("showTabBar", sender: self)
            
        }
    }
    
    public func loginDidCompleteWithError(error:String, retry:Bool, button:UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView?.closeView()
            self.activityView = nil
            button.enabled = true
            self.setupNewAlert(error, retry:retry)
        }
    }
}

