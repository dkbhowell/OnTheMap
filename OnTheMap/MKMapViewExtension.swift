//
//  MKMapViewExtension.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/29/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import MapKit

extension MKMapView {
    func centerMapOnLocation(lat: Double, lng: Double, zoomLevel: Int = 2) {
        let location = CLLocationCoordinate2DMake(lat, lng)
        let zoomConstant: Double = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, zoomConstant * Double(zoomLevel), zoomConstant * Double(zoomLevel))
        setRegion(coordinateRegion, animated: true)
    }
}
