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



// MARK: - APIs

var POST_LOGIN_TOKEN = "LoginToken"
var POST_CREATE_SURVEY_TOKEN = "SurveyToken"
var GET_QUESTIONS_API = "SurveyByToken/\(SDKSession.surveyToken)/\(SDKSession.deviceID)"
var POST_ANSWER_PARTIAL = "PartialSurvey/\(SDKSession.surveyToken)/\(_PARTIAL_SURVEY_COMPLETE)/InApp-iOS/\(SDKSession.deviceID)"
var POST_ANSWER_ALL = "SurveyByToken/\(SDKSession.surveyToken)"

var _IS_USING_STATIC_TOKEN = Bool()


// MARK: - Macros

func SHOW_LOADING(kView: UIView, kMessage: String) {
    
    SDKSession.showLoadingOn(kView, withMessage: kMessage)
    
}


func REMOVE_LOADING() {
    
    SDKSession.removeLoading()
    
}


func GET_RGB_COLOR(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    
    return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    
}


func FONT(kName: String, kSize: CGFloat) -> UIFont {
    
    return UIFont(name: kName, size: kSize)!
    
}


func HELVETICA_BOLD(kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Bold", kSize: kSize)
    
}


func HELVETICA_NEUE(kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue", kSize: kSize)
    
}


func HELVETICA_LIGHT(kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Light", kSize: kSize)
    
}


func HELVETICA_ITALIC(kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Italic", kSize: kSize)
    
}


func HELVETICA_MEDIUM(kSize: CGFloat) -> UIFont {
    
    return FONT("HelveticaNeue-Medium", kSize: kSize)
    
}


func IMAGE(kName: String) -> UIImage {
    
    return UIImage(named: kName)!
    
}


func ENCODE_STRING(kString: String) -> String {
    
    let aCustomAllowedSet =  NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}").invertedSet
    let anEscapedString = kString.stringByAddingPercentEncodingWithAllowedCharacters(aCustomAllowedSet)
    
    return anEscapedString!
    
}