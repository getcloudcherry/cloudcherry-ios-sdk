//
//  CCSession.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 03/10/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//

import UIKit

class CCSession: NSObject {
    
    
    // MARK: - Outlets
    
    
    var loadingView = CCLoadingView()
    
    
    // MARK: - Properties
    
    
    /**
     Username to authenticate user
     */
    var username = String()
    
    /**
     Password to authenticate user
     */
    var password = String()
    
    /**
     Prefill Dictionary
     */
    var prefillDictionary: Dictionary<String, AnyObject>?
    
    /**
     Number of valid uses of survey token
     */
    var numberOfValidUses = -1
    
    /**
     Number of valid uses of survey token
     */
    var location = ""
    
    /**
     Parent View Controller for the SDK
     */
    var rootController = UIViewController()
    
    /**
     Access Token used to authorize Web Services
     */
    var accessToken = String()
    
    /**
     Survey Token used to fetch and update surveys
     */
    var surveyToken = String()
    
    /**
     Device ID used to uniquely identify a device
     */
    var deviceID = String()
    
    /**
     Images for unselected Smiley Rating
     */
    var unselectedSmileyRatingImages: [UIImage]?
    
    /**
     Images for selected Smiley Rating
     */
    var selectedSmileyRatingImages: [UIImage]?
    
    /**
     Image for unselected Star Rating
     */
    var unselectedStarRatingImage: UIImage?
    
    /**
     Image for selected Star Rating
     */
    var selectedStarRatingImage: UIImage?
    
    /**
     Custom Text Style for Single/Multi Select Buttons
    */
    var customTextStyle = SurveyCC.CustomStyleText.CC_CIRCLE
    
    
    // MARK: - Public Methods
    
    /**
     Shows the Loading View
     
     - parameter iView: The view on top of which the loading view appears
     
     - parameter iMessage: The message to be displayed while the loading page is displayed
     */
    
    func showLoadingOn(iView: UIView, withMessage iMessage: String) {
        
        self.loadingView.initWithFrame(iView.bounds, message: iMessage)
        iView.addSubview(self.loadingView)
        self.loadingView.startLoading()
        
    }
    
    
    func removeLoading() {
        
        self.loadingView.removeFromSuperview()
        
    }

}
