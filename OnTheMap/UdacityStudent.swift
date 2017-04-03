//
//  UdacityStudent.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import MapKit

class UdacityStudent {
    let id: String
    let firstName: String
    let lastName: String
    var email: String?
    var data: String?
    
    var name: String {
        return firstName + " " + lastName
    }
    
    var locationMarker: StudentLocationMarker?
    
    init(id: String, firstName: String, lastName:String, data: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.data = data
    }
    
    init?(dictionary: [String:Any]) {
        // TODO
        return nil
    }
    
    func setLocationMarker(lat: Double, lng: Double) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        if let marker = locationMarker {
            marker.coordinate = location
        } else {
            let marker = StudentLocationMarker(title: name, subtitle: data, coordinate: location)
            locationMarker = marker
        }
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

// Serialization
extension UdacityStudent {
    
    func serialize() -> [String:Any] {
        // TODO
        return [:]
    }
    
}
