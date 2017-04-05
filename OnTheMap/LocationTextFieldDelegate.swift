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
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("Done with location: \(textField.text)")
        if let location = textField.text {
            
            CLGeocoder().geocodeAddressString(location, completionHandler: { (placemark, err) in
                if let err = err {
                    print("Geocode Error: \(err)")
                    return
                }
                
                guard let placesFound = placemark, placesFound.count > 0 else {
                    print("Error, No Placemark in Geocode result")
                    return
                }
                
                let firstResult = placesFound[0]
                let latOpt = firstResult.location?.coordinate.latitude
                let lngOpt = firstResult.location?.coordinate.longitude
                
                guard let lat = latOpt, let lng = lngOpt else {
                    print("Error getting lat / lng coordinates from geocode result")
                    return
                }
                
                print("Successful Geocode: \(location) is at Coordiates (\(lat),\(lng))")
                
            })
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
