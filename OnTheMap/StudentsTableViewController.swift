//
//  StudentsTableViewController.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//
// http://stackoverflow.com/questions/29311093/place-activity-indicator-over-uitable-view/29311130

import UIKit

class StudentsTableViewController: StudentsLocationsViewController, UITableViewDelegate, UITableViewDataSource {
 
    // MARK: Properties
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorOuterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorOuterView.isHidden = true
    }
    
    // only refreshes data for the view, no new data is requested via http request
    // e.g. if new data was requested from the server by another view,
    // this view will show the updated data
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }
    
    // MARK: IBActions
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        logoutAndDismiss()
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        getStudentsInformation()
    }
    
    @IBAction func pinLocationPressed(_ sender: UIBarButtonItem) {
        checkStudentLocation()
    }
    
    // MARK: Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseAPI.sharedInstance().studentInformations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentName", for: indexPath)
        // get one student from the Student Information Array
        let student = ParseAPI.sharedInstance().studentInformations[indexPath.row]
        
        // display the full name of the student and the provided link
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        cell.imageView?.image = UIImage(named: "PinIcon")
        
        return cell
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the mediaURL property of a Student Information struct
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediaURL = URL(string: ParseAPI.sharedInstance().studentInformations[indexPath.row].mediaURL) {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: Helper functions
    
    // if UI should be disabled:
    // show a semitransparent view with an activity indicator
    // which overlays the main view
    override func enableUI(_ enabled: Bool) {
        DispatchQueue.main.async {
            if enabled {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorOuterView.isHidden = true
            } else {
                self.activityIndicatorOuterView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }
        }
    }
    
    // reloadData for Table View
    override func refreshData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
