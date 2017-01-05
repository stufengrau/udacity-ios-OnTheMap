//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation
import UIKit

class StudentInfoModel {
    
    var studentInformations = [StudentInformation]()
    
    // MARK: Shared Instance
    class func sharedInstance() -> StudentInfoModel {
        struct Singleton {
            static var sharedInstance = StudentInfoModel()
        }
        return Singleton.sharedInstance
    }
}

// Structure for Student Information
struct StudentInformation {
    let firstName: String
    let lastName: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let updatedAt: Date
    
    // initializer is failable
    init?(_ studentLocation: [String:AnyObject]) {
        var firstName: String?
        var lastName: String?
        var mediaURL: String?
        var latitude: Double?
        var longitude: Double?
        var updatedAt: Date?
        
        // format the date correctly
        // https://stackoverflow.com/questions/5185230/converting-an-iso-8601-timestamp-into-an-nsdate-how-does-one-deal-with-the-utc
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        // only get the values we are interested in
        for (key, value) in studentLocation {
            switch key {
            case ParseAPI.JSONKeys.FirstName:
                firstName = value as? String
            case ParseAPI.JSONKeys.LastName:
                lastName = value as? String
            case ParseAPI.JSONKeys.MediaURL:
                mediaURL = value as? String
            case ParseAPI.JSONKeys.Latitude:
                latitude = value as? Double
            case ParseAPI.JSONKeys.Longitude:
                longitude = value as? Double
            case ParseAPI.JSONKeys.UpdatedAt:
                updatedAt = dateFormatter.date(from: value as! String)
            default:
                break
            }
        }
        // only create an instance if all values are provided
        if let firstName = firstName, let lastName = lastName, let mediaURL = mediaURL, let latitude = latitude, let longitude = longitude, let updatedAt = updatedAt {
            // check if the url is valid and begins with a protocol
            // else prefix it with a protocol
            if (doesURLBeginWithProtocol(url: mediaURL)) {
                self.mediaURL = mediaURL
            } else {
                self.mediaURL = prefixURLWithProtocol(url: mediaURL)
            }
            self.firstName = firstName
            self.lastName = lastName
            self.latitude = latitude
            self.longitude = longitude
            self.updatedAt = updatedAt
        } else {
            return nil
        }
    }
}


// create an array of student locations from type [StudentInformation]
func createStudentLocations(_ studentLocationsResult: [String:AnyObject]) -> [StudentInformation] {
    
    // does the data contain a key "results"?
    guard let studentLocations = studentLocationsResult[ParseAPI.JSONKeys.Results] as? [[String:AnyObject]] else {
        return []
    }
    
    var result = [StudentInformation]()
    
    for studentInformation in studentLocations {
        if let studentLocation = StudentInformation(studentInformation) {
            result.append(studentLocation)
        }
    }

    // sort the array by updatedAt Date
    return result.sorted(by: {return $0.updatedAt > $1.updatedAt})
    
}

// check if a url begins with a protocol
func doesURLBeginWithProtocol(url: String) -> Bool {
    return url.hasPrefix("http://") || url.hasPrefix("https://")
}

// prefix url with a protocol
func prefixURLWithProtocol(url: String) -> String {
    return "http://".appending(url)
}
