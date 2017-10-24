//
//  CCSurveyViewController.swift
//  CCSampleApp
//
//  Created by Vishal Chandran on 22/09/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//
// ********************************************************* //
//                                                           //
//       Name: CCSurveyViewController                        //
//                                                           //
//    Purpose: Handles displaying the survey to the user     //
//                                                           //
// ********************************************************* //

var _PARTIAL_SURVEY_COMPLETE = false

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class headerFooterView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class questionCounterLabel : UILabel {
    
    override init(frame: CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public enum SurveyExitedAt {
    case WELCOME_SCREEN
    case PARTIAL_COMPLETION
    case COMPLETION
}

protocol CCSurveyDelegate {
    func surveyExited(withStatus iStatus: SurveyExitedAt)
}

class CCSurveyViewController: UIViewController, FloatRatingViewDelegate {
    
    
    // MARK: - Variables
    
    
    var surveyDelegate: CCSurveyDelegate?
    
    var keyboardAppeared = false
    var yOffset: CGFloat = 0
    
    var welcomeText = String()
    var thankYouText = String()
    
    var filteredQuestions = [NSDictionary]()
    var surveyQuestions = [CCQuestion]()
    
    var isSingleSelect = Bool()
    
    var questionCounter = 0
    var primaryButtonCounter = 0
    var showPreviousQuestion = false
    
    var partialResponseID = String()
    
    var logoURL = String()
    var logoImage = UIImage()
    
    var npsQuestionAnswered = false
    var starRatingQuestionAnswered = false
    var smileRatingQuestionAnswered = false
    
    var selectButtonMaxX = CGFloat(0)
    var selectButtonMaxY = CGFloat(0)
    
    var selectedNPSRating = Int()
    var selectedSmileRating = Int()
    var selectedSingleSelectOption = String()
    var selectedMultiSelectOptions = [String]()
    
    var questionsAnswered = [CCQuestionResponse]()
    var analyticsData = [CCAnalytics]()
    
    var headerColorCode = String()
    var footerColorCode = String()
    var backgroundColorCode = String()
    
    var red: [CGFloat] = [234/255, 234/255, 234/255, 234/255, 234/255, 234/255, 240/255, 239/255, 239/255, 116/255, 62/255]
    var green: [CGFloat] = [15/255, 61/255, 87/255, 113/255, 127/255, 148/255, 158/255, 219/255, 243/255, 244/255, 158/255]
    var blue: [CGFloat] = [42/255, 35/255, 37/255, 40/255, 41/255, 49/255, 43/255, 54/255, 59/255, 60/255, 76/255]
    
    var smileyUnicodes = ["\u{1F620}", "\u{1F61E}", "\u{1F610}", "\u{1F60A}", "\u{1F60D}"]
    
    
    // MARK: - Outlets
    
    
    var surveyView = UIView()
    
    var footerLabel = UILabel()
    var cloudCherryLogoImageView = UIImageView()
    
    var primaryButton = UIButton()
    
    var faciliationTextLabel = UILabel()
    var headerLabel = UILabel()
    
    var headerView = UIView()
    var footerView = UIView()
    var logoImageView = UIImageView()
    
    var questionCtrLabel = questionCounterLabel()
    var tappedButton = UIButton()
    var previousButton = UIButton()
    var submitButton = UIButton()
    
    var singleLineTextField = UITextField()
    var multiLineTextView = UITextView()
    var starRatingView = FloatRatingView()
    
    
    // MARK: - View Life Cycle Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Hiding Navigation Bar
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        SHOW_LOADING((self.navigationController?.view)!, kMessage: "Loading...")
        
        if (_IS_USING_STATIC_TOKEN) {
            
            self.performSelector(inBackground: #selector(CCSurveyViewController.fetchSurveys), with: nil)
            
        } else {
            
            self.performSelector(inBackground: #selector(CCSurveyViewController.loginUser), with: nil)
            
        }
        
        
        // Setting Up transparent background
        
        
        self.view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        
        
        // Adding Observers for Keyboard Show/Hide
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(CCSurveyViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(CCSurveyViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        // Removing Observers
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Notification Methods for Keyboard Show/Hide
    
    
    func keyboardWillShow(_ notification: Notification) {
        if (!keyboardAppeared) {
            keyboardAppeared = true
            
            if yOffset == 0 {
                yOffset = self.surveyView.frame.origin.y
                self.surveyView.frame.origin.y = 20
            }
        }
    }
    
    
    func keyboardWillHide(_ notification: Notification) {
        if (keyboardAppeared) {
            keyboardAppeared = false
            
            if yOffset != 0 {
                self.surveyView.frame.origin.y = yOffset
                yOffset = 0
            }
        }
    }
    
    
    func loginUser() {
        let anAPI = "\(BASE_URL)\(POST_LOGIN_TOKEN)"
        let anUsername = ENCODE_STRING(SDKSession.username)
        let aPassword = ENCODE_STRING(SDKSession.password)
        
        let aPostString = "grant_type=password&username=\(anUsername)&password=\(aPassword)"
        
        let anURLHandler = CCURLHandler()
        anURLHandler.initWithURLString(anAPI)
        
        let aResponse = anURLHandler.responseForFormURLEncodedString(aPostString)
        
        if (aResponse.isKind(of: NSDictionary.self)) {
            
            if let anAccessToken = aResponse["access_token"] as? String {
                SDKSession.accessToken = "Bearer \(anAccessToken)"
                
                self.createSurveyToken()
            }
        }
    }
    
    
    func createSurveyToken() {
        let anAPI = "\(BASE_URL)\(POST_CREATE_SURVEY_TOKEN)"
        let aPostDetail = ["token" : "iostest", "location" : SDKSession.location, "validUses" : SDKSession.numberOfValidUses] as [String : Any]
        
        let anURLHandler = CCURLHandler()
        anURLHandler.initWithURLString(anAPI)
        
        let aResponse = anURLHandler.responseForJSONObject(aPostDetail as AnyObject)
        
        if (aResponse.isKind(of: NSDictionary.self)) {
            
            if let aSurveyToken = aResponse["id"] as? String {
                SDKSession.surveyToken = aSurveyToken
                self.fetchSurveys()
            }
        }
    }
    
    
    func fetchSurveys() {
        let anAPI = "\(BASE_URL)\(GET_QUESTIONS_API)"
        
        let anURLHandler = CCURLHandler()
        anURLHandler.initWithURLString(anAPI)
        
        let aResponse = anURLHandler.getResponse()
        
        if (aResponse.isKind(of: NSDictionary.self)) {
            
//            print("SURVEY RESPONSE: \(aResponse)")
//            print("-------------------------------------------")
            
            let aQuestions = aResponse["questions"] as! [NSDictionary]
            self.welcomeText = aResponse["welcomeText"] as! String
            self.thankYouText = aResponse["thankyouText"] as! String
            self.partialResponseID = aResponse["partialResponseId"] as! String
            let aCompleteLogoURL = aResponse["logoURL"] as! String
            
            self.headerColorCode = aResponse["colorCode1"] as! String
            self.footerColorCode = aResponse["colorCode2"] as! String
            self.backgroundColorCode = aResponse["colorCode3"] as! String
            
            let aLogoURLDelimiters = CharacterSet(charactersIn: "?")
            let aLogoURLSplitStrings = aCompleteLogoURL.components(separatedBy: aLogoURLDelimiters)
            self.logoURL = aLogoURLSplitStrings[0]
            
            for aQuestion in aQuestions {
                if let _ = aQuestion["questionTags"] as? [String] {
                    if let aConditionalFilter = aQuestion["conditionalFilter"] as? [String:Any] {
                        if let aFilterQuestions = aConditionalFilter["filterquestions"] {
                            if (aFilterQuestions as AnyObject).count > 0 {
                                let aQuestionDisplayType = aQuestion["displayType"] as! String
                                let aCCQuestion = CCQuestion()
                                
                                aCCQuestion.questionId = aQuestion["id"] as! String
                                aCCQuestion.name = aQuestion["text"] as! String
                                aCCQuestion.displayType = aQuestionDisplayType
                                
                                if !(aQuestion["leadingDisplayTexts"]! is NSNull) {
                                    aCCQuestion.leadingDisplayText = (aQuestion["leadingDisplayTexts"]! as! [AnyObject])
                                }
                                aCCQuestion.sequence = aQuestion["sequence"] as! Int
                                
                                if (aQuestionDisplayType == "Scale") {
                                    if let aMultiSelect = aQuestion["multiSelect"] as? [String] {
                                        
                                        let aMultiSelectDelimiters = CharacterSet(charactersIn: "-")
                                        let aMultiSelectSplitStrings = aMultiSelect[0].components(separatedBy: aMultiSelectDelimiters)
                                        
                                        for aMultiSelectSplitString in aMultiSelectSplitStrings {
                                            
                                            let aDelimiters = CharacterSet(charactersIn: ";")
                                            let aSplitStrings = aMultiSelectSplitString.components(separatedBy: aDelimiters)
                                            
                                            
                                            aCCQuestion.ratingTexts.append(aSplitStrings[1])
                                            
                                        }
                                    }
                                }
                                
                                
                                if (aQuestionDisplayType == "Select") {
                                    if let aMultiSelect = aQuestion["multiSelect"] as? [String] {
                                        aCCQuestion.singleSelectOption = aMultiSelect
                                    }
                                }
                                
                                if (aQuestionDisplayType == "MultiSelect") {
                                    if let aMultiSelect = aQuestion["multiSelect"] as? [String] {
                                        aCCQuestion.multiSelectOption = aMultiSelect
                                    }
                                }
                                
                                surveyQuestions.append(aCCQuestion)
                            } else {
                                filteredQuestions.append(aQuestion)
                            }
                        }
                    }
                    
                }
                
            }
            
            let aQuestion = CCQuestion()
            
            aQuestion.name = ""
            aQuestion.displayType = "End"
            
            surveyQuestions.append(aQuestion)
            
            let aLogoDownloadGroup = DispatchGroup()
            aLogoDownloadGroup.enter()
            
            self.logoImage = UIImage(data: try! Data(contentsOf: URL(string: logoURL)!))!
            
            aLogoDownloadGroup.leave()
            aLogoDownloadGroup.wait(timeout: DispatchTime.distantFuture)
            
            self.startSurvey()
            
        }
        
    }
    
    
    func startSurvey() {
        
        
        REMOVE_LOADING()
        
        
        // Setting up Survey View
        
        
        surveyView = UIView(frame: CGRect(x: 20, y: self.view.frame.height / 4, width: self.view.frame.width - 40, height: self.view.frame.height / 2))
        surveyView.backgroundColor = hexStringToUIColor(backgroundColorCode)
        
        self.view.addSubview(surveyView)
        
        
        // Setting up Welcome Text
        
        
        faciliationTextLabel = UILabel(frame: CGRect(x: 0, y: 10, width: surveyView.frame.width, height: 20))
        faciliationTextLabel.font = HELVETICA_NEUE(18)
        faciliationTextLabel.numberOfLines = 2
        faciliationTextLabel.textAlignment = .center
        faciliationTextLabel.text = self.welcomeText
        
        surveyView.addSubview(faciliationTextLabel)
        
        
        // Setting up Primary Button
        
        
        let aPrimaryButtonWidth: CGFloat = 120
        
        let aPrimaryButtonXAlign: CGFloat = (surveyView.frame.width - aPrimaryButtonWidth) / 2
        let aPrimaryButtonYAlign: CGFloat = (surveyView.frame.height - 50) / 2
        
        primaryButton = UIButton(frame: CGRect(x: aPrimaryButtonXAlign, y: aPrimaryButtonYAlign, width: aPrimaryButtonWidth, height: 50))
        primaryButton.backgroundColor = UIColor(red: 213/255, green: 25/255, blue: 44/255, alpha: 1.0)
        primaryButton.setTitle("CONTINUE", for: UIControlState())
        primaryButton.titleLabel?.font = HELVETICA_NEUE(12)
        primaryButton.setTitleColor(.white, for: UIControlState())
        primaryButton.addTarget(self, action: #selector(CCSurveyViewController.primaryButtonTapped), for: .touchUpInside)
        
        surveyView.addSubview(primaryButton)
        
        
        // Setting up CC Footer
        
        
        footerLabel = UILabel(frame: CGRect(x: 0, y: surveyView.frame.size.height - 50, width: surveyView.frame.width, height: 20))
        footerLabel.font = HELVETICA_NEUE(11)
        footerLabel.text = "Customer Delight powered by"
        footerLabel.textAlignment = .center
        
        surveyView.addSubview(footerLabel)
        
        
        // Setting up CloudCherry Logo
        
        
        let aLogoImage = UIImage(named: "CCLogo", in: Bundle(for: type(of: self)), compatibleWith: nil)
        let aLogoImageWidth = (aLogoImage?.size.width)! - 10
        let aLogoImageHeight = (aLogoImage?.size.height)! - 10
        
        cloudCherryLogoImageView = UIImageView(frame: CGRect(x: (surveyView.frame.width - aLogoImageWidth) / 2, y: surveyView.frame.height - 30, width: aLogoImageWidth, height: aLogoImageHeight))
        cloudCherryLogoImageView.contentMode = .scaleAspectFit
        cloudCherryLogoImageView.image = aLogoImage
        
        surveyView.addSubview(cloudCherryLogoImageView)
        
    }
    
    
    // MARK: - FloatRatingViewDelegate Method
    
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
        print("Star Rating: \(Int(self.starRatingView.rating))")
        
        starRatingQuestionAnswered = true
        selectedNPSRating = Int(self.starRatingView.rating)
        
    }
    
    
    // MARK: - Private Methods
    
    
    // Handles Button Tap for Primary button
    
    
    func primaryButtonTapped() {
        
        primaryButtonCounter += 1
        
        if (primaryButtonCounter == 1) {
            
            faciliationTextLabel.isHidden = true
            primaryButton.isHidden = true
            footerLabel.isHidden = true
            cloudCherryLogoImageView.isHidden = true
            
            
            // Setting up Header View for Survey View
            
            
            headerView = headerFooterView(frame: CGRect(x: 0, y: 0, width: surveyView.frame.width, height: 50))
            headerView.backgroundColor = hexStringToUIColor(headerColorCode)
            
            surveyView.addSubview(headerView)
            
            
            // Setting up Text Label in Header View
            
            
            headerLabel = UILabel(frame: CGRect(x: 10, y: 15, width: headerView.frame.width - 20, height: 20))
            headerLabel.adjustsFontSizeToFitWidth = true
            headerLabel.font = HELVETICA_NEUE(15)
            headerLabel.textColor = UIColor.white
            headerView.addSubview(headerLabel)
            
            
            // Setting up Footer View for Survey View
            
            
            footerView = headerFooterView(frame: CGRect(x: 0, y: surveyView.frame.height - 50, width: surveyView.frame.width, height: 50))
            footerView.backgroundColor = hexStringToUIColor(footerColorCode)
            
            surveyView.addSubview(footerView)
            
            
            // Setting up Logo Image in Footer View
            
            
            let aLogoImageViewXAlign: CGFloat = (surveyView.frame.width - 50) / 2
            
            logoImageView = UIImageView(frame: CGRect(x: aLogoImageViewXAlign, y: 0, width: 50, height: 50))
            logoImageView.image = self.logoImage
            
            footerView.addSubview(logoImageView)
            
            
            // Setting up Question Counter
            
            
            questionCtrLabel = questionCounterLabel(frame: CGRect(x: surveyView.frame.width - 60, y: surveyView.frame.height - 70, width: 50, height: 20))
            questionCtrLabel.font = HELVETICA_NEUE(11)
            questionCtrLabel.textAlignment = .right
            
            surveyView.addSubview(questionCtrLabel)
            
            
            // Setting up Previous Button in Footer View
            
            
            previousButton = UIButton(type: .custom)
            previousButton.frame = CGRect(x: 10, y: 5, width: 100, height: 40)
            previousButton.backgroundColor = UIColor.lightGray
            previousButton.setTitle("PREVIOUS", for: UIControlState())
            previousButton.setTitleColor(UIColor.black, for: UIControlState())
            previousButton.titleLabel?.font = HELVETICA_NEUE(12)
            previousButton.addTarget(self, action: #selector(CCSurveyViewController.previousButtonTapped), for: .touchUpInside)
            
            footerView.addSubview(previousButton)
            
            
            // Setting up Next/Submit Button in Footer View
            
            
            submitButton = UIButton(type: .custom)
            submitButton.frame = CGRect(x: surveyView.frame.width - 110, y: 5, width: 100, height: 40)
            submitButton.backgroundColor = UIColor.lightGray
            submitButton.setTitle("NEXT", for: UIControlState())
            submitButton.setTitleColor(UIColor.black, for: UIControlState())
            submitButton.titleLabel?.font = HELVETICA_NEUE(12)
            submitButton.addTarget(self, action: #selector(CCSurveyViewController.nextButtonTapped), for: .touchUpInside)
            
            footerView.addSubview(submitButton)
            
            self.nextButtonTapped()
            
        } else {
            
            self.navigationController?.dismiss(animated: true, completion: {
                self.surveyDelegate?.surveyExited(withStatus: SurveyExitedAt.COMPLETION)
            })
            
        }
        
    }
    
    
    // Handles button tap for Previous Button
    
    
    func previousButtonTapped() {
        
        self.questionCounter -= 1
        
        self.selectButtonMaxX = 0
        
        self.showPreviousQuestion = true
        
        self.showQuestion()
        
    }
    
    
    // Handles showing the next question
    
    
    func nextButtonTapped() {
        
        self.questionCounter += 1
        
        self.selectButtonMaxX = 0
        
        self.showPreviousQuestion = false
        
        self.showQuestion()
        
    }
    
    
    // Handles removing subviews
    
    
    func removeSubViews() {
        
        if ((self.questionCounter - 1 != 0) && (!self.showPreviousQuestion)) {
            
            self.submitResponse()
            
        }
        
        for aView in self.surveyView.subviews {
            
            if ((!aView.isKind(of: headerFooterView.self)) && (!aView.isKind(of: questionCounterLabel.self))) {
                
                aView.removeFromSuperview()
                
            }
            
        }
        
        if (self.questionCounter == surveyQuestions.count) {        //questionTexts.count
            
            questionCtrLabel.removeFromSuperview()
            
        }
        
    }
    
    
    // Handles showing question
    
    
    func showQuestion() {
        self.removeSubViews()
        
        if (self.questionCounter <= surveyQuestions.count) {   //questionTexts.count
            
            questionCtrLabel.text = "\(self.questionCounter)/\(surveyQuestions.count - 1)"      //questionTexts.count
            
        }
        
        if (self.questionCounter - 1 == 0) {
            
            previousButton.isHidden = true
            
        } else {
            
            previousButton.isHidden = false
            faciliationTextLabel.isHidden = true
            
        }
        
        self.surveyView.endEditing(true)
        
        
        let aQuestion = surveyQuestions[self.questionCounter-1]
        
        headerLabel.text = aQuestion.name
        
        if !(self.questionCounter - 1 == 0) {
            updateDuration()
        }
        
        // Conditional Text Filter
        
        if (aQuestion.displayType != "End") {
            if !(self.questionCounter - 1 == 0) {
                if aQuestion.leadingDisplayText is [String] {
                    
                } else if let aDisplayTexts = aQuestion.leadingDisplayText as? [NSDictionary] {
                        print("Casting successful: ", aDisplayTexts)
                        conditionalTextFilter(aDisplayTexts)
                } else {
                }
            }
        }
        
        var isEnd = false
        
        switch (aQuestion.displayType) {
            
        case "Scale":
            
            
            // Setting up Rating System
            
            
            let aButtonWidth = ((surveyView.frame.width) - 10) / 11
            
            let aRatingButtonYAlign: CGFloat = (surveyView.frame.height - aButtonWidth) / 2
            
            for anIndex in 0 ..< 11 {
                
                let aRatingButton = UIButton(type: .custom)
                aRatingButton.frame = CGRect(x: ((aButtonWidth * CGFloat(anIndex)) + 5), y: aRatingButtonYAlign, width: aButtonWidth, height: aButtonWidth)
                aRatingButton.tag = anIndex + 1
                aRatingButton.setTitleColor(UIColor.white, for: UIControlState())
                aRatingButton.backgroundColor = UIColor(red: red[anIndex], green: green[anIndex], blue: blue[anIndex], alpha: 1.0)
                aRatingButton.setTitle("\(anIndex)", for: UIControlState())
                aRatingButton.titleLabel?.font = HELVETICA_NEUE(11)
                aRatingButton.addTarget(self, action: #selector(CCSurveyViewController.npsRatingButtonTapped(_:)), for: .touchUpInside)
                
                surveyView.addSubview(aRatingButton)
                
            }
            
            if (aQuestion.ratingTexts.count == 2) {                 //ratingTexts.count == 2
                
                let aRatingOneLabel = UILabel(frame: CGRect(x: 5, y: (aRatingButtonYAlign + aButtonWidth + 5), width: 50, height: 20))
                aRatingOneLabel.text = aQuestion.ratingTexts[0]                             //ratingTexts[0]
                aRatingOneLabel.font = HELVETICA_NEUE(10)
                
                surveyView.addSubview(aRatingOneLabel)
                
                
                let aRatingTwoLabel = UILabel(frame: CGRect(x: surveyView.frame.width - 105, y: (aRatingButtonYAlign + aButtonWidth + 5), width: 100, height: 20))
                aRatingTwoLabel.textAlignment = .right
                aRatingTwoLabel.text = aQuestion.ratingTexts[1]                                 //ratingTexts[1]
                aRatingTwoLabel.font = HELVETICA_NEUE(10)
                
                surveyView.addSubview(aRatingTwoLabel)
                
            } else {
                
                // Default Scale Legend Colors
                
                let aColorOne = hexStringToUIColor("E40021")
                let aColorTwo = hexStringToUIColor("D4F419")
                let aColorThree = hexStringToUIColor("348F36")
                
                let aLineY = aRatingButtonYAlign + aButtonWidth + 10
                
                
                // Default Scale Legend Lines
                
                
                let aColorLineOne = UIView(frame: CGRect(x: 5, y: aLineY, width: (aButtonWidth * 7), height: 3))
                aColorLineOne.backgroundColor = aColorOne
                
                surveyView.addSubview(aColorLineOne)
                
                let aColorLineTwo = UIView(frame: CGRect(x: aColorLineOne.frame.maxX, y: aLineY, width: (aButtonWidth * 2), height: 3))
                aColorLineTwo.backgroundColor = aColorTwo
                
                surveyView.addSubview(aColorLineTwo)
                
                let aColorLineThree = UIView(frame: CGRect(x: aColorLineTwo.frame.maxX, y: aLineY, width: (aButtonWidth * 2), height: 3))
                aColorLineThree.backgroundColor = aColorThree
                
                surveyView.addSubview(aColorLineThree)
                
                
                // Default Scale Legend Texts
                
                
                let aColorLineOneLabel = UILabel(frame: CGRect(x: 5, y: aColorLineOne.frame.maxY, width: aColorLineOne.frame.width, height: 20))
                aColorLineOneLabel.textAlignment = .center
                aColorLineOneLabel.font = HELVETICA_NEUE(7)
                aColorLineOneLabel.text = "Not at all"
                
                surveyView.addSubview(aColorLineOneLabel)
                
                let aColorLineTwoLabel = UILabel(frame: CGRect(x: aColorLineOneLabel.frame.maxX, y: aColorLineOne.frame.maxY, width: aColorLineTwo.frame.width, height: 20))
                aColorLineTwoLabel.textAlignment = .center
                aColorLineTwoLabel.font = HELVETICA_NEUE(7)
                aColorLineTwoLabel.text = "Maybe"
                
                surveyView.addSubview(aColorLineTwoLabel)
                
                let aColorLineThreeLabel = UILabel(frame: CGRect(x: aColorLineTwoLabel.frame.maxX, y: aColorLineOne.frame.maxY, width: aColorLineThree.frame.width, height: 20))
                aColorLineThreeLabel.textAlignment = .center
                aColorLineThreeLabel.font = HELVETICA_NEUE(7)
                aColorLineThreeLabel.text = "YES, for sure!"
                
                surveyView.addSubview(aColorLineThreeLabel)
                
            }
            
        case "MultilineText":
            
            multiLineTextView = UITextView(frame: CGRect(x: 5, y: 100, width: self.surveyView.frame.width - 10, height: self.surveyView.frame.height - 200))
            multiLineTextView.layer.borderColor = UIColor.black.cgColor
            multiLineTextView.layer.borderWidth = 1.0
            multiLineTextView.autocorrectionType = .no
            multiLineTextView.spellCheckingType = .no
            
            surveyView.addSubview(multiLineTextView)
            
        case "Star-5":
            
            let aStarRatingYAlign: CGFloat = (self.surveyView.frame.height - 40) / 2
            
            starRatingView = FloatRatingView(frame: CGRect(x: 40, y: aStarRatingYAlign, width: self.surveyView.frame.width - 80, height: 40))
            
            starRatingView.delegate = self
            
            var anEmptyImage = UIImage(named: "StarEmpty", in: Bundle(for: type(of: self)), compatibleWith: nil)
            var aFullImage = UIImage(named: "StarFull", in: Bundle(for: type(of: self)), compatibleWith: nil)
            
            if ((SDKSession.unselectedStarRatingImage != nil) && (SDKSession.selectedStarRatingImage != nil)) {
                
                anEmptyImage = SDKSession.unselectedStarRatingImage
                aFullImage = SDKSession.selectedStarRatingImage
                
            }
            
            starRatingView.emptyImage = anEmptyImage
            starRatingView.fullImage = aFullImage
            starRatingView.contentMode = UIViewContentMode.scaleAspectFit
            
            self.surveyView.addSubview(starRatingView)
            
            
        case "Text":
            
            let aSingleLineTextFieldY: CGFloat = (self.surveyView.frame.height - 40) / 2
            
            singleLineTextField = UITextField(frame: CGRect(x: 5, y: aSingleLineTextFieldY, width: self.surveyView.frame.width - 10, height: 40))
            singleLineTextField.borderStyle = .line
            singleLineTextField.keyboardType = .default
            
            self.surveyView.addSubview(singleLineTextField)
            
        case "Number":
            
            let aSingleLineTextFieldY: CGFloat = (self.surveyView.frame.height - 40) / 2
            
            singleLineTextField = UITextField(frame: CGRect(x: 5, y: aSingleLineTextFieldY, width: self.surveyView.frame.width - 10, height: 40))
            singleLineTextField.borderStyle = .line
            singleLineTextField.keyboardType = .numberPad
            
            self.surveyView.addSubview(singleLineTextField)
            
        case "Smile-5" :
            
            let aWidth = self.surveyView.frame.width - 50
            let aButtonWidth = aWidth / 5
            let aRatingButtonYAlign: CGFloat = (surveyView.frame.height - aButtonWidth) / 2
            
            for anIndex in 0 ..< 5 {
                
                let aSmileyButton = UIButton(type: .custom)
                aSmileyButton.frame = CGRect(x: ((aButtonWidth * CGFloat(anIndex)) + 5) + 22, y: aRatingButtonYAlign, width: aButtonWidth, height: 50)
                aSmileyButton.tag = anIndex + 1
                aSmileyButton.addTarget(self, action: #selector(CCSurveyViewController.smileRatingButtonTapped(_:)), for: .touchUpInside)
                
                if ((SDKSession.unselectedSmileyRatingImages != nil) && (SDKSession.selectedSmileyRatingImages != nil)) {
                    
                    if ((SDKSession.unselectedSmileyRatingImages!.count == 5) && (SDKSession.selectedSmileyRatingImages!.count == 5)) {
                        
                        aSmileyButton.setImage(SDKSession.unselectedSmileyRatingImages![anIndex], for: UIControlState())
                        aSmileyButton.imageView?.contentMode = .scaleAspectFit
                        
                    } else {
                        
                        aSmileyButton.setTitle(self.smileyUnicodes[anIndex], for: UIControlState())
                        aSmileyButton.titleLabel?.font = HELVETICA_NEUE(25)
                        aSmileyButton.layer.borderColor = UIColor.lightGray.cgColor
                        aSmileyButton.layer.borderWidth = 1.0
                        
                    }
                    
                } else {
                    
                    aSmileyButton.setTitle(self.smileyUnicodes[anIndex], for: UIControlState())
                    aSmileyButton.titleLabel?.font = HELVETICA_NEUE(25)
                    aSmileyButton.layer.borderColor = UIColor.lightGray.cgColor
                    aSmileyButton.layer.borderWidth = 1.0
                    
                }
                
                self.surveyView.addSubview(aSmileyButton)
                
            }
            
        case "MultiSelect" :
            
            self.setupOptionButtons("MultiSelect")
            
        case "Select":
            
            self.setupOptionButtons("Select")
            
        case "End":
            
            questionCtrLabel.removeFromSuperview()
            
            headerView.isHidden = true
            footerView.isHidden = true
            logoImageView.isHidden = true
            
            faciliationTextLabel.isHidden = false
            faciliationTextLabel.frame = CGRect(x: 0, y: 10, width: surveyView.frame.width, height: 20)
            faciliationTextLabel.text = self.thankYouText
            
            surveyView.addSubview(faciliationTextLabel)
            
            printAnalytics()
            
            primaryButton.isHidden = false
            primaryButton.setTitle("CLOSE", for: UIControlState())
            
            surveyView.addSubview(primaryButton)
            
            footerLabel.isHidden = false
            
            surveyView.addSubview(footerLabel)
            
            let aLogoImage = UIImage(named: "CCLogo", in: Bundle(for: type(of: self)), compatibleWith: nil)
            let aLogoImageWidth = (aLogoImage?.size.width)! - 10
            let aLogoImageHeight = (aLogoImage?.size.height)! - 10
            
            cloudCherryLogoImageView = UIImageView(frame: CGRect(x: (surveyView.frame.width - aLogoImageWidth) / 2, y: surveyView.frame.height - 30, width: aLogoImageWidth, height: aLogoImageHeight))
            cloudCherryLogoImageView.contentMode = .scaleAspectFit
            cloudCherryLogoImageView.image = aLogoImage
            
            surveyView.addSubview(cloudCherryLogoImageView)
            
            submitButton.setTitle("FINISH", for: UIControlState())
            isEnd = true
            
        default:
            isEnd = true
            break
        }
        
        
        // Analytics
        
        if !isEnd {
        addToAnalytics()
        }
    }
    

    // Analytics Functions
    
    func addToAnalytics() {
        let aDate = Date()
        let aLastViewedAt = Int(floor(aDate.timeIntervalSince1970 * 1000))
        let aData = CCAnalytics(id: surveyQuestions[self.questionCounter - 1].questionId, name: headerLabel.text!, impression: 1, lastViewedAt: aLastViewedAt)      //questionIDs[self.questionCounter - 1]
        
        var itExists = false
        var i = 0
        for aDictionary in analyticsData {
            
            if aDictionary.id == aData.id {
                itExists = true
                break
            }
            i+=1
        }
        
        if !itExists {
            analyticsData.append(aData)
        } else {
            let aData = analyticsData[i]
            analyticsData.remove(at: i)
            updateAnalytics(aData)
        }
        
        print(analyticsData)
    }
    
    
    func updateAnalytics(_ aData: CCAnalytics) {
        
        let aDate = Date()
        let aLastViewedAt = Int(floor(aDate.timeIntervalSince1970 * 1000))
        
        aData.name = headerLabel.text!
        aData.impression += 1
        aData.lastViewedAt = aLastViewedAt
        
        analyticsData.append(aData)
    }
    
    
    func updateDuration() {
        let aData = analyticsData.last
        
        let aDate = Date()
        let aLastViewedAt = Int(floor(aDate.timeIntervalSince1970 * 1000))
        
        aData?.duration += (aLastViewedAt-(aData?.lastViewedAt)!)
        aData?.lastViewedAt = aLastViewedAt
        if analyticsData.count != 0 {
            analyticsData.removeLast()
        }
        analyticsData.append(aData!)
    }
    
    
    func printAnalytics() {
    
        print("Printing Analytics")
        
        _ANALYTICS_DATA = [NSDictionary]()
        
        for anAnalyticsData in analyticsData {
            
            let aJSON = " { id:\(anAnalyticsData.id), name: \(anAnalyticsData.name), impression:\(anAnalyticsData.impression), duration:\(anAnalyticsData.duration), lastViewedAt:\(anAnalyticsData.lastViewedAt)}"
            print(aJSON)
            
            let aDictionary = ["id" : anAnalyticsData.id, "name" : anAnalyticsData.name, "impression" : anAnalyticsData.impression, "duration" : anAnalyticsData.duration, "lastViewedAt" : anAnalyticsData.lastViewedAt] as [String : Any]
            _ANALYTICS_DATA.append(aDictionary as NSDictionary)
        }
        
    }
    
    
    // Sets up Single/Multi Select Buttons
    
    
    func setupOptionButtons(_ iQuestionDisplayType: String) {
        
        var anOptions = [String]()
        var anOptionButtonY = CGFloat(5)
        var anOnlyOneLine = true
        
        var aFirstButtonTag = 1
        var aLastButtonTag = 1
        
        if (iQuestionDisplayType == "MultiSelect") {
            
            anOptions = surveyQuestions[self.questionCounter-1].multiSelectOption                //multiSelectOptions
            
        } else {
            
            anOptions = surveyQuestions[self.questionCounter-1].singleSelectOption                                   //singleSelectOptions
            
        }
        
        let aButtonView = UIView(frame: CGRect(x: 0, y: 50, width: self.surveyView.frame.width, height: self.surveyView.frame.height - 100))
        
        for anIndex in 0 ..< anOptions.count {
            
            var anOptionButtonWidth = CGFloat()
            
            if (SDKSession.customTextStyle == .CC_CIRCLE) {
                
                anOptionButtonWidth = 40
                
            } else {
                
                anOptionButtonWidth = 50
                
            }
            
            let anOptionButton = UIButton(type: .custom)
            anOptionButton.frame = CGRect(x: (self.selectButtonMaxX) + 10, y: anOptionButtonY, width: anOptionButtonWidth, height: 40)
            anOptionButton.setTitle(anOptions[anIndex], for: UIControlState())
            anOptionButton.setTitleColor(UIColor.black, for: UIControlState())
            anOptionButton.titleLabel?.font = HELVETICA_NEUE(11)
            anOptionButton.layer.borderColor = UIColor.lightGray.cgColor
            anOptionButton.layer.borderWidth = 1.0
            
            anOptionButton.tag = anIndex + 1
            
            if (SDKSession.customTextStyle == .CC_RECTANGLE) {
                
                anOptionButton.sizeToFit()
                
            }
            
            aLastButtonTag = anIndex + 1
            
            let aButtonMaxX = anOptionButton.frame.maxX
            let aButtonWidth = anOptionButton.frame.width
            
            var anOptionButtonNewWidth = CGFloat()
            
            if (SDKSession.customTextStyle == .CC_RECTANGLE) {
                
                anOptionButtonNewWidth = aButtonWidth + 6
                
            } else {
                
                anOptionButtonNewWidth = 40
                
            }
            
            anOptionButton.frame = CGRect(x: (self.selectButtonMaxX) + 10, y: anOptionButtonY, width: anOptionButtonNewWidth, height: 40)
            
            aButtonView.addSubview(anOptionButton)
            
            if (aButtonMaxX >= (self.surveyView.frame.width - 10)) {
                
                anOnlyOneLine = false
                
                anOptionButtonY = anOptionButton.frame.maxY + 10
                self.selectButtonMaxX = 0
                
                anOptionButton.frame = CGRect(x: (self.selectButtonMaxX) + 10, y: anOptionButtonY, width: anOptionButtonNewWidth, height: 40)
                
                let aLastButton = aButtonView.viewWithTag(aLastButtonTag - 1) as! UIButton
                let aLastButtonMaxX = aLastButton.frame.maxX
                let aRemainingPadding = self.surveyView.frame.width - aLastButtonMaxX
                var aNewButtonX = (aRemainingPadding / 2) + 5
                
                for anIndex in aFirstButtonTag ..< aLastButtonTag {
                    
                    let aButton = aButtonView.viewWithTag(anIndex) as! UIButton
                    
                    aButton.frame = CGRect(x: aNewButtonX, y: aButton.frame.minY, width: aButton.frame.width, height: 40)
                    
                    if (SDKSession.customTextStyle == .CC_CIRCLE) {
                        
                        aButton.titleLabel?.adjustsFontSizeToFitWidth = true
                        aButton.layer.cornerRadius = aButton.frame.width / 2
                        aButton.titleEdgeInsets = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
                        
                    }
                    
                    aNewButtonX = aButton.frame.maxX + 10
                    
                    
                }
                
                aFirstButtonTag = aLastButtonTag
                
                anOnlyOneLine = true
                
            }
            
            self.selectButtonMaxX = anOptionButton.frame.maxX
            self.selectButtonMaxY = anOptionButton.frame.maxY
            
            if (iQuestionDisplayType == "MultiSelect") {
                
                anOptionButton.addTarget(self, action: #selector(CCSurveyViewController.multiSelectButtonTapped(_:)), for: .touchUpInside)
                
            } else {
                
                anOptionButton.addTarget(self, action: #selector(CCSurveyViewController.singleSelectButtonTapped(_:)), for: .touchUpInside)
                
            }
            
        }
        
        let aButtonViewHeight = self.selectButtonMaxY + 5
        let aButtonViewYAlign: CGFloat = (surveyView.frame.height - aButtonViewHeight) / 2
        
        aButtonView.frame = CGRect(x: 0, y: aButtonViewYAlign, width: self.surveyView.frame.width, height: aButtonViewHeight)
        
        self.surveyView.addSubview(aButtonView)
        
        if (anOnlyOneLine) {
            
            let aLastButton = self.surveyView.viewWithTag(aLastButtonTag) as! UIButton
            let aLastButtonMaxX = aLastButton.frame.maxX
            let aRemainingPadding = self.surveyView.frame.width - aLastButtonMaxX
            var aNewButtonX = (aRemainingPadding / 2) + 5
            
            for anIndex in aFirstButtonTag ..< aLastButtonTag + 1 {
                
                let aButton = self.view.viewWithTag(anIndex) as! UIButton
                
                aButton.frame = CGRect(x: aNewButtonX, y: aButton.frame.minY, width: aButton.frame.width, height: 40)
                aNewButtonX = aButton.frame.maxX + 10
                
                if (SDKSession.customTextStyle == .CC_CIRCLE) {
                    
                    aButton.titleLabel?.adjustsFontSizeToFitWidth = true
                    aButton.layer.cornerRadius = aButton.frame.width / 2
                    aButton.titleEdgeInsets = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
                    
                }
                
            }
            
        }
        
    }
    
    
    // Submits the partial response after every question
    
    
    func submitResponse() {
        
        let aRequest = NSMutableURLRequest(url: URL(string: "\(BASE_URL)\(POST_ANSWER_PARTIAL)")!)
        
        var aSurveyResponse = Dictionary<String, AnyObject>()
        var aSurveyResponseArray: Array<AnyObject> = []
        var aCurrentQuestionAnswered = false
        
        let anIndex = self.questionCounter - 2
        
        switch (surveyQuestions[anIndex].displayType) {             //self.questionDisplayTypes[anIndex]
        case "Scale":
            
            // NPS Question
            
            if (npsQuestionAnswered) {
                aCurrentQuestionAnswered = true
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: selectedNPSRating, iTextResponse: [""],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["numberInput" : selectedNPSRating as AnyObject, "questionId" :surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
            }
            
        case "MultilineText":
            
            // Multiline Answer
            
            if (multiLineTextView.text != "") {
                
                aCurrentQuestionAnswered = true
                
                let aResponseText = multiLineTextView.text
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: -1, iTextResponse: [aResponseText!],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["textInput" : aResponseText as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
            }
            
        case "Star-5":
            
            // Star Rating Answer
            
            if (starRatingQuestionAnswered) {
                
                aCurrentQuestionAnswered = true
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: selectedNPSRating, iTextResponse: [""],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["numberInput" : selectedNPSRating as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
            }
            
        case "Text":
            
            // Single Line AlphaNumeric Text
            
            if (singleLineTextField.text != "") {
                
                aCurrentQuestionAnswered = true
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: -1, iTextResponse: [singleLineTextField.text!],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["textInput" : singleLineTextField.text! as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
                singleLineTextField.text = ""
                
            }
            
        case "Number":
            
            // Single Line Numeric Text
            
            if (singleLineTextField.text != "") {
                
                aCurrentQuestionAnswered = true
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: -1, iTextResponse: [singleLineTextField.text!],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["textInput" : singleLineTextField.text! as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
                singleLineTextField.text = ""
                
            }
            
        case "Smile-5" :
            
            // Smiley Question
            
            if (smileRatingQuestionAnswered) {
                
                aCurrentQuestionAnswered = true
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: selectedSmileRating, iTextResponse: [""],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["numberInput" : selectedSmileRating as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
            }
            
        case "MultiSelect" :
            
            // Multi Select Question
            
            if (selectedMultiSelectOptions.count != 0) {
                
                aCurrentQuestionAnswered = true
                
                var selectedMultiOptionsString = ""
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: -1, iTextResponse: selectedMultiSelectOptions,iDidRespond: aCurrentQuestionAnswered)
                
                for anIndex in 0 ..< selectedMultiSelectOptions.count {
                    
                    if (anIndex == (selectedMultiSelectOptions.count - 1)) {
                        
                        selectedMultiOptionsString += "\(selectedMultiSelectOptions[anIndex])"
                        
                    } else {
                        
                        selectedMultiOptionsString += "\(selectedMultiSelectOptions[anIndex]),"
                        
                    }
                    
                }
                
                aSurveyResponse = ["textInput" : selectedMultiOptionsString as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
            }
            
        case "Select":
            
            // Single Select Option
            
            if (!selectedSingleSelectOption.isEmpty) {
                
                aCurrentQuestionAnswered = true
                
                storeResponse(surveyQuestions[anIndex].questionId, iQuestionType: surveyQuestions[anIndex].displayType, iNumberResponse: -1, iTextResponse: [selectedSingleSelectOption],iDidRespond: aCurrentQuestionAnswered)
                
                aSurveyResponse = ["textInput" : selectedSingleSelectOption as AnyObject, "questionId" : surveyQuestions[anIndex].questionId as AnyObject, "questionText" : surveyQuestions[anIndex].name as AnyObject]
                
            }
            
        default:
            
            break
            
        }
        
        if (aCurrentQuestionAnswered) {
            
            if (SDKSession.prefillDictionary != nil) {
                
                for (aKey, aValue) in SDKSession.prefillDictionary! {
                    
                    aSurveyResponse["\(aKey)"] = "\(aValue)" as AnyObject
                    
                }
                
            }
            
        }
        
        aSurveyResponseArray.append(aSurveyResponse as AnyObject)
        
        let aJsonData: Data =  try! JSONSerialization.data(withJSONObject: aSurveyResponseArray, options: JSONSerialization.WritingOptions.prettyPrinted)
        let aJsonString: String = String(data: aJsonData, encoding: String.Encoding.utf8)!
        
        print(aJsonString)
        
        let aPostData = NSData(data: aJsonString.data(using: String.Encoding.utf8)!) as Data
        
        aRequest.httpMethod = "POST"
        aRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        aRequest.httpBody = aPostData
        
        let aTaskOne = URLSession.shared.dataTask(with: (aRequest as URLRequest), completionHandler: { (aData, aResponse, anError) in
            
            if let aHttpResponse = aResponse as? HTTPURLResponse {
                
                let aResponseStatusCode = aHttpResponse.statusCode
                
                print("Response Status Code: \(aResponseStatusCode)")
                
                if (aResponseStatusCode == 204) {
                    
                    print("\(self.surveyQuestions[self.questionCounter - 2].displayType) Response Submitted")
                    
                }
                
            } else {
                
                print(anError?.localizedDescription)
                
            }
            
        }) 
        
        aTaskOne.resume()
        
        npsQuestionAnswered = false
        starRatingQuestionAnswered = false
        smileRatingQuestionAnswered = false
        tappedButton = UIButton()
        
    }
    
    
    // Store the responses of the user
    
    
    func storeResponse(_ iQuestionID:String, iQuestionType:String, iNumberResponse:Int, iTextResponse:[String], iDidRespond:Bool) {
        
        if iDidRespond {
            
            let aResponse = CCQuestionResponse()
            aResponse.questionID = iQuestionID
            aResponse.questionType = iQuestionType
            aResponse.numberResponse = iNumberResponse
            aResponse.textResponse = iTextResponse
            aResponse.isAnswered = true
            
            var aFlag = 0
            
            for someResponse in questionsAnswered {
                
                if someResponse.questionID == iQuestionID {
                    questionsAnswered.remove(at: aFlag)
                }
                aFlag+=1
            }
            questionsAnswered.append(aResponse)
        }
        
    }
    
    
    // Conditional Question Text Filter
    
    
    func conditionalTextFilter(_ iLeadingDisplayTextOptions:[NSDictionary]) {
        for aLeadingDisplayTextOption in iLeadingDisplayTextOptions {
            
            if let aFilterQuestions = (aLeadingDisplayTextOption["filter"] as? [String:Any])!["filterquestions"] {
                
                let aFilterQuestions = aFilterQuestions as! [NSDictionary]
                
                var didSatisfy = false
                var didFail = false
                
                for aFilterQuestion in aFilterQuestions {
                    
                    print(aFilterQuestion)
                    
                    if isAnd(aFilterQuestion) {
                        if (conditionCheck(aFilterQuestion) && !didFail) {
                            
                            didSatisfy = true
                            
                        } else {
                            
                            didFail = true
                            break
                            
                        }
                        
                    } else if isOr(aFilterQuestion) {
                        
                        if (conditionCheck(aFilterQuestion)) {
                            
                            didSatisfy = true
                            break
                            
                        }
                    }
                    
                }
                
                if didSatisfy && !didFail {
                    headerLabel.text = aLeadingDisplayTextOption["text"] as? String
                }
                
            } else {
            }
        }
    }

    
    // Conditional Flow Filter
    
    
    func conditionalFlowFilter(_ iQuestionId:String) {
        
        var anAddedCount = 0
        var aRemovedCount = 0
        
        if isQuestionAnswered(iQuestionId) {
            
            for aConditionalQuestion in filteredQuestions {
                
                if let aConditionalFilter = aConditionalQuestion["conditionalFilter"] as? [String:Any] {
                    
                    var didSatisfy = false
                    var didFail = false
                    
                    let aFilterByQuestions = aConditionalFilter["filterquestions"] as! [NSDictionary]
                    for aFilterByQuestion in aFilterByQuestions {
                        print(aFilterByQuestion)
                        if isAnd(aFilterByQuestion) {
                            if (conditionCheck(aFilterByQuestion) && !didFail) {
                                didSatisfy = true
                            } else {
                                didFail = true
                                break
                            }
                        } else if isOr(aFilterByQuestion) {
                            if (conditionCheck(aFilterByQuestion)) {
                                didSatisfy = true
                                break
                            }
                        }
                    }
                    
                    var aFlag = false
                    
                    if didSatisfy && !didFail {
                    
                        let aConditionalId = aConditionalQuestion["id"] as! String
                        
                        for aQuestion in surveyQuestions {
                            
                            if aQuestion.questionId == aConditionalId {
                                aFlag = true
                                break
                            }
                        }
                        
                        if !aFlag {
                            addToQuestions(aConditionalQuestion)
                            anAddedCount+=1
                        }
                        
                    } else {
                    
                        let aConditionalId = aConditionalQuestion["id"] as! String
                        
                        for aQuestion in surveyQuestions {
                            
                            if aQuestion.questionId == aConditionalId {
                                aFlag = true
                                break
                            }
                        }
                        if aFlag {
                            removeFromQuestions(aConditionalId)
                            aRemovedCount += 1
                        }
                    }
                    
                }
            }
        }
        
        if anAddedCount > 0 || aRemovedCount > 0 {
        }
    }
    
    
    func addToQuestions(_ aQuestion:NSDictionary) {
        
        let aQuestionDisplayType = aQuestion["displayType"] as! String
        let aCCQuestion = CCQuestion()
        
        aCCQuestion.questionId = aQuestion["id"] as! String
        aCCQuestion.name = aQuestion["text"] as! String
        aCCQuestion.displayType = aQuestionDisplayType
        
        if !(aQuestion["leadingDisplayTexts"]! is NSNull) {
            aCCQuestion.leadingDisplayText = (aQuestion["leadingDisplayTexts"]! as! [AnyObject])
        }
        
        aCCQuestion.sequence = aQuestion["sequence"] as! Int
        
        if (aQuestionDisplayType == "Scale") {
            
            if let aMultiSelect = aQuestion["multiSelect"] as? [String] {
                
                let aMultiSelectDelimiters = CharacterSet(charactersIn: "-")
                let aMultiSelectSplitStrings = aMultiSelect[0].components(separatedBy: aMultiSelectDelimiters)
                
                for aMultiSelectSplitString in aMultiSelectSplitStrings {
                    
                    let aDelimiters = CharacterSet(charactersIn: ";")
                    let aSplitStrings = aMultiSelectSplitString.components(separatedBy: aDelimiters)
                    
                    
                    aCCQuestion.ratingTexts.append(aSplitStrings[1])
                    
                }
                
            }
            
        }
        
        
        if (aQuestionDisplayType == "Select") {
            
            if let aMultiSelect = aQuestion["multiSelect"] as? [String] {
                
                aCCQuestion.singleSelectOption = aMultiSelect
                
            }
            
        }
        
        if (aQuestionDisplayType == "MultiSelect") {
            
            if let aMultiSelect = aQuestion["multiSelect"] as? [String] {
                
                aCCQuestion.multiSelectOption = aMultiSelect
                //                                    self.multiSelectOptions = aMultiSelect
                
            }
            
        }

        sortSurveyQuestions()
    }

    
    func sortSurveyQuestions() {
        surveyQuestions = surveyQuestions.sorted( by: { $0.sequence < $1.sequence })
        for aQuestion in surveyQuestions {
            print(aQuestion.sequence)
        }
    }
    
    
    func removeFromQuestions(_ iQuestionId:String) {
        //RemoveFromQuestion, analytics and stored Responses
    }
    
    
    // If groupBy is AND (By Default or if Specified)
    
    
    func isAnd(_ iFilterQuestion:NSDictionary) -> Bool {
        if iFilterQuestion["groupBy"] as? String == "AND" || iFilterQuestion["groupBy"] is NSNull {
            return true
        } else {
            return false
        }
    }
    
    
    // If groupBy is OR (Explicit)
    
    
    func isOr(_ iFilterQuestion:NSDictionary) -> Bool {
        if iFilterQuestion["groupBy"] as? String == "OR" {
            return true
        } else {
            return false
        }
    }
    
    
    func isANumberCondition(_ iFilterQuestion:NSDictionary) -> Bool {
        if let aCondition = iFilterQuestion["answerCheck"] as? [String] {
            let aCondition = aCondition[0]
            if(aCondition.lowercased() == "gt" || aCondition.lowercased() == "lt" || aCondition.lowercased() == "eq") {
                return true
            }
            return false
        }
        
        return false
    }
    
    
    //Conditional Text Check
    
    
    func conditionCheck(_ iFilterQuestion:NSDictionary) -> Bool {
        if isANumberCondition(iFilterQuestion) {
            if let kConditions = iFilterQuestion["answerCheck"] as? [String] {
                let aCondition = kConditions[0]
                let aQuestionId = iFilterQuestion["questionId"] as! String
                
                if intAnswerForQuestionWithID(aQuestionId) != nil {
                    let anAnswer = intAnswerForQuestionWithID(aQuestionId)
                    let aNumber = iFilterQuestion["number"] as! Int
                    
                    if aCondition.lowercased() == "lt" {
                        
                        if aNumber > anAnswer {
                            return true
                        }
                        
                    } else if aCondition.lowercased() == "gt" {
                        if aNumber < anAnswer {
                            return true
                        }
                        
                    } else if aCondition.lowercased() == "eq" {
                        if aNumber == anAnswer {
                            return true
                        }
                    } else {
                        return false
                    }
                }
            }
            
        } else {
            
            var didFindAll = false
            
            if let kConditions = iFilterQuestion["answerCheck"] as? [String] {
                
                let aQuestionId = iFilterQuestion["questionId"] as! String
                
                if stringAnswerForQuestionWithID(aQuestionId) != nil {
                    
                    let aStringAnswer = stringAnswerForQuestionWithID(aQuestionId)
                    var aStringArray = [String]()
                    aStringArray = aStringAnswer!
                    
                    for aCondition in kConditions {
                        
                        if aStringArray.contains(aCondition) {
                            didFindAll = true
                            
                        } else {
                            didFindAll = false
                            break
                        }
                        
                    }
                    if didFindAll {
                        return true
                    }
                }
                
            }
            
        }
        
        return false
    }
    
    
    // Return Int Answers
    
    
    func intAnswerForQuestionWithID(_ iQuestionID:String) -> Int? {
        
        for aQuestionAnswered in questionsAnswered {
            
            if aQuestionAnswered.questionID == iQuestionID {
                return aQuestionAnswered.numberResponse
            }
        }
        return nil
    }
    
    
    func isQuestionAnswered(_ iQuestionID:String) -> Bool {
        
        for aQuestionAnswered in questionsAnswered {
            
            if aQuestionAnswered.questionID == iQuestionID {
                return true
            }
            
        }
        return false
    }

    
    
    // Return String Answers
    
    
    func stringAnswerForQuestionWithID(_ iQuestionID:String) -> [String]? {
        
        for aQuestionAnswered in questionsAnswered {
            
            if aQuestionAnswered.questionID == iQuestionID {
                return aQuestionAnswered.textResponse
            }
            
        }
        return nil
    }
    
    
    // Converts HEX color string to RGB (HEX received from API response)
    
    
    func hexStringToUIColor(_ iHexColorCodeString:String) -> UIColor {
        
        var aColorCodeString:String = iHexColorCodeString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (aColorCodeString.hasPrefix("#")) {
            aColorCodeString = aColorCodeString.substring(from: aColorCodeString.characters.index(aColorCodeString.startIndex, offsetBy: 1))
        }
        
        if ((aColorCodeString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var aRGBValue:UInt32 = 0
        Scanner(string: aColorCodeString).scanHexInt32(&aRGBValue)
        
        return UIColor(
            red: CGFloat((aRGBValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((aRGBValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(aRGBValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
        
    }
    
    
    // Handles NPS Survey button taps
    
    
    func npsRatingButtonTapped(_ iButton: UIButton) {
        
        if let aTappedNPSButton = self.view.viewWithTag(iButton.tag) as? UIButton {
            
            npsQuestionAnswered = true
            
            let anIndex = tappedButton.tag - 1
            
            if (anIndex != -1) {
                
                tappedButton.setTitleColor(UIColor.white, for: UIControlState())
                tappedButton.backgroundColor = UIColor(red: red[anIndex], green: green[anIndex], blue: blue[anIndex], alpha: 1.0)
                tappedButton.layer.borderColor = UIColor.clear.cgColor
                
            }
            
            aTappedNPSButton.setTitleColor(UIColor.black, for: UIControlState())
            aTappedNPSButton.backgroundColor = UIColor.lightGray
            aTappedNPSButton.layer.borderColor = UIColor.black.cgColor
            aTappedNPSButton.layer.borderWidth = 1.0
            
            tappedButton = aTappedNPSButton
            
            selectedNPSRating = iButton.tag - 1
            
        }
        
    }
    
    
    // Handles Smile Rating button taps
    
    
    func smileRatingButtonTapped(_ iButton: UIButton) {
        
        if let aTappedSmileButton = self.view.viewWithTag(iButton.tag) as? UIButton {
            
            smileRatingQuestionAnswered = true
            
            let anIndex = tappedButton.tag - 1
            
            if ((SDKSession.unselectedSmileyRatingImages != nil) && (SDKSession.selectedSmileyRatingImages != nil)) {
                
                if ((SDKSession.unselectedSmileyRatingImages!.count == 5) && (SDKSession.selectedSmileyRatingImages!.count == 5)) {
                    
                    if (anIndex != -1) {
                        
                        tappedButton.setImage(SDKSession.unselectedSmileyRatingImages![anIndex], for: UIControlState())
                        
                    }
                    
                    aTappedSmileButton.setImage(SDKSession.selectedSmileyRatingImages![iButton.tag - 1], for: UIControlState())
                    
                } else {
                    
                    if (anIndex != -1) {
                        
                        tappedButton.backgroundColor = UIColor.clear
                        
                    }
                    
                    aTappedSmileButton.backgroundColor = UIColor.lightGray
                    
                }
                
            } else {
                
                if (anIndex != -1) {
                    
                    tappedButton.backgroundColor = UIColor.clear
                    
                }
                
                aTappedSmileButton.backgroundColor = UIColor.lightGray
                
            }
            
            tappedButton = aTappedSmileButton
            
            selectedSmileRating = iButton.tag
            
        }
        
    }
    
    
    // Handles Single Select button taps
    
    
    func singleSelectButtonTapped(_ iButton: UIButton) {
        
        if let aTappedButton = self.view.viewWithTag(iButton.tag) as? UIButton {
            
            tappedButton.backgroundColor = UIColor.white
            tappedButton = iButton
            
            aTappedButton.backgroundColor = UIColor(red: 242/255, green: 219/255, blue: 29/255, alpha: 1.0)
            
            self.selectedSingleSelectOption = (aTappedButton.titleLabel?.text!)!
            
        }
        
    }
    
    
    // Handles Multi Select button taps
    
    
    func multiSelectButtonTapped(_ iButton: UIButton) {
        
        if let aTappedButton = self.view.viewWithTag(iButton.tag) as? UIButton {
            
            let aSelectedButtonTitle = (aTappedButton.titleLabel?.text!)!
            
            if (self.selectedMultiSelectOptions.contains(aSelectedButtonTitle)) {
                
                self.removeSelectedString(&self.selectedMultiSelectOptions, iStringToRemove: aSelectedButtonTitle)
                aTappedButton.backgroundColor = UIColor.white
                print(self.selectedMultiSelectOptions)
                
            } else {
                
                self.selectedMultiSelectOptions.append(aSelectedButtonTitle)
                aTappedButton.backgroundColor = UIColor(red: 242/255, green: 219/255, blue: 29/255, alpha: 1.0)
                print(self.selectedMultiSelectOptions)
                
            }
            
        }
        
    }
    
    
    func removeSelectedString (_ iFromArray: inout [String], iStringToRemove: String){
        
        iFromArray = iFromArray.filter{$0 != iStringToRemove}
        
    }
}
