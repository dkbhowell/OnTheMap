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
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    let state = StateController.sharedInstance
    let parseClient = ParseClient.sharedInstance
    let udacityClient = UdacityClient.sharedInstance()
    let delegate = MapViewDelegate()
    
    // variables
    private var students: [UdacityStudent] = StateController.sharedInstance.getStudents()
    private var studentPins: [MKAnnotation] = []
    private var userPin: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        state.addObserver(self)
        mapView.delegate = delegate
        let students = state.getStudents()
        let userStudent = state.userStudent
        studentPins = getMarkersFromStudents(students: students)
        userPin = userStudent?.locationMarker
        print("Refreshing Map from ViewDidLoad")
        refreshPins(newStudentPins: studentPins, newUserPin: userPin)
    }
    
    func studentsUpdated(students: [UdacityStudent]) {
        // students do not include user
        let markers = getMarkersFromStudents(students: students)
        print("Refreshing Map from studentsUpdated")
        refreshPins(newStudentPins: markers)
    }
    
    func userStudentUpdated(userStudent: UdacityStudent) {
        if let pin = userStudent.locationMarker {
            refreshPins(newUserPin: pin)
        }
    }
    
    private func getMarkersFromStudents(students: [UdacityStudent]) -> [MKAnnotation] {
        return students.map { $0.locationMarker }
            .flatMap { $0 }
    }
    
    // Actions
    @IBAction func postPin(_ sender: UIBarButtonItem) {
        if let _ = state.userStudent?.locationMarker {
            // alert that there is already a pin, ask to update it
            let alert = UIAlertController(title: "Pin Already Exists", message: "Would you like to overwrite your old pin?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                print("overwrite old pin")
                self.startPostPinFlow()
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                print("Keep old pin")
            })
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
            mapView.addAnnotation(newUserPin)
            self.userPin = newUserPin
            mapView.centerMapOnLocation(lat: newUserPin.coordinate.latitude, lng: (newUserPin.coordinate.longitude), zoomLevel: 5)
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
//        self.present(controller, animated: true, completion: nil)
//        self.navigationController?.pushViewController(controller, animated: true)
        let newNavController = UINavigationController(rootViewController: controller)
        self.present(newNavController, animated: true, completion: nil)
    }
    
    func postPin(lat: Double, lng: Double, subtitle: String) {
        if let id = StateController.sharedInstance.getUser()?.id {
            parseClient.getStudent(withUdacityID: id, completion: { (result) in
                switch result {
                case .success(let student):
                    if let student = student {
                        // if pin exists, update it
                        print("Pin Exists for Student: \(student)\n Updating Pin")
                        self.updateExistingStudentLocation(id: student.id, lat: lat, lng: lng, subtitle: subtitle)
                    } else {
                        // if pin does not exist, create a new one
                        print("Pin does not exist for student, posting a brand new pin")
                        self.postNewPin(lat: lat, lng: lng, subtitle: subtitle)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }
    
    private func updateExistingStudentLocation(id: String, lat: Double, lng: Double, subtitle: String) {
        // TODO
        parseClient.updateStudentLocation(objectId: id, lat: lat, lng: lng, data: subtitle) { (result) in
            switch result {
            case .success(let updatedAtString):
                print("Successful update at: \(updatedAtString)")
                executeOnMain {
                    self.updateUserPin(lat: lat, lng: lng, subtitle: subtitle)
//                    self.centerMapOnLocation(lat: lat, lng: lng, regionDistance: 6000)
                }
            case .failure(let error):
                print("Error updating student location: \(error)")
            }
        }
    }
    
    private func postNewPin(lat: Double, lng: Double, subtitle: String) {
        self.parseClient.postStudentLocation(lat: lat, lng: lng, data: subtitle, completion: { (result) in
            switch result {
            case .success(let objectId):
                print("Location Added Successfully!\n---Object ID: \(objectId)")
                executeOnMain {
                    self.updateUserPin(lat: lat, lng: lng, subtitle: subtitle)
//                    self.centerMapOnLocation(lat: lat, lng: lng, regionDistance: 6000)
                }
            case .failure(let error):
                print("Location Add Unsuccessful!\n---\(error)")
            }
        })
    }
    
    @IBAction func logout(_ sender: Any) {
        (self.tabBarController as? HomeTabViewController)?.logout()
    }
    
    func centerMapOnLocation(lat: Double, lng: Double, regionDistance: Int) {
        let location = CLLocation(latitude: lat, longitude: lng)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance(regionDistance * 2), CLLocationDistance(regionDistance * 2))
        
        mapView.setRegion(coordinateRegion, animated: true)
    }

}

extension MKMapView {
    func centerMapOnLocation(lat: Double, lng: Double, zoomLevel: Int = 2) {
        let location = CLLocationCoordinate2DMake(lat, lng)
        let zoomConstant: Double = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, zoomConstant * Double(zoomLevel), zoomConstant * Double(zoomLevel))
        setRegion(coordinateRegion, animated: true)
    }
}
