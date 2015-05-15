//
//  StudentListViewController.swift
//  On The Map
//
//  Created by nacho on 5/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class StudentListViewController:ListViewController, StudentListDelegate {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public func studentSelected(student:StudentLocation) {
        if let mediaURL = student.mediaURL {
            UIApplication.sharedApplication().openURL(mediaURL)
        }
    }
    
    public func setupTableCell(student:StudentLocation, tableCell:UITableViewCell) {
        tableCell.textLabel!.text = student.getFullName()
    }
    
    public func getTableCellReuseIdentifier() -> String {
        return "studentCell"
    }
}