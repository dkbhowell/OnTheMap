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
        let parseClient = ParseClient.shared
        parseClient.getStudents { (studentsResult) in
            switch studentsResult {
            case .success(let students):
                StateController.shared.setStudents(students: students)
            case .failure(let appError):
                print(appError)
            }
        }
        loadUserPin()
    }
    
    func logout() {
        StateController.shared.resetState()
        FBSDKLoginManager().logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshData() {
        let parseClient = ParseClient.shared
        parseClient.getStudents { (studentRayResult) in
            switch studentRayResult {
            case .success(let students):
                let state = StateController.shared
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
        let parseClient = ParseClient.shared
        if let id = StateController.shared.getUser()?.id {
            parseClient.getStudent(withUdacityID: id, completion: { (result) in
                switch result {
                case .success(let student):
                    if let student = student {
                        print("Pin Exists for Student: \(student)")
                        // set user pin
                        StateController.shared.userStudent = student
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
