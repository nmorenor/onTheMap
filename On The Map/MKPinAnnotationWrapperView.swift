//
//  MKPinAnnotationWrapperView.swift
//  On The Map
//
//  Created by nacho on 5/12/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MKPinAnnotationWrapperView: UIView {
    
    var annotation:MKPinAnnotationView!
    
    class func createAnnotation(target:UIViewController, mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!, tapRecognizer:UITapGestureRecognizer?) -> MKPinAnnotationView? {
        if let annotation = annotation as? StudentLocationMapAnnotation {
            let identifier = "pin"
            var view:MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y:5)
                let button = UIButton(type: UIButtonType.DetailDisclosure)
                button.addTarget(target, action: "handleInfoButton:", forControlEvents: UIControlEvents.TouchUpInside)
                let calloutView = MKPinAnnotationWrapperView(frame: CGRectMake(0, 0, button.frame.width, button.frame.height))
                calloutView.addSubview(button)
                calloutView.annotation = view
                
                view.rightCalloutAccessoryView = calloutView
                
                let left = UIView()
                let titleLabel = UILabel()
                titleLabel.tag = 21
                titleLabel.text = annotation.title
                
                let subtitleLabel = UILabel()
                subtitleLabel.tag = 42
                subtitleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
                subtitleLabel.text = annotation.subtitle
                
                left.addSubview(titleLabel)
                left.addSubview(subtitleLabel)
                
                view.leftCalloutAccessoryView = left
                
                if let tapRecognizer = tapRecognizer {
                    tapRecognizer.numberOfTapsRequired = 1
                
                    view.addGestureRecognizer(tapRecognizer)
                }
            }
            
            if let titleLabel = view.leftCalloutAccessoryView!.viewWithTag(21) as? UILabel {
                titleLabel.text = annotation.title
                titleLabel.textAlignment = NSTextAlignment.Left
            }
            
            if let subtitleLabel = view.leftCalloutAccessoryView!.viewWithTag(42) as? UILabel {
                subtitleLabel.text = annotation.subtitle
                subtitleLabel.textAlignment = NSTextAlignment.Left
            }
            
            if let calloutView = view.rightCalloutAccessoryView as? MKPinAnnotationWrapperView {
                calloutView.annotation = view
            }
            
            return view
        }
        return nil
    }
}
