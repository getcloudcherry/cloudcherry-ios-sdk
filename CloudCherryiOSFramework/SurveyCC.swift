//
//  SurveyCC.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 03/10/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//

import UIKit


var _ANALYTICS_DATA = [NSDictionary]()

public protocol SurveyCCDelegate {
    func surveyExited(withStatus iStatus: SurveyExitedAt)
}

open class SurveyCC: NSObject, CCSurveyDelegate {
    
    public var surveyDelegate: SurveyCCDelegate?
    
    /**
     Initalize the CloudCherry SDK with username and password. This method has to be called mandatorily.
     
     - parameter iUsername: Username for user authentication
     
     - parameter iPassword: Password for user authentication
     */
    private func setCredentials(_ iUsername: String, iPassword: String) {
        
        if (!iUsername.isEmpty && !iPassword.isEmpty) {
            
            SDKSession.username = iUsername
            SDKSession.password = iPassword
            _IS_USING_STATIC_TOKEN = false
            
        } else {
            
            NSException(name: NSExceptionName(rawValue: "Inavlid Data"), reason: "Please provide a valid Username and Password", userInfo: nil).raise()
            
        }
        
    }
    
    
    /**
     Initalize the CloudCherry SDK with username, password and token. This method has to be called mandatorily.
     
     - parameter iUsername: Username for user authentication
     
     - parameter iPassword: Password for user authentication
     
     - parameter iToken: Token for authentication
     */
    open func initialise(_ iUsername: String, iPassword: String, iToken: String) {
        if (iUsername.isEmpty || iPassword.isEmpty) {
            NSException(name: NSExceptionName(rawValue: "Inavlid Data"), reason: "Please provide a valid Username and Password", userInfo: nil).raise()
        } else {
            SDKSession.username = iUsername
            SDKSession.password = iPassword
            _IS_USING_STATIC_TOKEN = false
            
            if (!iToken.isEmpty) {
                SDKSession.surveyToken = iToken
                _IS_USING_STATIC_TOKEN = true
            }
        }
    }
    
    
    /**
     Initalize the CloudCherry SDK with username, password and token config. This method has to be called mandatorily.
     
     - parameter iUsername: Username for user authentication
     
     - parameter iPassword: Password for user authentication
     
     - parameter iTokenConfig: Token Config for authentication
     */
    open func initialise(_ iUsername: String, iPassword: String, iTokenConfig: SurveyConfig) {
        if (!iUsername.isEmpty && !iPassword.isEmpty) {
            SDKSession.username = iUsername
            SDKSession.password = iPassword
            _IS_USING_STATIC_TOKEN = false
            
            self.setConfig(iTokenConfig.numberOfUses, iLocation: iTokenConfig.location)
            
            print("Credentials set for CloudCherry Survey")
        } else {
            NSException(name: NSExceptionName(rawValue: "Inavlid Data"), reason: "Please provide a valid Username and Password", userInfo: nil).raise()
        }
    }
    
    
    /**
     Initalize the Unique ID. This method has to be called mandatorily.
     
     - parameter iDictionary: Fields should either be "email" or "mobile". String key value for both
     */
    open func setUniqueId(_ iDictionary: NSDictionary) {
        if let anEmail = iDictionary["email"] as? String {
            SDKSession.uniqueEmail = anEmail
        }
        
        if let aMobile = iDictionary["mobile"] as? String {
            SDKSession.uniqueMobile = aMobile
        }
    }
    
    
    /**
     Initializes SDK using Static token generated from Dashboard
     
     - parameter iStaticToken: Static Token for authentication
     */
    open func setStaticToken(_ iStaticToken: String) {
        
        if (iStaticToken == "") {
            
            NSException(name: NSExceptionName(rawValue: "Inavlid Data"), reason: "Please provide a valid Static Token", userInfo: nil).raise()
            
        } else {
            
            SDKSession.surveyToken = iStaticToken
            _IS_USING_STATIC_TOKEN = true
            
        }
        
    }
    
    
    open func getAnalyticsDataAfterTestFinish() -> [NSDictionary]? {
        
        if _ANALYTICS_DATA.count > 0 {
            return _ANALYTICS_DATA
        } else {
            return nil
        }
    }
    
    
    /**
     Sets prefill details. This method is optional
     
     - parameter iPrefillDictionary: Sets custom prefill key-values
     */
    open func setPrefill(_ iPrefillDictionary: Dictionary<String, AnyObject>) {
        
        SDKSession.prefillDictionary = iPrefillDictionary
        
    }
    
    
    /**
     Sets Config Data. This method is optional
     
     - parameter iValidUses: Sets number of valis uses the token can be used
     
     - parameter iMobileNumber: Sets location string
     */
    open func setConfig(_ iValidUses: Int, iLocation: String) {
        
        if (iValidUses == 0) {
            
            SDKSession.numberOfValidUses = iValidUses
            
        }
        
        if (iLocation != "") {
            
            SDKSession.location = iLocation
            
        }
        
    }
    
    
    /**
     Sets custom assets for Smiley Rating Question. This method is optional. If not called, emojis will be used
     
     - parameter iSmileyUnselectedAssets: Array of unselected UIImage assets to be provided in 'Sad' to 'Happy' order
     
     - parameter iSmileySelectedAssets: Array of selected UIImage assets to be provided in 'Sad' to 'Happy' order
     */
    open func setCustomSmileyRatingAssets(_ iSmileyUnselectedAssets: [UIImage], iSmileySelectedAssets: [UIImage]) {
        
        SDKSession.unselectedSmileyRatingImages = iSmileyUnselectedAssets
        SDKSession.selectedSmileyRatingImages = iSmileySelectedAssets
        
    }
    
    
    /**
     Sets Config Data. This method is optional
     
     - parameter iStarUnselectedAsset: Selected UIImage asset to be provided
     
     - parameter iStarSelectedAsset: Unselected UIImage asset to be provided
     */
    open func setCustomStarRatingAssets(_ iStarUnselectedAsset: UIImage, iStarSelectedAsset: UIImage) {
        
        SDKSession.unselectedStarRatingImage = iStarUnselectedAsset
        SDKSession.selectedStarRatingImage = iStarSelectedAsset
        
    }
    
