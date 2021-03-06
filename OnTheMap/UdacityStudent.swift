//
//  UdacityStudent.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import MapKit

struct StudentInformation: Equatable {
    let id: String
    let firstName: String
    let lastName: String
    var email: String?
    var data: String? {
        didSet {
            if let locationMarker = locationMarker {
                locationMarker.subtitle = data
            }
        }
    }
    var uniqueKey: String?
    
    private var createdAtString: String?
    
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
        guard let firstName = dictionary[Keys.FIRST_NAME] as? String else {
            return nil
        }
        
        guard let lastName = dictionary[Keys.LAST_NAME] as? String else {
            return nil
        }
        
        guard let objectId = dictionary[Keys.OBJECT_ID] as? String else {
            return nil
        }
        
        let createdAtString = dictionary[Keys.CREATED_AT] as? String
        let uniqueKey = dictionary[Keys.UNIQUE_KEY] as? String
        let mediaUrl = dictionary[Keys.MEDIA_URL] as? String
        let lat = dictionary[Keys.LAT] as? Double
        let lng = dictionary[Keys.LNG] as? Double
        
        self.init(id: objectId, firstName: firstName, lastName: lastName, data: mediaUrl)
        self.uniqueKey = uniqueKey
        self.createdAtString = createdAtString
        if let lat = lat, let lng = lng {
            self.setLocationMarker(lat: lat, lng: lng)
        }
    }
    
    mutating func setLocationMarker(lat: Double, lng: Double, subtitle: String? = nil) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        if let marker = locationMarker {
            marker.coordinate = location
        } else {
            let marker = StudentLocationMarker(title: name, subtitle: data, coordinate: location)
            locationMarker = marker
        }
        if let subtitle = subtitle {
            data = subtitle
        }
    }
    
    static func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
        return lhs.id == rhs.id
    }
}

extension StudentInformation {
    
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
extension StudentInformation {
    
    struct Keys {
        static let FIRST_NAME = "firstName"
        static let LAST_NAME = "lastName"
        static let LAT = "latitude"
        static let LNG = "longitude"
        static let MAP_STRING = "mapString"
        static let MEDIA_URL = "mediaURL"
        static let OBJECT_ID = "objectId"
        static let UNIQUE_KEY = "uniqueKey"
        static let UPDATED_AT = "updatedAt"
        static let CREATED_AT = "createdAt"
    }
    
    func serialize() -> [String:Any] {
        // TODO
        var dict: [String:Any] = [:]
        dict[Keys.FIRST_NAME] = firstName
        dict[Keys.LAST_NAME] = lastName
        dict[Keys.LAT] = locationMarker?.coordinate.latitude
        dict[Keys.LNG] = locationMarker?.coordinate.longitude
        dict[Keys.OBJECT_ID] = id
        dict[Keys.MEDIA_URL] = data
        return dict
    }
    
    static func studentDict(fromUser user: User, lat: Double, lng: Double, data: String?) -> [String:Any] {
        var dict = [String:Any]()
        dict[StudentInformation.Keys.FIRST_NAME] = user.firstName
        dict[StudentInformation.Keys.LAST_NAME] = user.lastName
        dict[StudentInformation.Keys.UNIQUE_KEY] = user.id
        dict[StudentInformation.Keys.MEDIA_URL] = data
        dict[StudentInformation.Keys.LAT] = lat
        dict[StudentInformation.Keys.LNG] = lng
        return dict
    }
    
}
