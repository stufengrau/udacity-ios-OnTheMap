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
    
    // MARK: Properties
    private var session = URLSession.shared
    var userID: String?
    var firstName: String?
    var lastName: String?
    
    // MARK: HTTP Requests
    // Udacity Login Request
    func login(email: String, password: String, completionHandler loginCompletionHandler: @escaping (LoginResult) -> Void) {
        
        let request = NSMutableURLRequest(url: udacityURLFromParameters(withPathExtension: Methods.Session))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create body with Udacity Login Credentials
        let loginCredentials = getJSONString([JSONBodyKeys.Username : email, JSONBodyKeys.Password : password])
        request.httpBody = "{\"\(JSONBodyKeys.Udacity)\": \(loginCredentials)}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                loginCompletionHandler(.networkFailure)
                return
            }
            
            // if Status Code is unequal to 2xx, then something with the credentials must be wrong
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                loginCompletionHandler(.loginFailure)
                return
            }
            
            // try to get the user id
            guard let parsedResult = self.convertData(self.trimData(data)) as? [String: AnyObject],
                let account = parsedResult[JSONResponseKeys.Account] as? [String: AnyObject],
                let userID = account[JSONResponseKeys.Key] as? String else {
                    loginCompletionHandler(.networkFailure)
                    return
            }
            
            self.userID = userID
            
            // after successful login try to get the first and last name of the user
            self.getStudentName(completionHandler: loginCompletionHandler)
            
        }
        task.resume()
        
    }
    
    // Get Public User Data from Udacity to extract the first and last name of the user
    func getStudentName(completionHandler getStudentNameCompletionHandler: @escaping (LoginResult) -> Void) {
        
        guard let userID = userID else {
            assertionFailure("impossible: userID unset while trying to get student name")
            getStudentNameCompletionHandler(.loginFailure)
            return
        }
        
        // User ID is required in the url
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
            
            // try to get the first and last name of the user
            guard let parsedResult = self.convertData(self.trimData(data)) as? [String: AnyObject],
                let user = parsedResult[JSONResponseKeys.User] as? [String: AnyObject],
                let firstName = user[JSONResponseKeys.FirstName] as? String,
                let lastName = user[JSONResponseKeys.LastName] as? String else {
                    getStudentNameCompletionHandler(.networkFailure)
                    return
            }
            
            self.firstName = firstName
            self.lastName = lastName
            
            // only if we can get the first and last name of the user, the login succeds
            getStudentNameCompletionHandler(.success)
            
        }
        
        task.resume()
    }
    
    
    // Logout from Udacity
    func logout() {
        
        // when logout button is pressed, reset all values
        self.userID = nil
        self.firstName = nil
        self.lastName = nil
        ParseAPI.sharedInstance().objectID = nil
        StudentInfoModel.sharedInstance().studentInformations = [StudentInformation]()
        
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
        
        // just try to send the logout request and hope for the best
        // success of this request is not critical for the app
        let task = session.dataTask(with: request as URLRequest)
        
        // start logout request
        task.resume()
    }
    
    // MARK: Helper Methods
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
