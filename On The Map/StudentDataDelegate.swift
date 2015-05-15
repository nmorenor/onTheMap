//
//  StudentDataDelegate.swift
//  On The Map
//
//  Created by nacho on 5/7/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public protocol StudentDataDelegate : StudentDataUpdateDelegate {
    
    func didRefresh(success:Bool, errorString:String?)
    
    func didLogout()
    
    func doPostData()
    
    
}
