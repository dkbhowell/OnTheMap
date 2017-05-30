//
//  AddSubtitleViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class AddSubtitleViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: Properties
    var mapPin: MapPin!
    weak var pinDelegate: PostPinDelegate!
    
    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleTextField.delegate = self
        mapView.addAnnotation(mapPin)
        mapView.centerMapOnLocation(lat: mapPin.coordinate.latitude, lng: mapPin.coordinate.longitude, zoomLevel: 5)
        mapView.selectAnnotation(mapPin, animated: true)
        mapView.isScrollEnabled = false
        errorLabel.text = ""
    }
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("Cancelling from Addsubtitle")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitTapped(_ sender: UIButton) {
        guard let text = subtitleTextField.text, text.trimmingCharacters(in: CharacterSet.whitespaces) != "" else {
            let alertController = UIAlertController(title: "Empty Link Detected!", message: "Do you want to update your location with an empty link?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (yesAction) in
                self.postPin(withSubtitle: "")
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard let _ = NetworkUtil.validUrl(fromString: text, addPrefixIfNecessary: true) else {
            let alertController = UIAlertController(title: "Invalid Link Detected!", message: "Do you want to update your location with an invalid link?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (yesAction) in
                self.postPin(withSubtitle: text)
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        postPin(withSubtitle: text)
    }
    
    // MARK: TextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = string
        if let existingText = textField.text {
            newString = NSString(string: existingText).replacingCharacters(in: range, with: string)
        }
        if let _ = NetworkUtil.validUrl(fromString: newString, addPrefixIfNecessary: true) {
            textField.backgroundColor = nil
            errorLabel.text = ""
            mapPin.subtitle = newString
            mapView.deselectAnnotation(mapPin, animated: false)
            mapView.selectAnnotation(mapPin, animated: false)
        } else {
            textField.backgroundColor = UIColor.red
            errorLabel.text = "Invalid URL -- please edit your URL"
        }
        return true
    }
    
    // MARK: Helper functions
    private func showErrorMessage(msg: String) {
        showAlertController(hostController: self, title: "Error", msg: msg)
    }
    private func postPin(withSubtitle subtitle: String) {
        pinDelegate.postPin(lat: mapPin.coordinate.latitude, lng: mapPin.coordinate.longitude, subtitle: subtitle)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
