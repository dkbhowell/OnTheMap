//
//  StateController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/30/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import Foundation
import MapKit

class StateController: StateSubject {
    // Singleton
    static let shared = StateController()
    private init() { }
    
    // Properties
    private var students: [StudentInformation] = []
    private var observers: [StateObserver] = []
    private var user: User?
    var userStudent: StudentInformation? {
        didSet {
            if let student = userStudent {
                if students.contains(student) {
                    students = students.filter({ (member) -> Bool in
                        member != student
                    })
                }
                notifyObservers(newUserStudent: student)
            }
        }
    }
    
    func getStudents(includeUser: Bool = false) -> [StudentInformation] {
        if includeUser, let userStudent = userStudent  {
            var allStudents = students
            allStudents.insert(userStudent, at: 0)
            return allStudents
        }
        return students
    }
    
    func addStudent(student: StudentInformation) {
        students.append(student)
    }
    
    func removeStudent(student: StudentInformation) {
        let i = students.index { (stud) -> Bool in
            stud.firstName == student.firstName &&
            stud.lastName == student.lastName
        }
        
        if let i = i {
            students.remove(at: i)
        }
    }
    
    func setStudents(students: [StudentInformation]) {
        if let userStudent = userStudent {
            let onlyOthers = students.filter({ (student) -> Bool in
                student != userStudent
            })
            self.students = onlyOthers
        } else {
            self.students = students
        }
        notifyObservers(newStudents: self.students)
    }
    
    func setUserLocationMarker(lat: Double, lng: Double, subtitle: String? = nil) {
        userStudent?.setLocationMarker(lat: lat, lng: lng, subtitle: subtitle)
        if let userStudent = userStudent {
            notifyObservers(newUserStudent: userStudent)
        }
    }
    
    func setUser(user: User) {
        print("Setting User")
        self.user = user
    }
    
    func getUser() -> User? {
        return self.user
    }
    
    func addObserver(_ observer: StateObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: StateObserver) {
        let index = observers.index { (obs) -> Bool in
            return obs === observer
        }
        if let trueIndex = index {
            observers.remove(at: trueIndex)
        }
    }
    
    func notifyObservers(newStudents: [StudentInformation]) {
        for observer in observers {
            executeOnMain {
                observer.studentsUpdated(students: newStudents)
            }
        }
    }
    
    func notifyObservers(newUserStudent: StudentInformation) {
        for observer in observers {
            executeOnMain {
                observer.userStudentUpdated(userStudent: newUserStudent)
            }
        }
    }
    
    func resetState() {
        students = []
        user = nil
        userStudent = nil
    }
    
    private func generateDummyData() {
        let dummyStudentData = [("Joe", "Smith", 37.390750, -122.079061), ("Mary", "North", 37.392991, -122.080928), ("Tom", "White", 37.388125, -122.079705)]
        for stud in dummyStudentData {
            var student = StudentInformation(id: "Dummy", firstName: stud.0, lastName: stud.1)
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

protocol StateObserver: class {
    func studentsUpdated(students: [StudentInformation])
    func userStudentUpdated(userStudent: StudentInformation)
}

protocol StateSubject: class {
    func addObserver(_ observer: StateObserver)
    func removeObserver(_ observer: StateObserver)
    func notifyObservers(newStudents: [StudentInformation])
    func notifyObservers(newUserStudent: StudentInformation)
}
