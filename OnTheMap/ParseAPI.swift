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
    case locationExists
    case noLocationExists
}

class ParseAPI: NetworkAPI {
    
    private var session = URLSession.shared
    var studentInformations = [StudentInformation]()
    var objectID: String?
    
    var studentHasPostedLocation: Bool {return (objectID != nil)}
    
    func getStudentsLocations(completionHandler: @escaping (NetworkRequestResult) -> Void) {
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(withPathExtension: Methods.StudentLocation))
        
        request.addValue(HiddenKeys.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(HiddenKeys.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                debugPrint("error is not nil")
                completionHandler(.networkFailure)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(.networkFailure)
                return
            }
            
            guard let parsedResult = self.convertData(data) as? [String: AnyObject] else {
                debugPrint("Error parsing JSON Data")
                completionHandler(.networkFailure)
                return
            }
            
            self.studentInformations = createStudentLocations(parsedResult)
            completionHandler(.success)
            
        }
        task.resume()
    }
    
    func getStudentLocation(completionHandler: @escaping (CheckStudentLocationResult) -> Void) {
        
        guard let userID = UdacityAPI.sharedInstance().userID else {
            assertionFailure("Impossible: userID unset while trying to get student location")
            completionHandler(.networkFailure)
            return
        }
        
        let queryValue = getJSONString([JSONBodyKeys.UniqueKey : userID])
        let urlParameter = [ParameterKeys.ParseQuery : queryValue]
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(withPathExtension: Methods.StudentLocation, parameters: urlParameter))
        
        request.addValue(HiddenKeys.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(HiddenKeys.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                debugPrint("error is not nil")
                completionHandler(.networkFailure)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(.networkFailure)
                return completionHandler(.networkFailure)
            }

            guard let parsedResult = self.convertData(data) as? [String: AnyObject] else {
                    debugPrint("Something went wrong with parsing json data ...")
                    completionHandler(.networkFailure)
                    return
            }
            
            if let result = parsedResult["results"] as? [String: AnyObject],
                let objectID = result["objectID"] as? String {
                self.objectID = objectID
                completionHandler(.locationExists)
            }
            
            completionHandler(.noLocationExists)
            
        }
        task.resume()
        
    }
    

    // create a URL from parameters
    private func parseURLFromParameters(withPathExtension: String? = nil, parameters: [String:String] = [:]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: value)
            components.queryItems!.append(queryItem)
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
