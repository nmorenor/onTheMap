//
//  UdacityUserData.swift
//  On The Map
//
//  Created by nacho on 5/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public struct UdacityUserData {
    
    public var firstName:String?
    public var lastName:String?
    public var id:Int?
    public var nickName:String?
    public var imageUrl:NSURL?
    
    init(dict:[String:AnyObject]) {
        self.firstName = dict[UdacityClient.UdacityUserKeys.FirstName] as? String
        self.lastName = dict[UdacityClient.UdacityUserKeys.LastName] as? String
        if let key = dict[UdacityClient.UdacityUserKeys.UserID] as? String {
            self.id = key.toInt()
        }
        self.nickName = dict[UdacityClient.UdacityUserKeys.NickName] as? String
        if let image = dict[UdacityClient.UdacityUserKeys.ImageURL] as? String {
            self.imageUrl = NSURL(string: image)
        }
    }
}