
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
    
    // MARK: Properties
    let state = StateController.shared
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.text = Constants.Debug.MY_USERNAME
        fbLoginButton.delegate = self
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
        // change size of fb button
        for constraint in fbLoginButton.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height {
                print("Changing fb height")
                constraint.constant = 40
            }
        }
        imageView.layer.cornerRadius = 8.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let fbAccessToken = FBSDKAccessToken.current() {
            showLoadingSpinner()
            loginWithFacebook(usingAccessToken: fbAccessToken)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addKeyboardNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardNotificationObservers()
    }
    
    // MARK: TextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
    // MARK: FBSDKLoginButtonDelegate methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
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
    
    // MARK: Login with Facebook
    func loginWithFacebook(usingAccessToken token: FBSDKAccessToken) {
        guard let tokenString = token.tokenString else {
            print("Token does not have a token string")
            return
        }
        let udacityClient = UdacityClient.shared
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
    
    // MARK: Login with Udacity
    @IBAction func login(_ sender: UIButton) {
        let udacityClient = UdacityClient.shared
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
                self.showAuthenticationError(error: appError)
            }
        }
    }
    
    // MARK: Core methods
    func completeLogin() {
        errorLabel.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        let controller = storyboard!.instantiateViewController(withIdentifier: "HomeTabViewController") as! HomeTabViewController
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let url = URL(string: UdacityClient.StaticURL.signup)
        guard let signUpURL = url else {
            print("URL creation for sign up failed")
            return
        }
        UIApplication.shared.open(signUpURL, options: [:], completionHandler: nil)
    }
    
    // MARK: Helper Methods
    private func showLoadingSpinner() {
        let alert = UIAlertController(title: "Please Wait", message: "Logging into Facebook...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func resetViews() {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func showAuthenticationError(error: AppError) {
        var errorText = "Something Went Wrong..."
        switch error {
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
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension LoginController {
    // MARK: Keyboard Show / Hide
    func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 20
        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }
}
