//
//  StudentListDelegate.swift
//  On The Map
//
//  Created by nacho on 5/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public protocol StudentListDelegate {
    
    func studentSelected(student:StudentLocation)
    
    func setupTableCell(student:StudentLocation, tableCell:UITableViewCell)
    
    func getTableCellReuseIdentifier() -> String
}
