//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by heike on 27/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//

import Foundation

enum LoginResult {
    case success
    case networkFailure
    case loginFailure
}

class UdacityAPI: NetworkAPI {
    
    private var session = URLSession.shared
    var userID: String?
    var firstName: String?
    var lastName: String?
    
    func login(email: String, password: String, completionHandler loginCompletionHandler: @escaping (LoginResult) -> Void) {
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(withPathExtension: Methods.Session))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let loginCredentials = getJSONString([JSONBodyKeys.Username : email, JSONBodyKeys.Password : password])
        request.httpBody = "{\"\(JSONBodyKeys.Udacity)\": \(loginCredentials)}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                loginCompletionHandler(.networkFailure)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                loginCompletionHandler(.loginFailure)
                return
            }
            
            guard let parsedResult = self.convertData(self.trimData(data)) as? [String: AnyObject],
                let account = parsedResult["account"] as? [String: AnyObject],
                let userID = account["key"] as? String else {
                    debugPrint("Something went wrong with parsing json data ...")
                    loginCompletionHandler(.networkFailure)
                    return
            }
            
            debugPrint("Parsed JSON Data: \(parsedResult)")
            
            self.userID = userID
            
            self.getStudentName(completionHandler: loginCompletionHandler)
            
        }
        task.resume()
        
    }
    
    func getStudentName(completionHandler getStudentNameCompletionHandler: @escaping (LoginResult) -> Void) {
        
        guard let userID = userID else {
            assertionFailure("impossible: userID unset while trying to get student name")
            getStudentNameCompletionHandler(.loginFailure)
            return
        }
        
        let method = substituteKeyInMethod(Methods.Users, key: URLKeys.UserID, value: userID)
        let request = NSMutableURLRequest(url: udacityURLFromParameters(withPathExtension: method))
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                getStudentNameCompletionHandler(.networkFailure)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                getStudentNameCompletionHandler(.networkFailure)
                return
            }
            
            guard let parsedResult = self.convertData(self.trimData(data)) as? [String: AnyObject],
                let user = parsedResult["user"] as? [String: AnyObject],
                let firstName = user["first_name"] as? String,
                let lastName = user["last_name"] as? String else {
                    debugPrint("Something went wrong with parsing json data ...")
                    getStudentNameCompletionHandler(.networkFailure)
                    return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            
            debugPrint("Student Name \(self.firstName) \(self.lastName)")
            
            getStudentNameCompletionHandler(.success)
            
        }
        
        task.resume()
    }
    
    func logout() {
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(withPathExtension: Methods.Session))
        
        request.httpMethod = "DELETE"
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                return
            }
            
            // error handling?
        }
        
        self.userID = nil
        self.firstName = nil
        self.lastName = nil
        ParseAPI.sharedInstance().objectID = nil
        
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
    
    // skip first 5 characters from Udacity response
    private func trimData(_ data: Data?) -> Data? {
        
        guard let data = data else {
            return nil
        }
        
        let range = Range(uncheckedBounds: (5, data.count))
        return data.subdata(in: range)
        
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityAPI {
        struct Singleton {
            static var sharedInstance = UdacityAPI()
        }
        return Singleton.sharedInstance
    }
    

}
