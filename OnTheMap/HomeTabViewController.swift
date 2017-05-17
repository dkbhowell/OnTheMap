//
//  HomeTabViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/16/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class HomeTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let parseClient = ParseClient.sharedInstance
        parseClient.getStudents { (studentsResult) in
            switch studentsResult {
            case .success(let students):
                print("Successfully got students from Tab Controller")
                StateController.sharedInstance.setStudents(students: students)
            case .failure(let appError):
                print(appError)
            }
        }
    }
}
