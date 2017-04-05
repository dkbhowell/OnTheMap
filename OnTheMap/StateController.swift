//
//  StateController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/30/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation
import MapKit

class StateController {
    // Singleton
    static let sharedInstance = StateController()
    private init() { if AppDelegate.DEBUG { generateDummyData() } }
    
    // Properties
    private var students: [UdacityStudent] = []
    private var user: User?
    var userStudent: UdacityStudent?
    
    
    var getMarkers: [MKAnnotation] {
        if let userStudent = userStudent {
            var allStudents = self.students
            allStudents.append(userStudent)
            return allStudents.map { $0.locationMarker }
                .flatMap { $0 }
        }
        return self.students.map { $0.locationMarker }
            .flatMap { $0 }
    }
    
    func addStudent(student: UdacityStudent) {
        students.append(student)
    }
    
    func removeStudent(student: UdacityStudent) {
        let i = students.index { (stud) -> Bool in
            stud.firstName == student.firstName &&
            stud.lastName == student.lastName
        }
        
        if let i = i {
            students.remove(at: i)
        }
    }
    
    func setStudents(students: [UdacityStudent]) {
        if let userStudent = userStudent {
            let onlyOthers = students.filter({ (student) -> Bool in
                student != userStudent
            })
            self.students = onlyOthers
        } else {
            self.students = students
        }
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func getUser() -> User? {
        return self.user
    }
    
//    func resetState() {
//        nickname = nil
//        firstName = nil
//        lastName = nil
//        email = nil
//    }
    
    private func generateDummyData() {
        let dummyStudentData = [("Joe", "Smith", 37.390750, -122.079061), ("Mary", "North", 37.392991, -122.080928), ("Tom", "White", 37.388125, -122.079705)]
        for stud in dummyStudentData {
            let student = UdacityStudent(id: "Dummy", firstName: stud.0, lastName: stud.1)
            if student.firstName == "Mary" {
                student.data = "http://www.google.com"
            }
            if student.firstName == "Joe" {
                student.data = "GoergeWentToFlyAkite"
            }
            student.setLocationMarker(lat: stud.2, lng: stud.3)
            addStudent(student: student)
        }
    }
    
    
}
