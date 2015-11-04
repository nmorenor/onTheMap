//
//  StudentLocationMapAnnotation.swift
//  On The Map
//
//  Created by nacho on 5/8/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit

public class StudentLocationMapAnnotation: NSObject, MKAnnotation {
    
    public let title:String?
    public let subtitle:String?
    public let coordinate:CLLocationCoordinate2D
    let studentLocation:StudentLocation
    
    init(studentLocation:StudentLocation) {
        self.title = studentLocation.getFullName()
        
        if let subtitle = studentLocation.mediaURL?.absoluteString {
            self.subtitle = subtitle
        } else {
            self.subtitle = ""
        }
        
        self.studentLocation = studentLocation
        self.coordinate = CLLocationCoordinate2D(latitude: Double(studentLocation.latitude!), longitude: Double(studentLocation.longitude!))
        super.init()
    }
    
    
}
