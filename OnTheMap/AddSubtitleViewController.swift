//
//  AddSubtitleViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class AddSubtitleViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var subtitleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleTextField.delegate = self
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
