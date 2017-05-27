//
//  HomeTabViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/16/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

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
    
    func logout() {
        // TO DO
        StateController.sharedInstance.resetState()
        FBSDKLoginManager().logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshData() {
        let parseClient = ParseClient.sharedInstance
        parseClient.getStudents { (studentRayResult) in
            switch studentRayResult {
            case .success(let students):
                let state = StateController.sharedInstance
                state.setStudents(students: students)
            case .failure(let appError):
                print(appError)
                let alertController = UIAlertController(title: "Error refreshing data from network", message: "Please check your connection and try again", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func loadUserPin() {
        let parseClient = ParseClient.sharedInstance
        if let id = StateController.sharedInstance.getUser()?.id {
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
