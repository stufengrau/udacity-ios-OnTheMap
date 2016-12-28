//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by heike on 27/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation

// TODO: String weg
enum LoginResult {
    case success(String)
    case networkFailure
    case loginFailure
}



class UdacityAPI {
    
    private var userID: String?
    
    var session = URLSession.shared
    
    func login(email: String, password: String, completionHandler: @escaping (LoginResult) -> Void) {
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(withPathExtension: Methods.Session))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\" : {\"username\": \"\(email)\", \"password\":\"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                completionHandler(.networkFailure)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(.loginFailure)
                return
            }
            
            guard let parsedResult = self.convertData(data) as? [String: AnyObject],
                let account = parsedResult["account"] as? [String: AnyObject],
                let userID = account["key"] as? String else {
                    debugPrint("Something went wrong with parsing json data ...")
                    completionHandler(.networkFailure)
                    return
            }
            
            debugPrint("Parsed JSON Data: \(parsedResult)")
            
            // TODO: userid speichern in variable
            completionHandler(.success(userID))
            
        }
        task.resume()
        
    }
    
    
    // create a URL from parameters
    private func udacityURLFromParameters(withPathExtension: String? = nil) -> URL {
        
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
        
        let range = Range(uncheckedBounds: (5, data.count))
        let newData = data.subdata(in: range)
        
        return try? JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
        
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityAPI {
        struct Singleton {
            static var sharedInstance = UdacityAPI()
        }
        return Singleton.sharedInstance
    }
    

}
