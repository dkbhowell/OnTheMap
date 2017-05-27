//
//  StudentTableViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/16/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class StudentTableViewController: UIViewController, StateObserver, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var students = StateController.sharedInstance.getStudents()
    var userStudent = StateController.sharedInstance.userStudent
    var allStudents: [UdacityStudent] {
        get {
            if let userStudent = userStudent {
                var allStudents = students
                allStudents.insert(userStudent, at: 0)
                return allStudents
            } else {
                return students
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        students = StateController.sharedInstance.getStudents()
        userStudent = StateController.sharedInstance.userStudent
        StateController.sharedInstance.addObserver(self)
        
        print("loaded with \(students.count) students")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStudents.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Udacity Students"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = allStudents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableCell")
        
        guard let newCell = cell  else {
            print("Warning: Unable to Dequeue cell")
            return UITableViewCell()
        }
        
        newCell.textLabel?.text = student.name
        newCell.detailTextLabel?.text = student.data
        
        if student == userStudent {
//            let currentFont = newCell.textLabel?.font!
            newCell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
            newCell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            newCell.backgroundColor = UIColor(redVal: 255, greenVal: 211, blueVal: 137, alpha: 1)
        } else {
            newCell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            newCell.detailTextLabel?.font = UIFont.systemFont(ofSize: 10.0)
            newCell.backgroundColor = nil
        }
    
        return newCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = allStudents[indexPath.row]
        guard let urlString = student.data else {
            print("No subtitle/data associated with student")
            return
        }
        openURL(fromString: urlString)
    }
    
    func studentsUpdated(students: [UdacityStudent]) {
        self.students = students
        tableView.reloadData()
        print("State Changed from Table View Controller!")
    }
    
    func userStudentUpdated(userStudent: UdacityStudent) {
        //TODO
        print("New User Student in Table View")
        self.userStudent = userStudent
        tableView.reloadData()
    }
    
    func getMapController() -> MapViewController? {
        guard let controllers = self.tabBarController?.viewControllers else {
            print("Problem accessing view controlers in tab bar controller")
            return nil
        }
        for controller in controllers {
            // check for direct controller as mapview
            if controller is MapViewController {
                return controller as? MapViewController
            }
            // check for mapcontroller as root view controller in navigation controller
            if let navController = controller as? UINavigationController,
                let mapController = navController.viewControllers.first as? MapViewController
            {
                return mapController
            }
        }
        return nil
    }
    
    private func getMapNavController(fromNavControllers controllers: [UINavigationController]) -> UINavigationController? {
        for controller in controllers {
            // check for mapcontroller as root view controller in navigation controller
            if controller.viewControllers.first is MapViewController
            {
                return controller
            }
        }
        return nil
    }
    
    private func openURL(fromString string: String) {
        let url = NetworkUtil.validUrl(fromString: string, addPrefixIfNecessary: true)
        NetworkUtil.openUrl(url: url)
    }
    
    func goToMapController() {
        guard let controllers = self.tabBarController?.viewControllers?.filter({ (vc) -> Bool in
            vc is UINavigationController
        }).map({ (vc) -> UINavigationController in
            vc as! UINavigationController
        }) else {
            print("Problem acessing view controllers in tab bar controller")
            return
        }
        guard let mapNavController = getMapNavController(fromNavControllers: controllers) else {
            print("No map nav controller found in controllers")
            return
        }
        guard let index = controllers.index(of: mapNavController) else {
            print("Map Nav controller now found in controller list")
            return
        }
        self.tabBarController?.selectedIndex = index
    }
    
    @IBAction func postPin(_ sender: Any) {
        goToMapController()
        let mapController = getMapController()
        mapController?.postPin(UIBarButtonItem())
    }
    
    @IBAction func refreshPins(_ sender: Any) {
        
    }
    
    @IBAction func logout(_ sender: Any) {
        (self.tabBarController as? HomeTabViewController)?.logout()
    }
    
}

extension UIColor {
    convenience init(redVal: Int, greenVal: Int, blueVal: Int, alpha: Float) {
        let redDecimal = Float(Float(redVal) / 255)
        let greenDecimal = Float(Float(greenVal) / 255)
        let blueDecimal = Float(Float(blueVal) / 255)
        self.init(colorLiteralRed: redDecimal, green: greenDecimal, blue: blueDecimal, alpha: alpha)
    }
}
