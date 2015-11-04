//
//  StudentLocation.swift
//  On The Map
//
//  Created by nacho on 5/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class StudentLocation : NSObject {
    
    public var createdAt:NSDate?
    public var firstName:String?
    public var lastName:String?
    public var latitude:Double?
    public var longitude:Double?
    public var mapString:String?
    public var mediaURL:NSURL?
    public var objectId:String?
    public var uniquekey:String
    public var updatedAt:NSDate?
    
    public override var hashValue : Int {
        get {
            return self.uniquekey.hashValue
        }
    }
    
    public convenience init(uniquekey:String) {
        self.init(student:[ParseClient.StudendLocationKeys.UniqueKey : uniquekey as AnyObject])
    }
    
    public init(student:[String:AnyObject]) {
        let uniquekey = student[ParseClient.StudendLocationKeys.UniqueKey] as! String
        self.uniquekey = uniquekey.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        super.init()
        //initialize date formatter
        let dateFormatter = getDateFormatter()
        
        if let createdAt = student[ParseClient.StudendLocationKeys.CreatedAt] as? String {
            self.createdAt = dateFormatter.dateFromString(createdAt)
        }
        if let updatedAt = student[ParseClient.StudendLocationKeys.UpdateAt] as? String {
            self.updatedAt = dateFormatter.dateFromString(updatedAt);
        }
        if let latitude = student[ParseClient.StudendLocationKeys.Latitude] as? Double {
            self.latitude = latitude
        }
        if let longitude = student[ParseClient.StudendLocationKeys.Longitude] as? Double {
            self.longitude = longitude
        }
        
        self.firstName = student[ParseClient.StudendLocationKeys.FirstName] as? String
        self.lastName = student[ParseClient.StudendLocationKeys.LastName] as? String
        self.mapString = student[ParseClient.StudendLocationKeys.MapString] as? String
        if let mediaURL = student[ParseClient.StudendLocationKeys.MediaURL] as? String {
            if let url = NSURL(string:mediaURL) {
                self.mediaURL = url
            }
        }
        if let objectId = student[ParseClient.StudendLocationKeys.ObjectID] as? String {
            self.objectId = objectId
        }
        
        
    }
    
    public func setStudentCreatedAt(createdAt:String) {
        self.createdAt = getDateFormatter().dateFromString(createdAt)
    }
    
    public func setStudentUpdatedAt(updatedAt:String) {
        self.updatedAt = getDateFormatter().dateFromString(updatedAt)
    }
    
    public func getFullName() -> String {
        if let _ = self.firstName {
            if let _ = self.lastName {
                return "\(self.firstName!) \(self.lastName!)"
            } else {
                return self.firstName!
            }
        } else {
            return ""
        }
    }
    
    private func getDateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = HTTPClient.Constants.DateFormat
        return dateFormatter
    }
    
    public func toDictionary() -> [String:AnyObject] {
        var result = [String:AnyObject]()
        
        //initialize date formatter
        let dateFormatter = getDateFormatter()
        
        if let createdAt = self.createdAt {
            result[ParseClient.StudendLocationKeys.CreatedAt] = dateFormatter.stringFromDate(createdAt)
        }
        if let objectId = self.objectId {
            result[ParseClient.StudendLocationKeys.ObjectID] = objectId
        }
        result[ParseClient.StudendLocationKeys.UniqueKey] = self.uniquekey
        
        if let latitude = self.latitude {
            result[ParseClient.StudendLocationKeys.Latitude] = latitude
        }
        if let longitude = self.longitude {
            result[ParseClient.StudendLocationKeys.Longitude] = longitude
        }
        if let firstName = self.firstName {
            result[ParseClient.StudendLocationKeys.FirstName] = firstName
        }
        if let lastName = self.lastName {
            result[ParseClient.StudendLocationKeys.LastName] = lastName
        }
        if let mapString = self.mapString {
            result[ParseClient.StudendLocationKeys.MapString] = mapString
        }
        if let mediaURL = self.mediaURL {
            result[ParseClient.StudendLocationKeys.MediaURL] = mediaURL.absoluteString
        }
        
        return result
    }
}

public func ==(lhs: StudentLocation, rhs: StudentLocation) -> Bool {
    return lhs.hashValue == rhs.hashValue
}