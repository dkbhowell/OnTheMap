//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 3/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    let state = StateController.sharedInstance
    let parseClient = ParseClient.sharedInstance
    let udacityClient = UdacityClient.sharedInstance()
    let delegate = MapViewDelegate()
    
    // Actions
    @IBAction func postPin(_ sender: UIBarButtonItem) {
        if let userPin = state.getUser()?.locationMarker {
            // alert that there is already a pin, ask to update it
            let alert = UIAlertController(title: "Pin Already Exists", message: "Would you like to overwrite your old pin?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                print("overwrite old pin")
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                print("Keep old pin")
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            alert.preferredAction = yesAction
            self.present(alert, animated: true, completion: nil)
        } else {
            // Post a new pin
            let alert = UIAlertController(title: "Post a location?", message: "Would you like to post a location?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                print("Add new pin")
                self.parseClient.postStudentLocation(lat: self.mountainView.0, lng: self.mountainView.1, completion: { (result) in
                    switch result {
                    case .success(let objectId):
                        print("Location Added Successfully!\n---Object ID: \(objectId)")
                    case .failure(let error):
                        print("Location Add Unsuccessful!\n---\(error)")
                    }
                })
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reloadPins(_ sender: UIBarButtonItem) {
        loadPins()
    }
    
    
    // Locations
    let mountainView = (37.3861, -122.0839)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = delegate
        
        loadPins()
        
        // check online for user pin
        if let id = udacityClient.userId {
            parseClient.getStudent(withUdacityID: id, completion: { (result) in
                switch result {
                case .success(let student):
                    if let student = student, let pin = student.locationMarker {
                        print("Pin Exists for Student: \(student)")
                        self.state.getUser()?.locationMarker = pin
                    } else {
                        print("No pin exists for student")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            })
        }
    }
    
    private func loadPins() {
        parseClient.getStudents { (result) in
            switch result {
            case .success(let students):
                print("Success! Fetched Students")
                self.state.setStudents(students: students)
                let markers = self.state.getMarkers
                performUpdatesOnMain {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.showAnnotations(markers, animated: true)
                    print("Added annotations")
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
