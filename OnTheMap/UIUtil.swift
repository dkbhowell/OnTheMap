//
//  UIUtil.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

func executeOnMain(withDelayInSeconds delay: Double? = nil, _ updates: @escaping () -> Void) {
    if let delay = delay {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: updates)
    } else {
        DispatchQueue.main.async {
            updates()
        }
    }
}
