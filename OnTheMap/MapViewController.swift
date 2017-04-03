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
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                print("overwrite old pin")
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                print("Keep old pin")
            }))
        } else {
            // Post a new pin
            let alert = UIAlertController(title: "Post an alert?", message: "Would you like to post an alert?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                print("Add new pin")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Locations
    let mountainView = (37.3861, -122.0839)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = delegate
        
        let markers = state.getMarkers
        mapView.showAnnotations(markers, animated: true)
        
        parseClient.getStudents { (result) in
            switch result {
            case .success(let students):
                print("Success! Fetched Students")
                self.state.setStudents(students: students)
                let markers = self.state.getMarkers
                performUpdatesOnMain {
                    self.mapView.showAnnotations(markers, animated: true)
                }
            case .failure(let reason):
                print("Failed.. reason: \(reason)")
            }
        }
        
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
    
    func centerMapOnLocation(lat: Double, lng: Double, regionDistance: Int) {
        let location = CLLocation(latitude: lat, longitude: lng)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance(regionDistance * 2), CLLocationDistance(regionDistance * 2))
        
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
