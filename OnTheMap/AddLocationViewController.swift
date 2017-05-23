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
    @IBOutlet weak var confirmationButtons: UIStackView!
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
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesClicked(_ sender: UIButton) {
        guard let lastLocation = lastLocation else {
            print("Last Location empty when it should have a value")
            return
        }
        
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddSubtitleController") as! AddSubtitleViewController
        let coordinates = (lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
        controller.coordinates = coordinates
        controller.pinDelegate = pinDelegate
//        present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func noClicked(_ sender: UIButton) {
        resetUI()
    }
    
    private func resetUI() {
        locationTextField.text = nil
        confirmationButtons.isHidden = true
        mapView.removeAnnotations(mapView.annotations)
        lastLocation = nil
        resetMapview()
    }
    
    // Delegate Functions
    func showErrorMessageAndReset(errorMsg: String) {
        performUpdatesOnMain {
            self.errorLabel.text = errorMsg
            self.confirmationButtons.isHidden = true
            self.resetMapview()
        }
    }
    
    func clearErrorMessage() {
        performUpdatesOnMain {
            self.errorLabel.text = ""
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
    func showAnnotation(annotation: MKAnnotation) {
        performUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
            self.mapView.centerMapOnLocation(lat: annotation.coordinate.latitude, lng: annotation.coordinate.longitude, zoomLevel: 5)
            self.lastLocation = annotation
            self.confirmationButtons.isHidden = false
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func resetMapview(animated: Bool = true) {
        mapView.removeAnnotations(mapView.annotations)
        let span = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(self.centerOfUS.0, self.centerOfUS.1) , span: span)
        mapView.setRegion(region, animated: animated)
    }
    
}

extension UIResponder {
    // Swift 1.2 finally supports static vars!. If you use 1.1 see:
    // http://stackoverflow.com/a/24924535/385979
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
