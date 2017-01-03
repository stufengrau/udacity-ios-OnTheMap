//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by heike on 28/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation

extension UdacityAPI {
 
    // MARK: URL Constants
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        
        static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
    }
    
    // MARK: Methods
    struct Methods {
        static let Session = "/session"
        static let Users = "/users/{id}"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
}
