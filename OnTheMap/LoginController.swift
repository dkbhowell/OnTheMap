
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
    let signUpURL = "https://www.udacity.com/account/auth#!/signup"
    
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
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        
        if let fbAccessToken = FBSDKAccessToken.current() {
            print("Found FB Access Token -- logging in with Facebook")
            loginWithFacebook(usingAccessToken: fbAccessToken)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() != nil {
            showLoadingSpinner()
        }
    }
    
    func showLoadingSpinner() {
        let alert = UIAlertController(title: "Please Wait", message: "Logging into Facebook...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        print("Presenting Alert Controller")
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Text field shoudl return..........")
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            if let userText = usernameTextField.text, let pwdText = passwordTextField.text,
                userText != "", pwdText != ""
            {
                login(UIButton())
            }
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Facebook login button delegate methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        // TODO
        print("Login Error parameter: \(error)")
        print("Login token: \(result.token)")
        print("Granted permissions: \(result.grantedPermissions)")
        print("Denied permissions: \(result.declinedPermissions)")
        guard !result.isCancelled else {
            print("user cancelled login attempt")
            return
        }
        guard result.declinedPermissions.count <= 0 else {
            print("user denied permissions; sign in unsuccesful")
            return
        }
        guard result.grantedPermissions.count >= 0 else {
            print("No permissions granted to the app; sign in unsuccessful")
            return
        }
        
        if let accessToken = FBSDKAccessToken.current() {
            showLoadingSpinner()
            loginWithFacebook(usingAccessToken: accessToken)
        } else {
            print("FB Access Token not found")
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("login button did log out")
    }
    
    func loginWithFacebook(usingAccessToken token: FBSDKAccessToken) {
        guard let tokenString = token.tokenString else {
            print("Token does not have a token string")
            return
        }
        let udacityClient = UdacityClient.sharedInstance()
        udacityClient.authenticateWithFacebook(fbToken: tokenString, completionForFbAuth: { (result) in
            self.dismiss(animated: true, completion: nil)
            switch result {
            case .success(_):
                executeOnMain {
                    print("FB Auth Success!!!! 😀")
                    self.completeLogin()
                }
            case .failure(let appError):
                print("FB Auth Fail!!!! 😩")
                print(appError)
            }
        })
    }
    
    @IBAction func login(_ sender: UIButton) {
        let udacityClient = UdacityClient.sharedInstance()
        guard let username = usernameTextField.text, let pwd = passwordTextField.text else {
            print("No username or password")
            return
        }
        udacityClient.authenticate(username: username, password: pwd) { (result) in
            switch result {
            case .success( _):
                print("Success!!!! 😀")
                executeOnMain {
                    self.completeLogin()
                }
            case .failure(let appError):
                print("Failure!!!! 😩")
                var errorText = "Something Went Wrong"
                switch appError {
                case .NetworkError:
                    errorText = "Authentication Failed: Unable to reach network -- please check your connection and try again"
                case .ParseError:
                    errorText = "Authentication Failed: Unexpected value in request or response, please try again"
                case .AuthenticationError:
                    errorText = "Authentication Failed: Invalid username or password, please try again"
                case .UnexpectedResult:
                    errorText = "Authentication Failed: Invalid credentials, please try again"
                }
                executeOnMain {
                    let alertController = UIAlertController(title: "Authentication Failure", message: errorText, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { action in
                        self.resetViews()
                        self.dismiss(animated: true, completion: nil)
                    })
                    self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let url = URL(string: signUpURL)
        guard let signUpURL = url else {
            print("URL creation for sign up failed")
            return
        }
        UIApplication.shared.open(signUpURL, options: [:], completionHandler: nil)
    }
    
    private func resetViews() {
        usernameTextField.text = ""
        passwordTextField.text = ""
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

