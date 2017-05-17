//
//  WelcomeViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let state = StateController.sharedInstance
    let udacityClient = UdacityClient.sharedInstance()
    let parseClient = ParseClient.sharedInstance
    
    // Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nickameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var sessionIdLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = state.getUser() {
            if let nickname = user.nickname {
                nickameLabel.text = nickname
            }
            firstNameLabel.text = user.firstName
            lastNameLabel.text = user.lastName
            
            if let email = user.email {
                emailLabel.text = email
            }
            
            if let sessionId = udacityClient.sessionId {
                sessionIdLabel.text = sessionId
            }
            
            if let userId = udacityClient.userId {
                userIdLabel.text = userId
            }
        }
        
        loadUserPin()
        
    }
    
    @IBAction func goMapGo(_ sender: UIButton) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "StudentTabController")
        present(controller, animated: true, completion: nil)
    }
    
    private func loadUserPin() {
        if let id = udacityClient.userId {
            parseClient.getStudent(withUdacityID: id, completion: { (result) in
                switch result {
                case .success(let student):
                    if let student = student {
                        print("Pin Exists for Student: \(student)")
                        // set user pin
                        self.state.userStudent = student
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
