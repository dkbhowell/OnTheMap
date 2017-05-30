//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    // MARK: Constants
    let centerOfUS = (39.8282, -98.5795)
    
    // MARK: Outlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    // MARK: Properties
    let regionRadius: CLLocationDistance = 1000
    var lastLocation: MapPin?
    weak var pinDelegate: PostPinDelegate!

    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        resetMapview(animated: false)
        enableFind(enabled: false)
        findOnMapButton.layer.cornerRadius = 10
        findOnMapButton.clipsToBounds = true
    }
    
    // MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findOnMapClicked(_ sender: UIButton) {
        guard let locationString = locationTextField.text else {
            showErrorMessageAndReset(errorMsg: "Please enter a location in the text field")
            return
        }
        geocode(locationString: locationString)
    }
    
    // MARK: Core functions
    private func geocode(locationString string: String) {
        enableFind(enabled: false)
        CLGeocoder().geocodeAddressString(string, completionHandler: { (placemark, err) in
            self.enableFind(enabled: true)
            if let err = err {
                print("Geocode Error: \(err)")
                self.showErrorMessageAndReset(errorMsg: "Error Finding Location -- Please enter another city")
                return
            }
            
            guard let placesFound = placemark, placesFound.count > 0 else {
                print("Error, No Placemark in Geocode result")
                self.showErrorMessageAndReset(errorMsg: "Error Finding Location -- Please enter another city")
                return
            }
            
            let firstResult = placesFound[0]
            let latOpt = firstResult.location?.coordinate.latitude
            let lngOpt = firstResult.location?.coordinate.longitude
            
            guard let lat = latOpt, let lng = lngOpt else {
                print("Error getting lat / lng coordinates from geocode result")
                self.showErrorMessageAndReset(errorMsg: "Error Finding Location -- Please enter another city")
                return
            }
            
            print("Successful Geocode: \(string) is at Coordiates (\(lat),\(lng))")
            
            // show location on mapview
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let name = StateController.shared.getUser()?.name
            let mapPin = MapPin(coordinate: coordinate , title: name ?? "New Location", subtitle: "")
            self.continueToSubtitle(pin: mapPin)
        })
    }
    
    private func continueToSubtitle(pin: MapPin) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddSubtitleController") as! AddSubtitleViewController
        controller.mapPin = pin
        controller.pinDelegate = pinDelegate
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: UI Helper functions
    private func resetUI() {
        executeOnMain {
            self.locationTextField.text = nil
            self.enableFind(enabled: false)
            self.resetMapview(animated: false)
            self.lastLocation = nil
        }
    }
    
    func showErrorMessageAndReset(errorMsg: String) {
        executeOnMain {
            self.resetUI()
            let alertController = UIAlertController(title: "Geocode Error", message: "We had trouble finding that location, please try again", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAnnotation(pin: MapPin) {
        executeOnMain {
            self.mapView.addAnnotation(pin)
            self.mapView.centerMapOnLocation(lat: pin.coordinate.latitude, lng: pin.coordinate.longitude, zoomLevel: 5)
            self.lastLocation = pin
            self.mapView.selectAnnotation(pin, animated: true)
        }
    }
    
    private func resetMapview(animated: Bool = true) {
        executeOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
            let span = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.centerOfUS.0, self.centerOfUS.1) , span: span)
            self.mapView.setRegion(region, animated: animated)
        }
    }
    
    private func enableFind(enabled: Bool) {
        executeOnMain {
            self.findOnMapButton.isEnabled = enabled
        }
    }
    
    // MARK: TextFieldDelegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            enableFind(enabled: false)
            print("No text in textfield")
            return true
        }
        let newText = NSString(string: text).replacingCharacters(in: range, with: string)
        if newText != "" {
            enableFind(enabled: true)
        } else {
            enableFind(enabled: false)
        }
        return true
    }
}
