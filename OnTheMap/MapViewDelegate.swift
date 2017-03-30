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
        
        guard let website = (view.annotation as? UdacityStudent.StudentLocationMarker)?.subtitle else {
            print("no subtitle for annotation")
            return
        }
        
        guard let url = URL(string: website) else {
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation selected!!!")
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        print("annotations added!")
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        print("loading map")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let defaultView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "student_pin")
        defaultView.canShowCallout = true
        defaultView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return defaultView
    }
    
}
