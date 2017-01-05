//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation

enum NetworkRequestResult {
    case success
    case networkFailure
}

enum CheckStudentLocationResult {
    case networkFailure
    case locationDoesExist
    case locationDoesNotExist
}

class ParseAPI: NetworkAPI {
    
    // MARK: Properties
    private var session = URLSession.shared
    var studentInformations = [StudentInformation]()
    var objectID: String?
    
    // computed property to check, if user has already posted a location
    var studentHasPostedLocation: Bool {return (objectID != nil)}
    
    
    // MARK: HTTP Requests
    // Get last 100 Students Locations from Parse API
    func getStudentsLocations(completionHandler: @escaping (NetworkRequestResult) -> Void) {
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(withPathExtension: Methods.StudentLocation))
        
        addApiAndApplicationKeys(to: request)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(.networkFailure)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(.networkFailure)
                return
            }
            
            guard let parsedResult = self.convertData(data) as? [String: AnyObject] else {
                completionHandler(.networkFailure)
                return
            }
            
            // create the [StudentInformation] array
            self.studentInformations = createStudentLocations(parsedResult)
            completionHandler(.success)
            
        }
        task.resume()
    }
    
    // Get a student location
    func getStudentLocation(completionHandler: @escaping (CheckStudentLocationResult) -> Void) {
        
        guard let userID = UdacityAPI.sharedInstance().userID else {
            assertionFailure("Impossible: userID unset while trying to get student location")
            completionHandler(.networkFailure)
            return
        }
        
        // send query with the user id
        let queryValue = getJSONString([JSONKeys.UniqueKey : userID])
        let urlParameter = [ParameterKeys.ParseQuery : queryValue]
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(withPathExtension: Methods.StudentLocation, parameters: urlParameter))
        
        addApiAndApplicationKeys(to: request)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(.networkFailure)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(.networkFailure)
                return
            }
            
            guard let parsedResult = self.convertData(data) as? [String: AnyObject] else {
                completionHandler(.networkFailure)
                return
            }
            
            guard let result = parsedResult[JSONKeys.Results] as? [[String:AnyObject]],
                result.count > 0, let objectID = result[0][JSONKeys.ObjectID] as? String else {
                    // user has not posted a location yet
                    completionHandler(.locationDoesNotExist)
                    return
            }
            
            // if user has already posted a location, save the objectID to be able to perform
            // updated to this location
            self.objectID = objectID
            completionHandler(.locationDoesExist)
            
        }
        task.resume()
        
    }
    
    // POST or PUT (Update) a student location
    func updateStudentLocation(_ location: String, _ mediaURL: String, _ latitude: Double, _ longitude: Double, completionHandler: @escaping (NetworkRequestResult) -> Void) {
        
        guard let userID = UdacityAPI.sharedInstance().userID,
            let firstName = UdacityAPI.sharedInstance().firstName,
            let lastName = UdacityAPI.sharedInstance().lastName else {
            assertionFailure("Impossible: userID, firstName and lastName unset while trying to post student location")
            completionHandler(.networkFailure)
            return
        }
        
        let request: NSMutableURLRequest
        
        
        // first check if user has already posted a location
        // if true, update location with PUT request
        // else POST new location
        if studentHasPostedLocation {
            let method = substituteKeyInMethod(Methods.UpdateStudentLocation, key: URLKeys.ID, value: objectID!)
            request = NSMutableURLRequest(url: parseURLFromParameters(withPathExtension: method))
            request.httpMethod = "PUT"
        } else {
            request = NSMutableURLRequest(url: parseURLFromParameters(withPathExtension: Methods.StudentLocation))
            request.httpMethod = "POST"
        }
        
        addApiAndApplicationKeys(to: request)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // create the JSON String for the HTTP Body
        let jsonString = getJSONString([
            JSONKeys.UniqueKey : userID,
            JSONKeys.FirstName : firstName,
            JSONKeys.LastName : lastName,
            JSONKeys.Location : location,
            JSONKeys.MediaURL : mediaURL,
            JSONKeys.Latitude : String(latitude),
            JSONKeys.Longitude : String(longitude)
            ])
        
        request.httpBody = jsonString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                completionHandler(.networkFailure)
                return
            }
       
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(.networkFailure)
                return
            }
            
            completionHandler(.success)
        }
        
        task.resume()
        
    }
    
    // MARK: Helper Methods

    // add API Key and Application ID to the HTTP Header
    private func addApiAndApplicationKeys(to request: NSMutableURLRequest) {
        request.addValue(APIKeys.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(APIKeys.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    }

    // create a URL from parameters
    private func parseURLFromParameters(withPathExtension: String? = nil, parameters: [String:String]? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")

        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseAPI {
        struct Singleton {
            static var sharedInstance = ParseAPI()
        }
        return Singleton.sharedInstance
    }
    
}
