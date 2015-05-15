//
//  PostingMapViewDelegate.swift
//  On The Map
//
//  Created by nacho on 5/12/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension PostingViewController: MKMapViewDelegate {
    
    public func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        return MKPinAnnotationWrapperView.createAnnotation(self, mapView:mapView, viewForAnnotation: annotation, tapRecognizer: nil)
    }
    
    public func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        for next in views {
            if let annotationView = next as? MKPinAnnotationView {
                if let annotation = annotationView.annotation {
                    var region:MKCoordinateRegion = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.00725, longitudeDelta: 0.00725))
                    self.map!.setRegion(region, animated: true)
                }
            }
        }
    }
}
