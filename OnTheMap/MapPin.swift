//
//  MapPin.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import MapKit

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
