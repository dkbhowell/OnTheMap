//
//  UdacityStudent.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import MapKit

class UdacityStudent {
    let firstName: String
    let lastName: String
    var email: String?
    
    var name: String {
        return firstName + " " + lastName
    }
    
    var locationMarker: StudentLocationMarker?
    
    init(firstName: String, lastName:String, email: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    func setLocationMarker(lat: Double, lng: Double, title: String? = nil, subtitle: String? = nil) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let marker = StudentLocationMarker(title: title, subtitle: subtitle, coordinate: location)
        locationMarker = marker
    }
}

extension UdacityStudent {
    
    class StudentLocationMarker: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        
        init(title: String? = nil, subtitle: String? = nil, coordinate: CLLocationCoordinate2D) {
            self.title = title
            self.subtitle = subtitle
            self.coordinate = coordinate
        }
    }
}
