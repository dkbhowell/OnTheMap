//
//  NetworkUtil.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/26/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//
import UIKit

class NetworkUtil {
    
    private static let validUrlSchemes = ["http://", "https://"]
    
    static func validUrl(fromString urlString: String, addPrefixIfNecessary: Bool = false) -> URL? {
        var stringToCheck = urlString
        
        if addPrefixIfNecessary {
            
            var hasValidPrefix = false
            for prefix in validUrlSchemes {
                if urlString.hasPrefix(prefix) {
                    hasValidPrefix = true
                    break
                }
            }
            
            if !hasValidPrefix {
                stringToCheck = "\(validUrlSchemes[0])\(stringToCheck)"
            }
        }
        
        if let url = URL(string: stringToCheck), UIApplication.shared.canOpenURL(url) {
            return url
        }
        
        return nil
    }
    
    static func openUrl(url: URL?) {
        guard let url = url else {
            print("Could not open URL: URL is nil")
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
            print("Could not open URL: Invalid URL")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
