//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    let tfDelegate: UITextFieldDelegate = LocationTextFieldDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = tfDelegate
    }
}
