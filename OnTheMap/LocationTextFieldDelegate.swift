//
//  LocationTextFieldDelegate.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class LocationTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    weak var hostController: AddLocationViewController!
    weak var errorLabel: UILabel!
    
    init(textField: UITextField, hostController: AddLocationViewController, errorLabel: UILabel) {
        self.hostController = hostController
        self.errorLabel = errorLabel
        super.init()
        textField.delegate = self
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldBeginEditing")
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("Done with location: \(textField.text ?? "none")")
        if let location = textField.text {
            
            CLGeocoder().geocodeAddressString(location, completionHandler: { (placemark, err) in
                if let err = err {
                    print("Geocode Error: \(err)")
                    self.showErrorMessage(msg: "Error Finding Location -- Please enter another city")
                    return
                }
                
                guard let placesFound = placemark, placesFound.count > 0 else {
                    print("Error, No Placemark in Geocode result")
                    self.showErrorMessage(msg: "Error Finding Location -- Please enter another city")
                    return
                }
                
                let firstResult = placesFound[0]
                let latOpt = firstResult.location?.coordinate.latitude
                let lngOpt = firstResult.location?.coordinate.longitude
                
                guard let lat = latOpt, let lng = lngOpt else {
                    print("Error getting lat / lng coordinates from geocode result")
                    self.showErrorMessage(msg: "Error Finding Location -- Please enter another city")
                    return
                }
                let coordinates = (lat, lng)
                
                print("Successful Geocode: \(location) is at Coordiates (\(lat),\(lng))")
                guard let hostController = self.hostController else {
                    print("No host view controller to continue UI flow")
                    self.showErrorMessage(msg: "Error Finding Location -- Please enter another city")
                    return
                }
                
                // show location on mapview
                let location = UdacityStudent.StudentLocationMarker(title: "New Location", subtitle: nil, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                hostController.showAnnotation(annotation: location)
                
                
                
            })
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func showErrorMessage(msg: String) {
        performUpdatesOnMain {
            self.errorLabel.text = msg
        }
    }
    
    
}
