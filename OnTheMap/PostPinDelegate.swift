//
//  PostPinDelegate.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/6/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

protocol PostPinDelegate: class {
    func postPin(lat: Double, lng: Double, subtitle: String)
}
