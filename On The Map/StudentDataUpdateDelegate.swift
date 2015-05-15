//
//  StudentDataUpdateDelegate.swift
//  On The Map
//
//  Created by nacho on 5/12/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public protocol StudentDataUpdateDelegate {
    
    func didUpdateData(success:Bool, errorString:String?)
}


