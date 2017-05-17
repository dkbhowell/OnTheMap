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
        
        loadUserPin()
    }
    
    private func logout() {
        // TO DO
    }
    
    private func loadUserPin() {
        let udacityClient = UdacityClient.sharedInstance()
        let parseClient = ParseClient.sharedInstance
        if let id = udacityClient.userId {
            parseClient.getStudent(withUdacityID: id, completion: { (result) in
                switch result {
                case .success(let student):
                    if let student = student {
                        print("Pin Exists for Student: \(student)")
                        // set user pin
                        StateController.sharedInstance.userStudent = student
                    } else {
                        print("No pin exists for student")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }
}
