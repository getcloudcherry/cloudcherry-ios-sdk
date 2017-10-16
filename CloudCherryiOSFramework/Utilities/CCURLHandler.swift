//
//  CCURLHandler.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 03/10/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//

import UIKit

class CCURLHandler: NSObject {
    
    // Properties

    var urlString = String()
    var responseData = NSMutableData()
    var urlConnection = NSURLConnection()
    
    // MARK: - Initialization Method
    
    func initWithURLString(_ iURLString: String) {
        
        self.urlString = iURLString
        
    }
    
    // MARK: - Public Methods
    
    
    func responseForFormURLEncodedString(_ iPostBody: String) -> AnyObject {
        
        let anURL = URL(string: self.urlString)!
        let aPostData = iPostBody.data(using: String.Encoding.utf8)!
        let PostLength = "\(UInt(aPostData.count))"
        
        let anURLRequest = NSMutableURLRequest(url: anURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        anURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        anURLRequest.setValue(PostLength, forHTTPHeaderField: "Content-Length")
        anURLRequest.httpMethod = "POST"
        anURLRequest.httpBody = aPostData
        
        let aResponse = self.responseForRequest(anURLRequest as URLRequest)
        
        return aResponse
        
    }
    
    
    func responseForJSONObject(_ iPostObject: AnyObject) -> AnyObject {
        
        let anURL = URL(string: self.urlString)!
        let aPostData = try! JSONSerialization.data(withJSONObject: iPostObject, options: .prettyPrinted)
        
        let anURLRequest = NSMutableURLRequest(url: anURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        anURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        anURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        anURLRequest.httpBody = aPostData
        anURLRequest.httpMethod = "POST"
        
        if (!SDKSession.accessToken.isEmpty) {
            anURLRequest.setValue(SDKSession.accessToken, forHTTPHeaderField: "Authorization")
        }
        
        let aResponse = self.responseForRequest(anURLRequest as URLRequest)
        
        return aResponse
    }
    
    
    
    func getResponse() -> AnyObject {
        
        let anURL = URL(string: self.urlString)!
        
        let anURLRequest = NSMutableURLRequest(url: anURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        anURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        anURLRequest.httpMethod = "GET"
        
        if (!SDKSession.accessToken.isEmpty) {
            anURLRequest.setValue(SDKSession.accessToken, forHTTPHeaderField: "Authorization")
        }
        
        let aResponse = self.responseForRequest(anURLRequest as URLRequest)
        
        return aResponse
        
    }
    
    
    // MARK: - Private
    
    
    func responseForRequest(_ iRequest: URLRequest) -> AnyObject {
        
        var aResponse: AnyObject? = nil
        
        print("URL:     \(String(describing: iRequest.url))")
        if (iRequest.allHTTPHeaderFields != nil && (iRequest.allHTTPHeaderFields?.count)! > 0) {
            print("HEADERS: \(String(describing: iRequest.allHTTPHeaderFields))")
        }
        if (iRequest.httpBody != nil) {
            print("POST:    \(String(describing: String(data: iRequest.httpBody!, encoding: String.Encoding.utf8)))")
        }
        
        let aRequestGroup = DispatchGroup()
        aRequestGroup.enter()
        
        let aSessionTask = URLSession.shared.dataTask(with: iRequest as URLRequest) { iData, iResponse, iError in
            if (iData != nil) {
                let aHTTPResponse = iResponse as? HTTPURLResponse
                print("RESPONSE CODE: \(aHTTPResponse?.statusCode)")
                let aResponseObject = try? JSONSerialization.jsonObject(with: iData!, options: .mutableContainers)
                if (aResponseObject != nil)  {
                    print("RESPONSE OBJECT NOT NIL")
                    if (aResponseObject is NSDictionary)  {
                        print("DICTIONARY RESPONSE")
                        aResponse = NSDictionary(dictionary: aResponseObject as! NSDictionary)
                    } else if (aResponseObject is NSArray)  {
                        print("ARRAY RESPONSE")
                        aResponse = NSArray(array: aResponseObject as! NSArray)
                    } else {
                        if (iData != nil) {
                            let aResponeString = String(data: iData!, encoding: String.Encoding.utf8)! as AnyObject
                            aResponse = NSError(domain: "Error Response: \(aResponeString)", code: 56781, userInfo: nil)
                        }
                    }
                }
            }
            
            if (aResponse == nil) {
                if (iError != nil) {
                    aResponse = iError as AnyObject?
                }
            }
            
            aRequestGroup.leave()
        }
        
        aSessionTask.resume()
        _ = aRequestGroup.wait(timeout: DispatchTime.distantFuture)
        
        if (aResponse != nil) {
            print("RESPONSE: \(aResponse!)")
            return aResponse!
        } else {
            return NSError(domain: "Error Response: Please try again later", code: 56781, userInfo: nil)
        }
        
    }
    
}
