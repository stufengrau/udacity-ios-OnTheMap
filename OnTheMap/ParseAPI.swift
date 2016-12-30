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

class ParseAPI: NetworkAPI {
    
    private var session = URLSession.shared
    var studentInformations = [StudentInformation]()
    
    func getStudentLocations(completionHandler: @escaping (NetworkRequestResult) -> Void) {
        
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
            
            //            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
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
    

    // create a URL from parameters
    private func parseURLFromParameters(withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertData(_ data: Data?) -> AnyObject? {
        
        guard let data = data else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseAPI {
        struct Singleton {
            static var sharedInstance = ParseAPI()
        }
        return Singleton.sharedInstance
    }
    
}
