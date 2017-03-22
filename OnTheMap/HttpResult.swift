//
//  HttpResult.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/17/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

enum HttpResult<T, E: Error> {
    case success(T)
    case failure(E)
}
