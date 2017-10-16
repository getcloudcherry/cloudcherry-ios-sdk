//
//  ThrottlingLogic.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 16/10/17.
//  Copyright © 2017 Vishal Chandran. All rights reserved.
//

import UIKit

open class ThrottlingLogic: NSObject {
    public func generateLogic(fromResponse iResponse: NSArray) -> NSDictionary {
        let aResponse = iResponse[0] as! NSMutableDictionary
        let aLogic = aResponse["logic"] as! NSMutableDictionary
        let aUniqueID = (aLogic["uniqueIDQuestionIdOrTag"] as! String).lowercased()
        aLogic["inputIds"] = (aUniqueID == "email" ? [SDKSession.uniqueEmail] : [SDKSession.uniqueMobile])
        
        var aResponseLogics = aLogic["logics"] as! [NSMutableDictionary]
        let aFirstResponseLogics = aResponseLogics[0]
        let aResponseFilter = aFirstResponseLogics["filter"] as! NSMutableDictionary
        aResponseFilter["location"] = [SDKSession.location]
        
        aFirstResponseLogics["filter"] = aResponseFilter
        aResponseLogics[0] = aFirstResponseLogics
        aLogic["logics"] = aResponseLogics
        
        return aLogic
    }
}
