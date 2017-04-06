//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, PostPinDelegate {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    let state = StateController.sharedInstance
    let parseClient = ParseClient.sharedInstance
    let udacityClient = UdacityClient.sharedInstance()
    let delegate = MapViewDelegate()
    
    // Locations
    let mountainView = (37.3861, -122.0839)
    let sunnyVale = (37.365848, -122.036310)
    let paloAlto = (37.440896, -122.153891)
    let subtitle = "www.atp.fm"

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = delegate
        loadPins()
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
        loadPins()
    }
    
    private func refreshPins() {
        let markers = state.getMarkers
        mapView.removeAnnotations(mapView.annotations)
        mapView.showAnnotations(markers, animated: true)
    }
    
    private func startPostPinFlow() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationController") as! AddLocationViewController
        controller.pinDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func postPin(lat: Double, lng: Double, subtitle: String) {
        if let id = udacityClient.userId {
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
                self.state.userStudent?.setLocationMarker(lat: lat, lng: lng)
                performUpdatesOnMain {
                    self.refreshPins()
                    self.centerMapOnLocation(lat: lat, lng: lng, regionDistance: 6000)
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
                self.state.userStudent?.setLocationMarker(lat: lat, lng: lng)
                performUpdatesOnMain {
                    self.refreshPins()
                    self.centerMapOnLocation(lat: lat, lng: lng, regionDistance: 6000)
                }
            case .failure(let error):
                print("Location Add Unsuccessful!\n---\(error)")
            }
        })
    }
    
    private func loadPins() {
        parseClient.getStudents { (result) in
            switch result {
            case .success(let students):
                self.state.setStudents(students: students)
                performUpdatesOnMain {
                    self.refreshPins()
                }
            case .failure(let reason):
                print("Failed.. reason: \(reason)")
            }
        }
    }
    
    func centerMapOnLocation(lat: Double, lng: Double, regionDistance: Int) {
        let location = CLLocation(latitude: lat, longitude: lng)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance(regionDistance * 2), CLLocationDistance(regionDistance * 2))
        
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
