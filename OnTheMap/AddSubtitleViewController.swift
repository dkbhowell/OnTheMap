//
//  AddSubtitleViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class AddSubtitleViewController: UIViewController, UITextFieldDelegate, KeyboardAdaptable {

    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var coordinates: (Double, Double)!
    weak var pinDelegate: PostPinDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleTextField.delegate = self
        addKeyboardNotificationObservers()
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if let text = textField.text {
            pinDelegate.postPin(lat: coordinates.0, lng: coordinates.1, subtitle: text)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func addKeyboardNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardShow(notification: NSNotification) {
        keyboardWillShow(notification: notification)
    }
    
    func keyboardHide(notification: NSNotification) {
        keyboardWillHide(notification: notification)
    }
}
