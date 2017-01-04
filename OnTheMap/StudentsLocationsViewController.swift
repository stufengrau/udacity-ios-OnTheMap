//
//  StudentsLocationsViewController.swift
//  OnTheMap
//
//  Created by heike on 01/01/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

// Custom View Controller Class to provide some shared functions
// for the StudentsMap and StudentsTable View Controller
// to avoid code duplication
class StudentsLocationsViewController: UIViewController {
    
    // get students information from server
    func getStudentsInformation() {
        enableUI(false)
        ParseAPI.sharedInstance().getStudentsLocations { (networkRequestResult) in
            self.enableUI(true)
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Download of Student Informations failed. Please try again later.")
            case .success:
                self.refreshData()
            }
        }
    }
    
    // check if the user has already posted a location
    // if true, ask if the existing location should be overwriten
    // else modally present the view to enter a new location and url
    func checkStudentLocation() {
        enableUI(false)
        ParseAPI.sharedInstance().getStudentLocation { (networkRequestResult) in
            self.enableUI(true)
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Could not check location status. Please try again later.")
            case .locationDoesExist:
                self.overrideLocationAlert("You have already posted a location. Do you want to overwrite your current location?")
            case .locationDoesNotExist:
                self.presentPostingInformationView()
            }
        }
    }
    
    // show the Overwrite Alert Message
    // if Overwrite is selected, modally present the view to enter a new location and url
    func overrideLocationAlert(_ message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: {_ in
                self.presentPostingInformationView()
            })
            let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
            alertController.addAction(overwriteAction)
            alertController.addAction(dismissAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // modally present the view to enter a new location and url
    func presentPostingInformationView() {
        DispatchQueue.main.async {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "postInformationView")
            let postController = controller.childViewControllers[0] as! PostInformationViewController
            postController.instanceOfStudentsLocationsVC = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // just trigger the logout request and dismiss view immediately
    // if the logout network request fails, nothing bad happens
    // Alternative: if the logout network request fails, show an alert
    // and do not dismiss the view ...
    func logoutAndDismiss() {
        UdacityAPI.sharedInstance().logout()
        self.dismiss(animated: true, completion: nil)
    }
    
    func enableUI(_ enabled: Bool) {
        fatalError("This method must be overriden.")
    }
    
    func refreshData() {
        fatalError("This method must be overriden.")
    }

}
