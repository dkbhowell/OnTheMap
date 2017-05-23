//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 4/5/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    var lastLocation: MKAnnotation?
    
    var tfDelegate: UITextFieldDelegate?
    weak var pinDelegate: PostPinDelegate!
    
    //39.8282° N, 98.5795° W
    let centerOfUS = (39.8282, -98.5795)

    override func viewDidLoad() {
        super.viewDidLoad()
        tfDelegate = LocationTextFieldDelegate(textField: locationTextField, hostController: self, errorLabel: errorLabel)
        resetMapview(animated: false)
        enableNext(enabled: false)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextClicked(_ sender: UIBarButtonItem) {
        guard let lastLocation = lastLocation else {
            print("Last Location empty when it should have a value")
            return
        }
        selectLocation(location: lastLocation)
    }
    
    private func selectLocation(location: MKAnnotation) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddSubtitleController") as! AddSubtitleViewController
        let coordinates = (location.coordinate.latitude, location.coordinate.longitude)
        controller.coordinates = coordinates
        controller.pinDelegate = pinDelegate
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func resetUI() {
        locationTextField.text = nil
        self.enableNext(enabled: false)
        mapView.removeAnnotations(mapView.annotations)
        lastLocation = nil
        resetMapview()
    }
    
    // Delegate Functions
    func showErrorMessageAndReset(errorMsg: String) {
        executeOnMain {
            self.errorLabel.text = errorMsg
            self.resetMapview()
            self.enableNext(enabled: false)
        }
    }
    
    func clearErrorMessage() {
        executeOnMain {
            self.errorLabel.text = ""
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    func showAnnotation(annotation: MKAnnotation) {
        executeOnMain {
            self.mapView.addAnnotation(annotation)
            self.mapView.centerMapOnLocation(lat: annotation.coordinate.latitude, lng: annotation.coordinate.longitude, zoomLevel: 5)
            self.lastLocation = annotation
            self.mapView.selectAnnotation(annotation, animated: true)
            self.enableNext(enabled: true)
        }
    }
    
    private func resetMapview(animated: Bool = true) {
        mapView.removeAnnotations(mapView.annotations)
        let span = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.centerOfUS.0, self.centerOfUS.1) , span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    private func enableNext(enabled: Bool) {
        nextButton.isEnabled = enabled
    }
    
}

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder? = nil
    
    public class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return UIResponder._currentFirstResponder
    }
    
    internal func findFirstResponder(sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
