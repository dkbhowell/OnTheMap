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
    
    func getMapController() -> MapViewController? {
        let navController = self.tabBarController?.viewControllers?[1] as? UINavigationController
        return navController?.viewControllers[0] as? MapViewController
    }
    
    func goToMapController() {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func postPin(_ sender: Any) {
        goToMapController()
        let mapController = getMapController()
        mapController?.postPin(UIBarButtonItem())
    }
    
    @IBAction func refreshPins(_ sender: Any) {
        
    }
    @IBAction func logout(_ sender: Any) {
        
    }
    
    
}
