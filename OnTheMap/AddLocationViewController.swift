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

    override func viewDidLoad() {
        super.viewDidLoad()
        tfDelegate = LocationTextFieldDelegate(textField: locationTextField, hostController: self, errorLabel: errorLabel)
        centerMapOnLocation(location: initialLocation)
        print("FIRST RESPONDER")
        let firstResponder = UIResponder.currentFirstResponder()
        print(firstResponder)
        print("RESPONDER CHAIN")
        printResponderChain(responder: firstResponder)
    }
    
    func printResponderChain(responder: UIResponder?) {
        guard let responder = responder else {
            return
        }
        print(responder)
        printResponderChain(responder: responder.next)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func noClicked(_ sender: UIButton) {
        resetUI()
    }
    
    private func resetUI() {
        locationTextField.text = nil
        confirmationButtons.isHidden = true
        mapView.removeAnnotations(mapView.annotations)
        lastLocation = nil
    }
    
    
    // Delegate Functions
    func showErrorMessageAndReset(errorMsg: String) {
        performUpdatesOnMain {
            self.errorLabel.text = errorMsg
        }
    }
    
    func showAnnotation(annotation: MKAnnotation) {
        performUpdatesOnMain {
            self.mapView.showAnnotations([annotation], animated: true)
            self.lastLocation = annotation
            self.confirmationButtons.isHidden = false
        }
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
