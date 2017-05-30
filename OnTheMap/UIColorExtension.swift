//
//  UIColorExtension.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//
import UIKit

extension UIColor {
    convenience init(redVal: Int, greenVal: Int, blueVal: Int, alpha: Float) {
        let redDecimal = Float(Float(redVal) / 255)
        let greenDecimal = Float(Float(greenVal) / 255)
        let blueDecimal = Float(Float(blueVal) / 255)
        self.init(colorLiteralRed: redDecimal, green: greenDecimal, blue: blueDecimal, alpha: alpha)
    }
}
