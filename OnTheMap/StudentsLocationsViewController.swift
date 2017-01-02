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
