//
//  User.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/3/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation
import MapKit

class User {
    
    var firstName: String
    var lastName: String
    var id: String
    
    var data: String? {
        didSet {
            if let locationMarker = locationMarker {
                locationMarker.subtitle = data
            }
        }
    }
    var nickname: String?
    var email: String?
    var locationMarker: UdacityStudent.StudentLocationMarker?
    
    var name: String {
        return "\(firstName) \(lastName)"
    }
    
    init(firstName: String, lastName: String, userId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.id = userId
    }
    
    convenience init?(dictionary: [String:Any]) {
        guard let userInfo = dictionary[Keys.USER_INFO] as? [String:Any] else {
            print("Error - key '\(Keys.USER_INFO)' not found in Dict: \(dictionary)")
            return nil
        }
        
        guard let firstName = userInfo[Keys.FIRST_NAME] as? String else {
            print("Error - key '\(Keys.FIRST_NAME)' not found in Dict: \(userInfo)")
            return nil
        }
        
        guard let lastName = userInfo[Keys.LAST_NAME] as? String else {
            print("Error - key '\(Keys.LAST_NAME)' not found in Dict: \(userInfo)")
            return nil
        }
        
        guard let id = userInfo[Keys.USER_ID] as? String else {
            print("Error - key '\(Keys.USER_ID)' not found in Dict: \(userInfo)")
            return nil
        }
        
        let emailObj = userInfo[Keys.EMAIL] as? [String:Any]
        
        self.init(firstName: firstName, lastName: lastName, userId: id)
        self.email = emailObj?[Keys.EMAIL_ADDRESS] as? String
        self.nickname = userInfo[Keys.NICKNAME] as? String
        
        print("User Info Success:")
        print("---Nickname: \(self.nickname ?? "None")")
        print("---Last Name: \(self.lastName)")
        print("---Email: \(self.email ?? "None")")
    }
    
    func setLocationMarker(lat: Double, lng: Double) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        if let marker = locationMarker {
            marker.coordinate = location
        } else {
            let marker = UdacityStudent.StudentLocationMarker(title: name, subtitle: data, coordinate: location)
            self.locationMarker = marker
        }
    }
    
}

extension User {
    struct Keys {
        static let ACCOUNT = "account"
        static let SESSION = "session"
        static let USER_ID = "key"
        static let SESSION_ID = "id"
        static let REGISTERED = "registered"
        static let USER_INFO = "user"
        static let NICKNAME = "nickname"
        static let LAST_NAME = "last_name"
        static let FIRST_NAME = "first_name"
        static let EMAIL = "email"
        static let EMAIL_ADDRESS = "address"
    }
    
    func toStudentDict() -> [String:Any] {
        var dict = [String:Any]()
        dict[UdacityStudent.Keys.FIRST_NAME] = self.firstName
        dict[UdacityStudent.Keys.LAST_NAME] = self.lastName
        dict[UdacityStudent.Keys.UNIQUE_KEY] = self.id
        dict[UdacityStudent.Keys.MEDIA_URL] = self.data
        dict[UdacityStudent.Keys.LAT] = self.locationMarker?.coordinate.latitude
        dict[UdacityStudent.Keys.LNG] = self.locationMarker?.coordinate.longitude
        return dict
    }
}
