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
 
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorOuterView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorOuterView.isHidden = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        logoutAndDismiss()
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        getStudentsInformation()
    }
    
    @IBAction func pinLocationPressed(_ sender: UIBarButtonItem) {
        checkStudentLocation()
    }
    
    override func refreshData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func enableUI(_ enabled: Bool) {
        DispatchQueue.main.async {
            
            if enabled {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorOuterView.isHidden = true
            } else {
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorOuterView.isHidden = false
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseAPI.sharedInstance().studentInformations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentName", for: indexPath)
        let student = ParseAPI.sharedInstance().studentInformations[indexPath.row]
        
        cell.detailTextLabel?.text = student.mediaURL
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.imageView?.image = UIImage(named: "PinIcon")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediaURL = URL(string: ParseAPI.sharedInstance().studentInformations[indexPath.row].mediaURL) {
            UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
