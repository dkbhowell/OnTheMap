//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/17/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

extension UdacityClient {
    struct UrlComponents {
        static let SCHEME = "https"
        static let HOST = "www.udacity.com"
        static let PATH = "/api/"
    }
    
    struct Methods {
        static let SESSION = "session"
        static let USER = "users"
    }
    
    struct RequestParamNames {
        static let UDACITY = "udacity"
        static let USERNAME = "username"
        static let PASSWORD = "password"
        static let FB_MOBILE = "facebook_mobile"
        static let ACCESS_TOKEN = "access_token"
    }
    
    struct ResponseKeys {
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
}
