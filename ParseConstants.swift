//
//  ParseConstants.swift
//  On The Map
//
//  Created by nacho on 5/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

extension ParseClient {
    
    struct Constants {
        static let BaseSecureURL = "https://api.parse.com/1/classes/"
    }
    
    struct Methods {
        static let StudentLocation = "StudentLocation"
        static let StudentLocationWithID = "StudentLocation/{id}"
    }
    
    struct MethodParameters {
        static let Limit = "limit"
        static let Where = "where"
        static let Skip = "skip"
    }
    
    struct JSONResponseKeys {
        static let Results = "results"
        static let CreatedAt = "createdAt"
        static let ObjectId = "objectId"
        static let Error = "error"
        static let Code = "code"
    }
    
    struct StudendLocationKeys {
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdateAt = "updatedAt"
    }
}