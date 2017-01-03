//
//  NetworkAPI.swift
//  OnTheMap
//
//  Created by heike on 29/12/2016.
//  Copyright © 2016 stufengrau. All rights reserved.
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
    
    func getJSONString(_ jsonDict: [String:String]) -> String {
        
        let escapedQuoteSign = "\""
        let keyValueDelimeter = ":"
        let objectDelimiter = ","
        let beginJSON = "{"
        let endJSON = "}"
        
        var jsonString = beginJSON
        
        for (key, value) in jsonDict {
            jsonString.append("\(escapedQuoteSign)\(key)\(escapedQuoteSign)\(keyValueDelimeter)\(escapedQuoteSign)\(value)\(escapedQuoteSign)\(objectDelimiter)")
        }
        
        // remove last comma
        jsonString.remove(at: jsonString.index(before: jsonString.endIndex))
        jsonString.append(endJSON)
        
        return jsonString
    }

    
}
