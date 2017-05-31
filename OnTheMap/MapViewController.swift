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
    
    private func startPostPinFlow() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationController") as! AddLocationViewController
        controller.pinDelegate = self
        let newNavController = UINavigationController(rootViewController: controller)
        self.present(newNavController, animated: true, completion: nil)
    }
    
    func postPin(lat: Double, lng: Double, subtitle: String) {
        guard let userId = StateController.shared.getUser()?.id else {
            print("No user id to use to post/update location")
            return
        }
        parseClient.postPin(studentId: userId, lat: lat, lng: lng, subtitle: subtitle) { (result) in
            switch result {
            case .success( _):
                print("Successfully posted/updated user lcoation")
            case .failure( _):
                print("failed to update user pin")
                showAlertController(hostController: self, title: "Error Posting Location", msg: "Please check your connection and try again")
            }
        }
    }
}
