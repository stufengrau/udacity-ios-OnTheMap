//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation
import UIKit

struct StudentInformation {
    let firstName: String
    let lastName: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    init?(_ studentLocation: [String:AnyObject]) {
        var firstName: String?
        var lastName: String?
        var mediaURL: String?
        var latitude: Double?
        var longitude: Double?
        for (key, value) in studentLocation {
            switch key {
            case "firstName":
                firstName = value as? String
            case "lastName":
                lastName = value as? String
            case "mediaURL":
                mediaURL = value as? String
            case "latitude":
                latitude = value as? Double
            case "longitude":
                longitude = value as? Double
            default:
                break
            }
        }
        if let firstName = firstName, let lastName = lastName, let mediaURL = mediaURL, let latitude = latitude, let longitude = longitude {
            self.firstName = firstName
            self.lastName = lastName
            self.mediaURL = mediaURL
            self.latitude = latitude
            self.longitude = longitude
        } else {
            return nil
        }
    }
}

func createStudentLocations(_ studentLocationsResult: [String:AnyObject]) -> [StudentInformation] {
    
    guard let studentLocations = studentLocationsResult["results"] as? [[String:AnyObject]] else {
        debugPrint("Key 'results' not found in \(studentLocationsResult).")
        return []
    }
    
    var result = [StudentInformation]()
    
    debugPrint("Number of JSON Datasets: \(studentLocations.count).")
    
    for studentInformation in studentLocations {
        if let studentLocation = StudentInformation(studentInformation) {
            result.append(studentLocation)
        }
    }
    
    return result
}
