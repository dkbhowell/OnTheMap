//
//  UIUtil.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation

func performUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

func performUpdatesOnMain(delayedSeconds: Double, _ updates: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delayedSeconds, execute: updates)
}
