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
    let delegate = MapViewDelegate()
    
    
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
                print("Success, Students!: \(students)")
                self.state.setStudents(students: students)
                let markers = self.state.getMarkers
                performUpdatesOnMain {
                    self.mapView.showAnnotations(markers, animated: true)
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
