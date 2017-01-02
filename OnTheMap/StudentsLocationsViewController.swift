//
//  StudentsLocationsViewController.swift
//  OnTheMap
//
//  Created by heike on 01/01/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import UIKit

class StudentsLocationsViewController: UIViewController {
    
    func getStudentsInformation() {
        debugPrint("getStudentInformations called.")
        enableUI(false)
        ParseAPI.sharedInstance().getStudentsLocations { (networkRequestResult) in
            self.enableUI(true)
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Download of Student Informations failed. Please try again later.")
            case .success:
                debugPrint(ParseAPI.sharedInstance().studentInformations.count)
                self.refreshData()
            }
        }
    }
    
    func checkStudentLocation() {
        enableUI(false)
        ParseAPI.sharedInstance().getStudentLocation { (networkRequestResult) in
            self.enableUI(true)
            switch(networkRequestResult) {
            case .networkFailure:
                self.showAlert("Could not check location status. Please try again later.")
            case .locationExists:
                debugPrint("User already posted a location")
                self.overrideLocationAlert("You already have posted a location. Do you want to override it?")
            case .noLocationExists:
                self.presentPostingInformationView()
            }
        }
    }
    
    func overrideLocationAlert(_ message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
                self.presentPostingInformationView()
            })
            let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            alertController.addAction(dismissAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentPostingInformationView() {
        DispatchQueue.main.async {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "postInformationView")
            self.present(controller, animated: true, completion: nil)
        }
    }
    

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
