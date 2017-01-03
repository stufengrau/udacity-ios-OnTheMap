//
//  NetworkAPI.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
//
//  Some general functions for the Udacity and Parse API
//

import Foundation

class NetworkAPI {
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    // given raw JSON, return a usable Foundation object
    func convertData(_ data: Data?) -> AnyObject? {
        
        guard let data = data else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
    }
    
    // given a dictionary from type [String:String], return a valid json string
    func getJSONString(_ jsonDict: [String:String]) -> String {
        
        let escapedQuoteSign = "\""
        let keyValueDelimeter = ":"
        let objectDelimiter = ","
        let beginJSON = "{"
        let endJSON = "}"
        
        var jsonString = beginJSON
        
        for (key, value) in jsonDict {
            // Quick Fix: "latitude" and "longitude" are needed as Double
            // so do not put the values in escaped quotation signs
            if (key == "latitude" || key == "longitude") {
                jsonString.append("\(escapedQuoteSign)\(key)\(escapedQuoteSign)\(keyValueDelimeter)\(value)\(objectDelimiter)")
            } else {
                jsonString.append("\(escapedQuoteSign)\(key)\(escapedQuoteSign)\(keyValueDelimeter)\(escapedQuoteSign)\(value)\(escapedQuoteSign)\(objectDelimiter)")
            }
        }
        
        // just to be save, remove last appended comma
        jsonString.remove(at: jsonString.index(before: jsonString.endIndex))
        
        jsonString.append(endJSON)
        
        return jsonString
    }
    
}
