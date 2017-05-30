//
//  StudentTableViewController.swift
//  OnTheMap
//
//  Created by Dustin Howell on 5/16/17.
//  Copyright © 2017 Dustin Howell. All rights reserved.
//

import UIKit

class StudentTableViewController: UIViewController, StateObserver, UITableViewDataSource, UITableViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    let state = StateController.shared
    var students = StateController.shared.getStudents()
    var userStudent = StateController.shared.userStudent
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

    // MARK: VC lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        students = state.getStudents()
        userStudent = state.userStudent
        state.addObserver(self)
        
        print("loaded with \(students.count) students")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStudents.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Udacity Students"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = allStudents[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableCell") ?? UITableViewCell()
        cell.textLabel?.text = student.name
        cell.detailTextLabel?.text = student.data
        if student == userStudent {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
            cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            cell.backgroundColor = UIColor(redVal: 255, greenVal: 211, blueVal: 137, alpha: 1)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 10.0)
            cell.backgroundColor = nil
        }
        return cell
    }
    
    // MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = allStudents[indexPath.row]
        guard let urlString = student.data else {
            print("No subtitle/data associated with student")
            return
        }
        openURL(fromString: urlString)
    }
    
    // MARK: Actions
    @IBAction func postPin(_ sender: Any) {
        goToMapController()
        let mapController = getMapController()
        mapController?.postPin(UIBarButtonItem())
    }
    
    @IBAction func refreshPins(_ sender: Any) {
        (self.tabBarController as? HomeTabViewController)?.refreshData()
    }
    
    @IBAction func logout(_ sender: Any) {
        (self.tabBarController as? HomeTabViewController)?.logout()
    }
    
    // MARK: StateObserver
    func studentsUpdated(students: [UdacityStudent]) {
        self.students = students
        tableView.reloadData()
    }
    
    func userStudentUpdated(userStudent: UdacityStudent) {
        self.userStudent = userStudent
        tableView.reloadData()
    }
    
    // MARK: Helper methods
    private func getMapController() -> MapViewController? {
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
    
    private func goToMapController() {
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
}
