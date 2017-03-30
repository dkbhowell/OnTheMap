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
    
    var students = [UdacityStudent]()
    var dummyStudents = [("Joe", "Smith", 37.390750, -122.079061), ("Mary", "North", 37.392991, -122.080928), ("Tom", "White", 37.388125, -122.079705)]
    
    // Locations
    let mountainView = (37.3861, -122.0839)

    override func viewDidLoad() {
        super.viewDidLoad()

        centerMapOnLocation(lat: mountainView.0, lng: mountainView.1, regionDistance: 1000)
        
        // create dummy data
        for stud in dummyStudents {
            let student = UdacityStudent(firstName: stud.0, lastName: stud.1)
            student.setLocationMarker(lat: stud.2, lng: stud.3)
            students.append(student)
        }
        
        let markers = students.map {
            $0.locationMarker
        }.flatMap { $0 }
        
        mapView.addAnnotations(markers)
    }
    
    func centerMapOnLocation(lat: Double, lng: Double, regionDistance: Int) {
        let location = CLLocation(latitude: lat, longitude: lng)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, CLLocationDistance(regionDistance * 2), CLLocationDistance(regionDistance * 2))
        
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
