//
//  StudentTableViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/16/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class StudentTableViewController: UIViewController, StateObserver, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var students = StateController.sharedInstance.getStudents()

    override func viewDidLoad() {
        super.viewDidLoad()
        students = StateController.sharedInstance.getStudents()
        StateController.sharedInstance.addObserver(self)
        
        print("loaded with \(students.count) students")
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Udacity Students"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableCell")
        
        guard let newCell = cell  else {
            print("Warning: Unable to Dequeue cell")
            return UITableViewCell()
        }
        
        newCell.textLabel?.text = student.name
        newCell.detailTextLabel?.text = student.data
    
        return newCell
    }
    
    func studentsUpdated(students: [UdacityStudent]) {
        self.students = students
        tableView.reloadData()
        print("State Changed from Table View Controller!")
    }
    
    func userStudentUpdated(userStudent: UdacityStudent) {
        //TODO
        print("New User Student in Table View")
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
