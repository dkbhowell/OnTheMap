//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/30/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

extension ParseClient {
    
    struct UrlComponents {
        static let SCHEME = "https"
        static let HOST = "www.parse.udacity.com"
        static let PATH = "/parse/classes/"
    }
    
    struct Methods {
        
    }
    
    struct RequestParamaterNames {
        static let LIMIT = "limit"
        static let SKIP = "skip"
        static let ORDER = "order"
    }
    
    struct ResponseKeys {
        static let RESULTS = "results"
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
    
    
}
