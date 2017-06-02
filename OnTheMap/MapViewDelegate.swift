//
//  MapViewDelegate.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/30/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation
import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Control tapped!!! 😀 :\(control)")
        
        guard let subtitleText = (view.annotation as? StudentInformation.StudentLocationMarker)?.subtitle else {
            print("no subtitle for annotation")
            return
        }
        
        let url = NetworkUtil.validUrl(fromString: subtitleText, addPrefixIfNecessary: true)
        NetworkUtil.openUrl(url: url)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let defaultView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "student_pin")
        defaultView.canShowCallout = true
        defaultView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return defaultView
    }
    
}
