//
//  KeyboardAdaptable.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/16/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//
import UIKit

protocol KeyboardAdaptable {
    func keyboardWillShow(notification: NSNotification)
    func keyboardWillHide(notification: NSNotification)
    func addKeyboardNotificationObservers()
}

extension KeyboardAdaptable where Self: UIViewController, Self: NSObject {
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
//            print("Checking if y is zero: y value:: \(self.view.frame.origin.y)")
//            if self.view.frame.origin.y == 0{
//                print("Y is zero, raising by \(keyboardSize.height) (keyboard height)")
//                self.view.frame.origin.y -= keyboardSize.height
//            }
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
//            }
        }
    }
}
