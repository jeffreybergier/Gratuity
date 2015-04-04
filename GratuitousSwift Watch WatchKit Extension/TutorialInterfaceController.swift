//
//  TutorialInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 4/1/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class TutorialInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var scrollingAnimationImageView: WKInterfaceImage?
    @IBOutlet private weak var instructionTextLabel: WKInterfaceLabel?
    @IBOutlet private weak var getStartedButtonLabel: WKInterfaceLabel?
    @IBOutlet private weak var getStartedButtonGroup: WKInterfaceGroup?
    
    private var animationTimer: NSTimer?
    private var interfaceControllerIsConfigured = false
    private var animationsShouldStartAfterViewAlreadytConfigured = false
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let tutorialTitleTextAttributes = GratuitousUIColor.WatchFonts.tutorialTitleText
    private let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        } else {
            if self.animationsShouldStartAfterViewAlreadytConfigured == true {
                self.animationsShouldStartAfterViewAlreadytConfigured = false
                self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: "repeatAnimationTimer:", userInfo: nil, repeats: true)
                self.animationTimer?.fire()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: "repeatAnimationTimer:", userInfo: nil, repeats: true)
            self.animationTimer?.fire()
            
            self.setTitle(NSLocalizedString("Tutorial", comment: ""))
            
            self.instructionTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Use the Digital Crown to scroll", comment: ""), attributes: self.tutorialTitleTextAttributes))
            
            self.getStartedButtonGroup?.setBackgroundColor(GratuitousUIColor.mediumBackgroundColor())
            self.getStartedButtonLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Get Started", comment: ""), attributes: self.largerButtonTextAttributes))
            
            self.interfaceControllerIsConfigured = true
        }
    }
    
    @objc private func repeatAnimationTimer(timer: NSTimer?) {
        self.animateUpTimer(nil)
    }
    
    @objc private func animateDownTimer(timer: NSTimer?) {
        timer?.invalidate()
        self.scrollingAnimationImageView?.setImageNamed("scrollDownAnimation-")
        self.scrollingAnimationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 23), duration: 3.0, repeatCount: 1)
    }
    
    @objc private func animateUpTimer(timer: NSTimer?) {
        timer?.invalidate()
        let animateDownTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "animateDownTimer:", userInfo: nil, repeats: false)
        self.scrollingAnimationImageView?.setImageNamed("scrollUpAnimation-")
        self.scrollingAnimationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 23), duration: 3.0, repeatCount: 1)
    }
    
    @IBAction private func didTapGetStartedButton() {
        self.dataSource.defaultsManager.showTutorialAtLaunch = false
        //            switch self.dataSource.defaultsManager.correctWatchInterface {
        //            case .CrownScroller:
        self.pushControllerWithName("CrownScrollBillInterfaceController", context: CrownScrollerInterfaceContext.Bill.rawValue)
        //            case .ThreeButtonStepper:
        //                self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: ThreeButtonStepperInterfaceContext.Bill.rawValue)
        //}
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        self.animationsShouldStartAfterViewAlreadytConfigured = true
        self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
}
