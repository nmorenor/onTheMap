//
//  ColorGradients.swift
//  On The Map
//
//  Created by nacho on 4/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension CAGradientLayer {
    
    class func orangeColor() -> CAGradientLayer {
        let colorTop = UIColor(red: 254.0/255.0, green: 134.0/255.0, blue: 14.0/255.0, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 254.0/255.0, green: 89.0/255.0, blue: 7.0/255.0, alpha: 1.0).CGColor
        
        let gl = CAGradientLayer()
        gl.colors = [colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        
        return gl;
    }
}
