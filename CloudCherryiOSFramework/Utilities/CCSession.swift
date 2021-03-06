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
    
    /**
     Email ID for Unique ID
     */
    var uniqueEmail = String()
    
    /**
     Mobile Number for Unique ID
     */
    var uniqueMobile = String()
    
    
    // MARK: - Public Methods
    
    /**
     Shows the Loading View
     
     - parameter iView: The view on top of which the loading view appears
     
     - parameter iMessage: The message to be displayed while the loading page is displayed
     */
    
    func showLoadingOn(_ iView: UIView, withMessage iMessage: String) {
        
        self.loadingView.initWithFrame(iView.bounds, message: iMessage)
        iView.addSubview(self.loadingView)
        self.loadingView.startLoading()
        
    }
    
    
    func removeLoading() {
        
        self.loadingView.removeFromSuperview()
        
    }

}


// MARK: - Question Class


class CCQuestion {
    
    var questionId = String()
    var name = String()
    var leadingDisplayText = [AnyObject]()
    var sequence = Int()
    var displayType = String()
    var ratingTexts = [String]()
    var singleSelectOption = [String]()
    var multiSelectOption = [String]()
}


// MARK: - Class to store responses of the answered questions

class CCQuestionResponse {
    
    var questionID = String()
    var questionType = String()
    var numberResponse = Int()
    var textResponse = [String]()
    var isAnswered = false
}


// MARK: - Analytics Class

class CCAnalytics {
    
    var id = String()
    var name = String()
    var impression = Int()
    var duration = Int()
    var lastViewedAt = Int()
    
    init(id:String, name:String,impression:Int,lastViewedAt:Int) {
        
        self.id = id
        self.name = name
        self.impression = impression
        self.lastViewedAt = lastViewedAt
        self.duration = 0
    }
}
