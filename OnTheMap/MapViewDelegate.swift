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
        
        guard let subtitleText = (view.annotation as? UdacityStudent.StudentLocationMarker)?.subtitle else {
            print("no subtitle for annotation")
            return
        }
        
        guard let url = urlFromString(urlString: subtitleText) else {
            print("Cannon create URL from String")
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
    
    private func urlFromString(urlString: String?) -> URL? {
        guard let urlString = urlString else {
            return nil
        }
        
        let httpPrefix = "http://"
        let httpsPrefix = "https://"
        
        var prefixedString = urlString
        if !urlString.hasPrefix(httpPrefix) && !urlString.hasPrefix(httpsPrefix) {
            prefixedString = "\(httpsPrefix)\(urlString)"
        }
        
        guard let url = URL(string: prefixedString) else {
            print("invalid URL: \(prefixedString)")
            return nil
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            print("Cannot open URL: \(url)")
            return nil
        }
        
        return url
    }
    
}
