//
//  DataResult.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/31/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

enum DataResult<T> {
    case success(T)
    case failure(String)
}
