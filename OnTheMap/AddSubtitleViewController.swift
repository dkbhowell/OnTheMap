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
    @IBOutlet weak var errorLabel: UILabel!
    
    var coordinates: (Double, Double)!
    var completion: ( (Double, Double, String) -> () )!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleTextField.delegate = self
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let presentingFirst = presentingViewController
        let presentingSecond = presentingViewController?.presentingViewController
        print("Presenting: \(presentingFirst)")
        print("Presenting 2: \(presentingSecond)")
        
        
        if let text = textField.text {
            completion(coordinates.0, coordinates.1, text)
        }
        
        let mapController = presentingViewController?.presentingViewController as? MapViewController
        if let mapController = mapController, let text = textField.text {
            print("Posting New Pin From Subtitle Controller")
            mapController.postPin(lat: coordinates.0, lng: coordinates.1, subtitle: text)
        } else {
            print("MapController: \(String(describing: mapController))")
            print("Text: \(String(describing: textField.text))")
        }
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