    /**
     Sets Custom Text Style. This method is optional
     
     - parameter iStyle: Custom Text Style enum
     */
    open func setCustomTextStyle(_ iStyle: CustomStyleText) {
        
        SDKSession.customTextStyle = iStyle
        
    }
    
    
    public enum CustomStyleText: String {
        
        case CC_RECTANGLE = "Rectangle" // Rectangluar buttons
        case CC_CIRCLE = "Circle" // Circular buttons
        
    }
    
    
    /**
     Presenting the CloudCherry Survey
     
     - parameter iController: The Parent Controller on which the Survey has to be presented.
     
     - parameter iToThrottle: To enable throttling in survey.
     */
    open func showSurveyInController(_ iController: UIViewController, iToThrottle: Bool) {
        
        // Get Throttling Logic and then continue with survey
        
        if iToThrottle {
            self.loginUser { (iResult) in
                if iResult {
                    self.showSurvey(iController)
                }
            }
        } else {
            self.showSurvey(iController)
        }
    }
    
    
    func showSurvey(_ iController: UIViewController) {
        if (_IS_USING_STATIC_TOKEN) {
            
            if (!SDKSession.surveyToken.isEmpty) {
                
                SDKSession.rootController = iController
                
                let aSurveyController = CCSurveyViewController()
                aSurveyController.modalPresentationStyle = .overCurrentContext
                aSurveyController.surveyDelegate = self
                let aNavigationController = UINavigationController(rootViewController: aSurveyController)
                
                iController.present(aNavigationController, animated: true, completion: nil)
                
                print("Static token method: Survey presented")
                
            } else {
                
                NSException(name: NSExceptionName(rawValue: "Inavlid Data"), reason: "Please provide valid static token", userInfo: nil).raise()
                
            }
            
        } else {
            
            if ((!SDKSession.username.isEmpty) && (!SDKSession.password.isEmpty)) {
                
                SDKSession.rootController = iController
                
                let aSurveyController = CCSurveyViewController()
                aSurveyController.surveyDelegate = self
                let aNavigationController = UINavigationController(rootViewController: aSurveyController)
                aNavigationController.view.backgroundColor = UIColor.clear
                aNavigationController.view.isOpaque = false
                aNavigationController.modalPresentationStyle = .overCurrentContext
                
                iController.present(aNavigationController, animated: true, completion: nil)
                
                print("Credential method: Survey presented")
                
            } else {
                
                NSException(name: NSExceptionName(rawValue: "Inavlid Data"), reason: "Please provide valid username and password", userInfo: nil).raise()
                
            }
            
        }
    }
    
    
    func loginUser(completion: (_ iResult: Bool) -> ()) {
        let anAPI = "\(BASE_URL)\(POST_LOGIN_TOKEN)"
        let anUsername = ENCODE_STRING(SDKSession.username)
        let aPassword = ENCODE_STRING(SDKSession.password)
        
        let aPostString = "grant_type=password&username=\(anUsername)&password=\(aPassword)"
        
        let anURLHandler = CCURLHandler()
        anURLHandler.initWithURLString(anAPI)
        
        let aResponse = anURLHandler.responseForFormURLEncodedString(aPostString)
        
        if (aResponse.isKind(of: NSDictionary.self)) {
            //            print("LOGIN RESPONSE: \(aResponse)")
            
            if let anAccessToken = aResponse["access_token"] as? String {
                SDKSession.accessToken = "Bearer \(anAccessToken)"
                self.throttle { (iResult) in
                    completion(iResult)
                }
            }
        }
    }
    
    
    func throttle(completion: (_ iResult: Bool) -> ()) {
        let anAPI = "\(BASE_URL_2)\(GET_SURVEY_THROTTLE_LOGIC)"
        
        let anURLHandler = CCURLHandler()
        anURLHandler.initWithURLString(anAPI)
        
        let aResponse = anURLHandler.getResponse()
        
        if let anArrayResponse = aResponse as? NSArray {
            self.postThrottle(forResponse: anArrayResponse) { (iResult) in
                completion(iResult)
            }
        }
    }
    
    
    func postThrottle(forResponse iResponse: NSArray, completion: (_ iResult: Bool) -> ()) {
        let aThrottle = ThrottlingLogic()
        let aLogic = aThrottle.generateLogic(fromResponse: iResponse)
        
        let anAPI = "\(BASE_URL_2)\(POST_THROTTLING)"
        
        let anURLHandler = CCURLHandler()
        anURLHandler.initWithURLString(anAPI)
        
        let aResponse = anURLHandler.responseForJSONObject(aLogic as AnyObject)
        
        if let anArrayResponse = aResponse as? NSArray {
            if (anArrayResponse.count != 0) {
                let anObject = anArrayResponse[0] as! NSDictionary
                if let aKey = anObject["key"] as? String {
                    if (aKey == SDKSession.uniqueEmail || aKey == SDKSession.uniqueMobile) {
                        if let aValue = anObject["value"] as? Bool {
                            completion(aValue)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - CCSurveyDelegate Method
    
    
    func surveyExited(withStatus iStatus: SurveyExitedAt) {
        self.surveyDelegate?.surveyExited(withStatus: iStatus)
    }

}
