//
//  WelcomeViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    let udacityClient = UdacityClient.sharedInstance()
    
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
        
        if let nickname = udacityClient.nickname {
            nickameLabel.text = nickname
        }
        
        if let firstName = udacityClient.firstName {
            firstNameLabel.text = firstName
        }
        
        if let lastName = udacityClient.lastName {
            lastNameLabel.text = lastName
        }
        
        if let email = udacityClient.email {
            emailLabel.text = email
        }
        
        if let sessionId = udacityClient.sessionId {
            sessionIdLabel.text = sessionId
        }
        
        if let userId = udacityClient.userId {
            userIdLabel.text = userId
        }
    }
    
    @IBAction func goMapGo(_ sender: UIButton) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "TestMapController")
        present(controller, animated: true, completion: nil)
    }
    
    

}
