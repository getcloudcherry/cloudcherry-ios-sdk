//
//  CCLoadingView.swift
//  CloudCherryiOSFramework
//
//  Created by Vishal Chandran on 03/10/16.
//  Copyright © 2016 Vishal Chandran. All rights reserved.
//

import UIKit

/**
 A generic loading view animation that can be used to indicate a delay of any sorts.
 */

class CCLoadingView: UIView {

    
    // MARK: - Outlets
    
    
    var message = String()
    var style = UIActivityIndicatorViewStyle.White
    
    
    // MARK: - Initialization
    
    /**
     Initiatize the Loading View.
     
     - parameter iFrame: Frame of the Loading View.
     
     - parameter iMessage: The message to be dispayed while showing the loading view.
     */
    
    func initWithFrame(iFrame: CGRect, message iMessage: String) {
        
        self.frame = iFrame
        self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        self.style = .White
        self.message = iMessage
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Starts the Loading Animation.
     */
    
    func startLoading() {
        
        let aLoadingIndicator = UIActivityIndicatorView()
        aLoadingIndicator.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, UIScreen.mainScreen().bounds.size.height / 2)
        aLoadingIndicator.activityIndicatorViewStyle = self.style
        self.addSubview(aLoadingIndicator)
        aLoadingIndicator.startAnimating()
        
        let aFrame = CGRectMake(0, CGRectGetMaxY(aLoadingIndicator.frame) + 10, self.bounds.size.width, 30)
        let aLabel = UILabel(frame: aFrame)
        aLabel.backgroundColor = UIColor.clearColor()
        aLabel.textAlignment = .Center
        aLabel.font = UIFont.systemFontOfSize(15)
        aLabel.textColor = UIColor.whiteColor()
        aLabel.text = self.message
        
        self.addSubview(aLabel)
        
    }

}
