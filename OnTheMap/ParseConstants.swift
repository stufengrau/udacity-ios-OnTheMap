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
        static let ObjectID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ParseQuery = "where"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Location = "mapString"
        static let MediaURL = "mediaURL"
        static let Lat = "latitude"
        static let Lon = "longitude"
    }
    
}
