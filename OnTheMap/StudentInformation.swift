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
    let updatedAt: Date
    
    init?(_ studentLocation: [String:AnyObject]) {
        var firstName: String?
        var lastName: String?
        var mediaURL: String?
        var latitude: Double?
        var longitude: Double?
        var updatedAt: Date?
        
        
        // https://stackoverflow.com/questions/5185230/converting-an-iso-8601-timestamp-into-an-nsdate-how-does-one-deal-with-the-utc
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
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
            case "updatedAt":
                updatedAt = dateFormatter.date(from: value as! String)
            default:
                break
            }
        }
        if let firstName = firstName, let lastName = lastName, let mediaURL = mediaURL, let latitude = latitude, let longitude = longitude, let updatedAt = updatedAt {
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

    return result.sorted(by: {return $0.updatedAt > $1.updatedAt})
    
}

func doesURLBeginWithProtocol(url: String) -> Bool {
    return url.hasPrefix("http://") || url.hasPrefix("https://")
}

func prefixURLWithProtocol(url: String) -> String {
    return "http://".appending(url)
}
