
//  LoginController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/17/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
//import FacebookLogin
import FBSDKLoginKit

class LoginController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    let state = StateController.sharedInstance
    
    // Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        usernameTextField.text = Constants.Debug.MY_USERNAME
        fbLoginButton.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text != "" {
            login(loginButton)
        }
        return true
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        // TODO
        print("Login Error parameter: \(error)")
        if result.isCancelled {
            print("user cancelled login attempt")
            return
        }
        print("Login token: \(result.token)")
        print("Granted permissions: \(result.grantedPermissions)")
        print("Denied permissions: \(result.declinedPermissions)")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // TODO
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
                    self.completeLogin()
                }
            case .failure(let msg):
                print("Failure!!!! 😩")
                performUpdatesOnMain {
                    self.errorLabel.text = msg
                }
            }
        }
    }
    
    func completeLogin() {
        errorLabel.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        let controller = storyboard!.instantiateViewController(withIdentifier: "HomeTabViewController") as! HomeTabViewController
        present(controller, animated: true, completion: nil)
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

