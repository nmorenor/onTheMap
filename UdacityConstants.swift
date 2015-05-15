//
//  UdacityConstants.swift
//  On The Map
//
//  Created by nacho on 4/20/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct Constants {
        
        static let BaseURLSecure:String = "https://www.udacity.com/api/"
        static let SignUpURL:NSURL = NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
    }
    
    struct Methods {
        static let Session = "session"
        static let Users = "users/{id}"
    }
    
    struct URLKeys {
        static let UserID = "id"
    }
    
    struct ParameterKeys {
        static let Udacity = "udacity"
        static let UserName = "username"
        static let Password = "password"
    }
    
    struct FacebookKeys {
        static let FacebookMobile = "facebook_mobile"
        static let AccessToken = "access_token"
    }
    
    struct JSONResponseKeys {
        static let Status = "status"
        static let ErrorMessage = "error"
        static let Session = "session"
        static let User = "user"
    }
    
    struct UdacitySessionKeys {
        static let Id = "id"
        static let Expiration = "expiration"
        static let Account = "account"
        static let AccountID = "key"
    }
    
    struct UdacityUserKeys {
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let UserID = "key"
        static let ImageURL = "_image_url"
        static let NickName = "nickname"
    }
    
}
