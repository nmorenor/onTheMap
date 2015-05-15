//
//  FlickerStudentListViewController.swift
//  On The Map
//
//  Created by nacho on 5/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class FlickerStudentListViewController:ListViewController, StudentListDelegate {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public func studentSelected(student:StudentLocation) {
        if let viewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("FlickerView") as? FlickerViewController {
            viewController.studentLocation = student
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    public func setupTableCell(student:StudentLocation, tableCell:UITableViewCell) {
        tableCell.textLabel!.text = student.getFullName()
        tableCell.detailTextLabel!.text = student.mapString
    }
    
    public func getTableCellReuseIdentifier() -> String {
        return "flickerStudentCell"
    }
}