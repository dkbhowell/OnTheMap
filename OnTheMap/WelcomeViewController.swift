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
        
        if let nickname = state.nickname {
            nickameLabel.text = nickname
        }
        
        if let firstName = state.firstName {
            firstNameLabel.text = firstName
        }
        
        if let lastName = state.lastName {
            lastNameLabel.text = lastName
        }
        
        if let email = state.email {
            emailLabel.text = email
        }
        
        if let sessionId = udacityClient.sessionId {
            sessionIdLabel.text = sessionId
        }
        
        if let userId = udacityClient.userId {
            userIdLabel.text = userId
        }
        
        parseClient.getStudents { (result) in
            switch result {
            case .success(let students):
                print("Success, Students!: \(students)")
            case .failure(let reason):
                print("Failed.. reason: \(reason)")
            }
        }
    }
    
    @IBAction func goMapGo(_ sender: UIButton) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "TestMapController")
        present(controller, animated: true, completion: nil)
    }
    
    

}
