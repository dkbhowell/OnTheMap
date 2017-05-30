//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, PostPinDelegate, StateObserver {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    let state = StateController.shared
    let parseClient = ParseClient.shared
    let udacityClient = UdacityClient.shared
    let delegate = MapViewDelegate()
    
    private var students: [UdacityStudent] = StateController.shared.getStudents()
    private var studentPins: [MKAnnotation] = []
    private var userPin: MKAnnotation?

    // MARK: VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        state.addObserver(self)
        mapView.delegate = delegate
        let students = state.getStudents()
        let userStudent = state.userStudent
        studentPins = getMarkersFromStudents(students: students)
        userPin = userStudent?.locationMarker
        refreshPins(newStudentPins: studentPins, newUserPin: userPin)
    }
    
    // MARK: StateObserver
    func studentsUpdated(students: [UdacityStudent]) {
        let markers = getMarkersFromStudents(students: students)
        refreshPins(newStudentPins: markers)
    }
    
    func userStudentUpdated(userStudent: UdacityStudent) {
        if let pin = userStudent.locationMarker {
            refreshPins(newUserPin: pin)
        }
    }
    
    // MARK: Actions
    @IBAction func postPin(_ sender: UIBarButtonItem) {
        if let _ = state.userStudent?.locationMarker {
            // alert that there is already a pin, ask to update it
            let alert = UIAlertController(title: "Pin Already Exists", message: "Would you like to overwrite your old pin?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.startPostPinFlow()
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(noAction)
            alert.preferredAction = yesAction
            self.present(alert, animated: true, completion: nil)
        } else {
            startPostPinFlow()
        }
    }
    
    @IBAction func reloadPins(_ sender: UIBarButtonItem) {
        (self.tabBarController as? HomeTabViewController)?.refreshData()
    }
    
    @IBAction func logout(_ sender: Any) {
        (self.tabBarController as? HomeTabViewController)?.logout()
    }
    
    // MARK: Helper functions
    private func getMarkersFromStudents(students: [UdacityStudent]) -> [MKAnnotation] {
        return students.map { $0.locationMarker }
            .flatMap { $0 }
    }
    
    // removes existing markers, adds markers for other students, adds user marker and focus if exists
    private func refreshPins(newStudentPins: [MKAnnotation]? = nil, newUserPin: MKAnnotation? = nil) {
        if let newStudentPins = newStudentPins {
            mapView.removeAnnotations(studentPins)
            mapView.addAnnotations(newStudentPins)
            studentPins = newStudentPins
        }
        
        if let newUserPin = newUserPin {
            if let userPin = self.userPin {
                mapView.removeAnnotation(userPin)
            }
            self.userPin = newUserPin
            mapView.addAnnotation(newUserPin)
            mapView.centerMapOnLocation(lat: newUserPin.coordinate.latitude, lng: (newUserPin.coordinate.longitude), zoomLevel: 5)
            mapView.selectAnnotation(newUserPin, animated: true)
        }
    }
    
    private func updateUserPin(lat: Double, lng: Double, subtitle: String? = nil) {
        guard let user = state.userStudent else {
            print("No User to Update Pin For")
            return
        }
        if let oldUserPin = user.locationMarker {
            mapView.removeAnnotation(oldUserPin)
        }
        user.setLocationMarker(lat: lat, lng: lng, subtitle: subtitle)
        guard let userPin = user.locationMarker else {
            print("Error: No user pin despite just setting it")
            return
        }
        mapView.addAnnotation(userPin)
        mapView.centerMapOnLocation(lat: userPin.coordinate.latitude, lng: userPin.coordinate.longitude, zoomLevel: 5)
        mapView.selectAnnotation(userPin, animated: true)
    }
    
    private func startPostPinFlow() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationController") as! AddLocationViewController
        controller.pinDelegate = self
        let newNavController = UINavigationController(rootViewController: controller)
        self.present(newNavController, animated: true, completion: nil)
    }
    
    func postPin(lat: Double, lng: Double, subtitle: String) {
        if let id = StateController.shared.getUser()?.id {
            parseClient.getStudent(withUdacityID: id, completion: { (result) in
                switch result {
                case .success(let student):
                    if let student = student {
                        // if pin exists, update it
                        self.updateExistingStudentLocation(id: student.id, lat: lat, lng: lng, subtitle: subtitle)
                    } else {
                        // if pin does not exist, create a new one
                        self.postNewPin(lat: lat, lng: lng, subtitle: subtitle)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }
    
    private func updateExistingStudentLocation(id: String, lat: Double, lng: Double, subtitle: String) {
        parseClient.updateStudentLocation(objectId: id, lat: lat, lng: lng, data: subtitle) { (result) in
            switch result {
            case .success( _):
                executeOnMain {
                    self.updateUserPin(lat: lat, lng: lng, subtitle: subtitle)
                }
            case .failure(let error):
                print("Error updating student location: \(error)")
            }
        }
    }
    
    private func postNewPin(lat: Double, lng: Double, subtitle: String) {
        self.parseClient.postStudentLocation(lat: lat, lng: lng, data: subtitle, completion: { (result) in
            switch result {
            case .success( _):
                executeOnMain {
                    self.updateUserPin(lat: lat, lng: lng, subtitle: subtitle)
                }
            case .failure(let error):
                print("Location Add Unsuccessful!\n---\(error)")
            }
        })
    }
}
