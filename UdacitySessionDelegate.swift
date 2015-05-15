//
//  UdacitySessionDelegate.swift
//  On The Map
//
//  Created by nacho on 5/2/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

public protocol UdacitySessionDelegate {
    
    func loginDidComplete(button:UIButton)
    
    func loginDidCompleteWithError(error:String, retry:Bool, button:UIButton)
}