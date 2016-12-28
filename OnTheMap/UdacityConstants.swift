//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by heike on 28/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation

extension UdacityAPI {
 
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"

    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Session
        static let Session = "/session"
        static let Users = "/users/{id}"
        
    }
    
}
