//
//  UdacitySession.swift
//  On The Map
//
//  Created by nacho on 4/30/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public struct UdacitySession {
    
    public var session:String?
    public var expiration:NSDate?
    public var userID:Int?
    public var facebookSession:Bool
    
    init(session:[String:AnyObject]?, account:[String:AnyObject]?, facebookSession:Bool) {
        self.session = session?[UdacityClient.UdacitySessionKeys.Id] as? String
        if let date = session?[UdacityClient.UdacitySessionKeys.Expiration] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = HTTPClient.Constants.DateFormat
            self.expiration = dateFormatter.dateFromString(date)
        }
        if let uid = account?[UdacityClient.UdacitySessionKeys.AccountID] as? String {
            self.userID = Int(uid)
        }
        self.facebookSession = facebookSession
    }
}
