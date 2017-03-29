//
//  LoginController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/17/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        usernameTextField.text = Constants.Debug.MY_USERNAME
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func login(_ sender: UIButton) {
        let udacityClient = UdacityClient.sharedInstance()
        let username = usernameTextField.text!
        let pwd = passwordTextField.text!
        udacityClient.authenticate(username: username, password: pwd) { (result) in
            switch result {
            case .success( _):
                print("Success!!!! 😀")
                performUpdatesOnMain {
                    self.errorLabel.text = " "
                }
            case .failure(let msg):
                print("Failure!!!! 😩")
                performUpdatesOnMain {
                    self.errorLabel.text = msg
                }
            }
        }
    }
    

}



extension LoginController {
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("show keyboard size: \(keyboardSize)")
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("hdie keyboard size: \(keyboardSize)")
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
}

