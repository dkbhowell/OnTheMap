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
    
    let httpPrefix = "http://"
    let httpsPrefix = "https://"
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Control tapped!!! 😀 :\(control)")
        
        guard let subtitleText = (view.annotation as? UdacityStudent.StudentLocationMarker)?.subtitle else {
            print("no subtitle for annotation")
            return
        }
        
        var urlString = subtitleText
        if !urlString.hasPrefix(httpPrefix) && !urlString.hasPrefix(httpsPrefix) {
            urlString = "\(httpsPrefix)\(urlString)"
        }
        
        guard let url = URL(string: urlString) else {
            print("subtitle is invalid URL")
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            print("Cannot open URL")
            return
        }
        
        print("opening url")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let defaultView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "student_pin")
        defaultView.canShowCallout = true
        defaultView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return defaultView
    }
    
}
