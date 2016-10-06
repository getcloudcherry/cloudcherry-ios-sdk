//
//  SurveyCC.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 03/10/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//

import UIKit

public class SurveyCC: NSObject {
    
    
    /**
     Initalize the CloudCherry SDK with username and password. This method has to be called mandatorily.
     
     - parameter iUsername: Username for user authentication
     
     - parameter iPassword: Password for user authentication
     */
    public func setCredentials(iUsername: String, iPassword: String) {
        
        if (!iUsername.isEmpty && !iPassword.isEmpty) {
            
            SDKSession.username = iUsername
            SDKSession.password = iPassword
            _IS_USING_STATIC_TOKEN = false
            
        } else {
            
            NSException(name: "Inavlid Data", reason: "Please provide a valid Username and Password", userInfo: nil).raise()
            
        }
        
    }
    
    
    /**
     Initializes SDK using Static token generated from Dashboard
     
     - parameter iStaticToken: Static Token for authentication
     */
    public func setStaticToken(iStaticToken: String) {
        
        if (iStaticToken == "") {
            
            NSException(name: "Inavlid Data", reason: "Please provide a valid Static Token", userInfo: nil).raise()
            
        } else {
            
            SDKSession.surveyToken = iStaticToken
            _IS_USING_STATIC_TOKEN = true
            
        }
        
    }
    
    
    /**
     Sets prefill details. This method is optional
     
     - parameter iPrefillDictionary: Sets custom prefill key-values
     */
    public func setPrefill(iPrefillDictionary: Dictionary<String, AnyObject>) {
        
        SDKSession.prefillDictionary = iPrefillDictionary
        
    }
    
    
    /**
     Sets Config Data. This method is optional
     
     - parameter iValidUses: Sets number of valis uses the token can be used
     
     - parameter iMobileNumber: Sets location string
     */
    public func setConfig(iValidUses: Int, iLocation: String) {
        
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
    public func setCustomSmileyRatingAssets(iSmileyUnselectedAssets: [UIImage], iSmileySelectedAssets: [UIImage]) {
        
        SDKSession.unselectedSmileyRatingImages = iSmileyUnselectedAssets
        SDKSession.selectedSmileyRatingImages = iSmileySelectedAssets
        
    }
    
    
    /**
     Sets Config Data. This method is optional
     
     - parameter iStarUnselectedAsset: Selected UIImage asset to be provided
     
     - parameter iStarSelectedAsset: Unselected UIImage asset to be provided
     */
    public func setCustomStarRatingAssets(iStarUnselectedAsset: UIImage, iStarSelectedAsset: UIImage) {
        
        SDKSession.unselectedStarRatingImage = iStarUnselectedAsset
        SDKSession.selectedStarRatingImage = iStarSelectedAsset
        
    }
    
    /**
     Sets Custom Text Style. This method is optional
     
     - parameter iStyle: Custom Text Style enum
     */
    public func setCustomTextStyle(iStyle: CustomStyleText) {
        
        SDKSession.customTextStyle = iStyle
        
    }
    
    
    public enum CustomStyleText: String {
        
        case CC_RECTANGLE = "Rectangle" // Rectangluar buttons
        case CC_CIRCLE = "Circle" // Circular buttons
        
    }
    
    
    /**
     Presenting the CloudCherry Survey
     
     - parameter iController: The Parent Controller on which the Survey has to be presented.
     */
    public func showSurveyInController(iController: UIViewController) {
        
        if (_IS_USING_STATIC_TOKEN) {
            
            if (!SDKSession.surveyToken.isEmpty) {
                
                SDKSession.rootController = iController
                
                let aSurveyController = CCSurveyViewController()
                aSurveyController.modalPresentationStyle = .OverCurrentContext
                let aNavigationController = UINavigationController(rootViewController: aSurveyController)
                
                iController.presentViewController(aNavigationController, animated: true, completion: nil)
                
            } else {
                
                NSException(name: "Inavlid Data", reason: "Please provide valid static token", userInfo: nil).raise()
                
            }
            
        } else {
            
            if ((!SDKSession.username.isEmpty) && (!SDKSession.password.isEmpty)) {
                
                SDKSession.rootController = iController
                
                let aSurveyController = CCSurveyViewController()
                let aNavigationController = UINavigationController(rootViewController: aSurveyController)
                aNavigationController.view.backgroundColor = UIColor.clearColor()
                aNavigationController.view.opaque = false
                aNavigationController.modalPresentationStyle = .OverCurrentContext
                
                iController.presentViewController(aNavigationController, animated: true, completion: nil)
                
            } else {
                
                NSException(name: "Inavlid Data", reason: "Please provide valid username and password", userInfo: nil).raise()
                
            }
            
        }
        
    }

}
