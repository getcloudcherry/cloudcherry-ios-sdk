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
    
    func initWithURLString(iURLString: String) {
        
        self.urlString = iURLString
        
    }
    
    // MARK: - Public Methods
    
    
    func responseForFormURLEncodedString(iPostBody: String) -> NSDictionary {
        
        let anURL = NSURL(string: self.urlString)!
        let aPostData = iPostBody.dataUsingEncoding(NSUTF8StringEncoding)!
        let PostLength = "\(UInt(aPostData.length))"
        
        let anURLRequest = NSMutableURLRequest(URL: anURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        anURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        anURLRequest.setValue(PostLength, forHTTPHeaderField: "Content-Length")
        anURLRequest.HTTPMethod = "POST"
        anURLRequest.HTTPBody = aPostData
        
        let aResponse = self.responseForRequest(anURLRequest)
        
        return aResponse
        
    }
    
    
    func responseForJSONObject(iPostObject: AnyObject) -> NSDictionary {
        
        let anURL = NSURL(string: self.urlString)!
        let aPostData = try! NSJSONSerialization.dataWithJSONObject(iPostObject, options: .PrettyPrinted)
        
        let anURLRequest = NSMutableURLRequest(URL: anURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        anURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        anURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        anURLRequest.HTTPBody = aPostData
        anURLRequest.HTTPMethod = "POST"
        
        if (!SDKSession.accessToken.isEmpty) {
            anURLRequest.setValue(SDKSession.accessToken, forHTTPHeaderField: "Authorization")
        }
        
        let aResponse = self.responseForRequest(anURLRequest)
        
        return aResponse
    }
    
    
    
    func getResponse() -> NSDictionary {
        
        let anURL = NSURL(string: self.urlString)!
        
        let anURLRequest = NSMutableURLRequest(URL: anURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        anURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        anURLRequest.HTTPMethod = "GET"
        
        if (!SDKSession.accessToken.isEmpty) {
            anURLRequest.setValue(SDKSession.accessToken, forHTTPHeaderField: "Authorization")
        }
        
        let aResponse = self.responseForRequest(anURLRequest)
        
        return aResponse
        
    }
    
    
    // MARK: - Private
    
    
    func responseForRequest(iRequest: NSURLRequest) -> NSDictionary {
        
        var aResponse: NSDictionary? = nil
        
        print("URL:     \(iRequest.URL)")
        print("HEADERS: \(iRequest.allHTTPHeaderFields)")
        
        if (iRequest.HTTPBody != nil) {
            print("POST:    \(String(data: iRequest.HTTPBody!, encoding: NSUTF8StringEncoding))")
        }
        
        let aRequestGroup = dispatch_group_create()
        dispatch_group_enter(aRequestGroup)
        
        let aSessionTask = NSURLSession.sharedSession().dataTaskWithRequest(iRequest, completionHandler: { (iData: NSData?,  iResponse: NSURLResponse?, iError: NSError?) -> Void in
            
            if let aResponseObject = try? NSJSONSerialization.JSONObjectWithData(iData!, options: .MutableContainers) as! NSDictionary {
                
                aResponse = aResponseObject
                
                if (aResponse == nil) {
                    if (iData != nil) {
                        let aResponseString = String(data: iData!, encoding: NSUTF8StringEncoding)
                        print("1. Error Response: \(aResponseString)")
                    }
                    else if (iError != nil) {
                        let anErrorString = iError!.localizedDescription
                        print("2. Error Response: \(anErrorString)")
                    }
                }
                dispatch_group_leave(aRequestGroup)
                
            } else {
                
                NSException(name: "Error", reason: "Inavlid Token", userInfo: nil).raise()
                dispatch_group_leave(aRequestGroup)
                
            }
        })
        aSessionTask.resume()
        dispatch_group_wait(aRequestGroup, DISPATCH_TIME_FOREVER)
        
        return aResponse!
        
    }
    
}
