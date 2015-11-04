//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by nacho on 4/30/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    public func getSessionIDWithDelegate(user:String, password:String, udacitySessionDelegate:UdacitySessionDelegate, button:UIButton) {
        self.getSessionID(user, password:password) { success, session, errorString in
            if (success) {
                udacitySessionDelegate.loginDidComplete(button)
            } else {
                if (errorString?.rangeOfString("Login Failed") != nil) {
                    udacitySessionDelegate.loginDidCompleteWithError(errorString!, retry:true, button:button)
                } else {
                    udacitySessionDelegate.loginDidCompleteWithError(errorString!, retry:false, button:button)
                }
            }
        }
    }
    
    public func getSessionIDWithDelegate(token:String, udacitySessionDelegate:UdacitySessionDelegate, button:UIButton) {
        self.getSessionID(token) { success, session, errorString in
            if (success) {
                udacitySessionDelegate.loginDidComplete(button)
            } else {
                udacitySessionDelegate.loginDidCompleteWithError(errorString!, retry:false, button:button)
            }
        }
    }
    
    public func getSessionID(user:String, password:String, completionHandler: (success:Bool, session:UdacitySession?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        let credentials = [
            UdacityClient.ParameterKeys.UserName : user,
            UdacityClient.ParameterKeys.Password : password
        ]
        let task = self.httpClient.taskForPOSTMethod(UdacityClient.Methods.Session, parameters: [String:AnyObject](), jsonBody: credentials) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, session: nil, errorString: "Login Failed")
            } else {
                self.handleSessionResult(JSONResult, facebookSession:false , error: error, completionHandler: completionHandler)
            }
        }
        return task;
    }
    
    public func getSessionID(token:String, completionHandler: (success:Bool, session: UdacitySession?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        _ = [
            UdacityClient.FacebookKeys.FacebookMobile: [UdacityClient.FacebookKeys.AccessToken : token]
        ]
        let task = self.httpClient.taskForGETMethod(UdacityClient.Methods.Session, parameters: [String:AnyObject]()) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, session: nil, errorString: "Login Failed (Facebook)")
            } else {
                self.handleSessionResult(JSONResult, facebookSession:true, error: error, completionHandler: completionHandler)
            }
        }
        return task
    }
    
    private func handleSessionResult(JSONResult:AnyObject, facebookSession:Bool, error:NSError?, completionHandler: (success:Bool, session:UdacitySession?, errorString:String?) -> Void) {
        if let sessionKey = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Session) as? [String:AnyObject] {
            if let accountKey = JSONResult.valueForKey(UdacityClient.UdacitySessionKeys.Account) as? [String:AnyObject] {
                self.udacitySession = UdacitySession(session: sessionKey, account:accountKey, facebookSession: facebookSession)
            } else {
                self.udacitySession = UdacitySession(session: sessionKey, account:nil, facebookSession: facebookSession)
            }
            if let userID = self.udacitySession?.userID {
                self.getUserData(userID) { success, userData, errorString in
                    if (success) {
                        if let userData = userData {
                            self.userData = userData
                        }
                    }
                }
            }
            completionHandler(success: true, session: self.udacitySession, errorString: nil)
        } else {
            if let authError = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.ErrorMessage) as? String {
                completionHandler(success: false, session: nil, errorString: authError)
            } else {
                completionHandler(success: false, session: nil, errorString: "Login Failed (Bad request)")
            }
        }
    }
    
    public func getUserData(userID:Int, completionHandler: (success:Bool, userData:UdacityUserData?, errorString:String?) -> Void) -> NSURLSessionDataTask {
        let mutableMethod = HTTPClient.substituteKeyInMethod(UdacityClient.Methods.Users, key: UdacityClient.URLKeys.UserID, value: "\(userID)")!
        let task = self.httpClient.taskForGETMethod(mutableMethod, parameters: [String:AnyObject]()) { JSONResult, error in
            if let _ = error {
                completionHandler(success: false, userData: nil, errorString: "User Data Request Error")
            } else {
                if let user = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.User) as? [String:AnyObject] {
                    let result = UdacityUserData(dict: user)
                    if let session = self.udacitySession {
                        if (session.userID == result.id) {
                            self.userData = result
                            
                            //try to locate the logged in student location data
                            if let uid = self.userData?.id {
                                ParseClient.sharedInstance().searchStudentByKey("\(uid)") { success, studentLocation, errorString in
                                    if (success) {
                                        self.studentLocation = studentLocation
                                    } else {
                                        var params:[String:AnyObject] = [String:AnyObject]()
                                        params[ParseClient.StudendLocationKeys.UniqueKey] = "\(self.userData!.id!)"
                                        params[ParseClient.StudendLocationKeys.FirstName] = self.userData!.firstName
                                        params[ParseClient.StudendLocationKeys.LastName] = self.userData!.lastName
                                        self.studentLocation = StudentLocation(student: params)
                                    }
                                }
                            }
                        }
                    }
                    
                    completionHandler(success: true, userData: result, errorString: nil)
                } else {
                    if let userError = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.ErrorMessage) as? String {
                        completionHandler(success: false, userData: nil, errorString: userError)
                    } else {
                        completionHandler(success: false, userData: nil, errorString: "Can not get user data")
                    }
                }
            }
        }
        return task
    }
}
