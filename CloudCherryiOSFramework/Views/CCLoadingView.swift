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
    var style = UIActivityIndicatorViewStyle.white
    
    
    // MARK: - Initialization
    
    /**
     Initiatize the Loading View.
     
     - parameter iFrame: Frame of the Loading View.
     
     - parameter iMessage: The message to be dispayed while showing the loading view.
     */
    
    func initWithFrame(_ iFrame: CGRect, message iMessage: String) {
        
        self.frame = iFrame
        self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        self.style = .white
        self.message = iMessage
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Starts the Loading Animation.
     */
    
    func startLoading() {
        
        let aLoadingIndicator = UIActivityIndicatorView()
        aLoadingIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        aLoadingIndicator.activityIndicatorViewStyle = self.style
        self.addSubview(aLoadingIndicator)
        aLoadingIndicator.startAnimating()
        
        let aFrame = CGRect(x: 0, y: aLoadingIndicator.frame.maxY + 10, width: self.bounds.size.width, height: 30)
        let aLabel = UILabel(frame: aFrame)
        aLabel.backgroundColor = UIColor.clear
        aLabel.textAlignment = .center
        aLabel.font = UIFont.systemFont(ofSize: 15)
        aLabel.textColor = UIColor.white
        aLabel.text = self.message
        
        self.addSubview(aLabel)
        
    }

}
