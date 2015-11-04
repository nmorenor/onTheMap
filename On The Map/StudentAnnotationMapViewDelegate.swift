//
//  StudentAnnotationMapViewDelegate.swift
//  On The Map
//
//  Created by nacho on 5/8/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension MapViewController: MKMapViewDelegate {
    
    public func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let tapRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleAnnotationTap:")
        return MKPinAnnotationWrapperView.createAnnotation(self, mapView:mapView, viewForAnnotation: annotation, tapRecognizer: tapRecognizer)
    }
    
    public func handleAnnotationTap(recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view as? MKPinAnnotationView {
            if (view.selected) {
                if let annotation = view.annotation as? StudentLocationMapAnnotation {
                    if let url = annotation.studentLocation.mediaURL {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        }
    }
    
    public func handleInfoButton(button:UIButton) {

        if let view = button.superview as? MKPinAnnotationWrapperView {
            if (view.annotation.selected) {
                if let annotation = view.annotation.annotation as? StudentLocationMapAnnotation {
                    if let url = annotation.studentLocation.mediaURL {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        }
    }
}
