//
//  AddSubtitleViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class AddSubtitleViewController: UIViewController, UITextFieldDelegate, KeyboardAdaptable {

    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var coordinates: (Double, Double)!
    var mapPin: MapPin!
    weak var pinDelegate: PostPinDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleTextField.delegate = self
        let userName = StateController.sharedInstance.getUser()?.name ?? "New Location"
        mapPin = MapPin(lat: coordinates.0, lng: coordinates.1, title: userName, subtitle: "")
        mapView.addAnnotation(mapPin)
        mapView.centerMapOnLocation(lat: mapPin.coordinate.latitude, lng: mapPin.coordinate.longitude, zoomLevel: 5)
        mapView.selectAnnotation(mapPin, animated: true)
        doneButton.isEnabled = false
        mapView.isScrollEnabled = false
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("Cancelling from Addsubtitle")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        if let text = subtitleTextField.text {
            postPin(withSubtitle: text)
        } else {
            postPin(withSubtitle: "")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = string
        if let existingText = textField.text {
            newString = NSString(string: existingText).replacingCharacters(in: range, with: string)
        }
        
        if isValidURL(urlString: newString) {
            textField.backgroundColor = nil
            clearErrorMessage()
            doneButton.isEnabled = true
            mapPin.subtitle = newString
            mapView.deselectAnnotation(mapPin, animated: false)
            mapView.selectAnnotation(mapPin, animated: false)
        } else {
            textField.backgroundColor = UIColor.red
            showErrorMessage(msg: "Invalid URL: Please enter a valid URL")
            doneButton.isEnabled = false
        }
        return true
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
    
    private func showErrorMessage(msg: String) {
        errorLabel.text = msg
    }
    
    private func clearErrorMessage() {
        errorLabel.text = ""
    }
    
    private func isValidURL(urlString: String?) -> Bool {
        guard let urlString = urlString else {
            return false
        }
        
        let httpPrefix = "http://"
        let httpsPrefix = "https://"
        
        var prefixedString = urlString
        if !urlString.hasPrefix(httpPrefix) && !urlString.hasPrefix(httpsPrefix) {
            prefixedString = "\(httpPrefix)\(urlString)"
        }
        
        guard let url = URL(string: prefixedString) else {
            print("invalid URL: \(prefixedString)")
            return false
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            print("Cannot open URL: \(url)")
            return false
        }
        
        return true
    }
    
    private func postPin(withSubtitle subtitle: String) {
        pinDelegate.postPin(lat: coordinates.0, lng: coordinates.1, subtitle: subtitle)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    convenience init(lat: Double, lng: Double, title: String, subtitle: String) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.init(coordinate: coordinate, title: title, subtitle: subtitle)
    }
}
