//
//  CCConstants.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 23/09/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//

import Foundation



// MARK: - Singleton

let SDKSession = CCSession()



// MARK: - URLs

var BASE_URL = "https://api.getcloudcherry.com/api/"
var BASE_URL_2 = "https://dispatcher.getcloudcherry.com/api/"


// MARK: - APIs

var POST_LOGIN_TOKEN = "LoginToken"
var POST_CREATE_SURVEY_TOKEN = "SurveyToken"
var GET_QUESTIONS_API = "SurveyByToken/\(SDKSession.surveyToken)/\(SDKSession.deviceID)"
var POST_ANSWER_PARTIAL = "PartialSurvey/\(SDKSession.surveyToken)/\(_PARTIAL_SURVEY_COMPLETE)/InApp-iOS/\(SDKSession.deviceID)"
var POST_ANSWER_ALL = "SurveyByToken/\(SDKSession.surveyToken)"

var GET_SURVEY_THROTTLE_LOGIC = "SurveyThrottleLogic/\(SDKSession.location)"
var POST_THROTTLING = "Throttling"
var POST_THROTTLING_ADD_ENTIRES = "Throttling/AddEntries"

var _IS_USING_STATIC_TOKEN = Bool()


// MARK: - Macros

func SHOW_LOADING(_ kView: UIView, kMessage: String) {
    
    SDKSession.showLoadingOn(kView, withMessage: kMessage)
    
}


func REMOVE_LOADING() {
    
    SDKSession.removeLoading()
    
}


func GET_RGB_COLOR(_ r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    
}


func FONT(_ kName: String, kSize: CGFloat) -> UIFont {
    
    return UIFont(name: kName, size: kSize)!
    
}


func HELVETICA_BOLD(_ kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Bold", kSize: kSize)
    
}


func HELVETICA_NEUE(_ kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue", kSize: kSize)
    
}


func HELVETICA_LIGHT(_ kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Light", kSize: kSize)
    
}


func HELVETICA_ITALIC(_ kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Italic", kSize: kSize)
    
}


func HELVETICA_MEDIUM(_ kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Medium", kSize: kSize)
    
}


func IMAGE(_ kName: String) -> UIImage {
    
    return UIImage(named: kName)!
    
}


func ENCODE_STRING(_ kString: String) -> String {
    
    let aCustomAllowedSet =  CharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}").inverted
    let anEscapedString = kString.addingPercentEncoding(withAllowedCharacters: aCustomAllowedSet)
    
    return anEscapedString!
    
}
