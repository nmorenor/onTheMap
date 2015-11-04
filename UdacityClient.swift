//
//  UdacityClient.swift
//  On The Map
//
//  Created by nacho on 4/20/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class UdacityClient : NSObject, HTTPClientProtocol {
    
    public var userData:UdacityUserData? = nil
    public var udacitySession:UdacitySession? = nil
    public var studentLocation:StudentLocation? = nil
    var httpClient:HTTPClient!
    
    override init() {
        super.init()
        self.httpClient = HTTPClient(delegate: self)
    }
    
    public func addRequestHeaders(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    public  func processResponse(data: NSData) -> NSData {
        return UdacityClient.processUdacityResponse(data)
    }
    
    public func getBaseURLSecure() -> String {
        return UdacityClient.Constants.BaseURLSecure
    }
    
    public func processJsonBody(jsonBody: [String : AnyObject]) -> [String : AnyObject] {
        let mutableJsonBody = [
            UdacityClient.ParameterKeys.Udacity : jsonBody
        ]
        return mutableJsonBody
    }
    
    //MARK: Utilities
    
    class func processUdacityResponse(data:NSData) -> NSData {
        //protect against no network
        if (data.length <= 0) {
            return data;
        } else {
            return data.subdataWithRange(NSMakeRange(5, data.length - 5))
        }
    }
    
    // MARK: - Shared Instance
    
    public class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
