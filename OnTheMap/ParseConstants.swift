//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation

extension ParseAPI {
    
    // MARK: URL Constants
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse"
    }
    
    // MARK: Methods
    struct Methods {
        static let StudentLocation = "/classes/StudentLocation"
        static let UpdateStudentLocation = "\(StudentLocation)/{id}"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let ID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ParseQuery = "where"
        static let Limit = "limit"
        static let Order = "order"
    }
    
    // MARK: JSON Body and Response Keys
    struct JSONKeys {
        // Body and Response Keys
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Location = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
        // Response Keys
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
    }
    
}
