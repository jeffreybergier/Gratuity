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
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    private let titleTextAttributes = GratuitousUIColor.WatchFonts.titleText
    private let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            // putting this in a background queue allows willActivate to finish, the animation to start.
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                self.configureInterfaceController()
            }
        }
    }
    
    private func configureInterfaceController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "repeatAnimationTimer:", userInfo: nil, repeats: true)
            self.animationTimer?.fire()
            
            let font = GratuitousUIColor.WatchFonts.titleText[NSFontAttributeName]
            
            self.setTitle(NSLocalizedString("Tutorial", comment: ""))
            
            self.instructionTextLabel?.setTextColor(GratuitousUIColor.lightTextColor())
            self.instructionTextLabel?.setAttributedText(NSAttributedString(string: NSLocalizedString("Use the Digital Crown to scroll.", comment: ""), attributes: self.titleTextAttributes))
            
            self.getStartedButtonGroup?.setBackgroundColor(GratuitousUIColor.lightBackgroundColor())
            self.getStartedButtonLabel?.setTextColor(GratuitousUIColor.ultraLightTextColor())
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
        self.scrollingAnimationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 23), duration: 2.0, repeatCount: 1)
    }
    
    @objc private func animateUpTimer(timer: NSTimer?) {
        timer?.invalidate()
        let animateDownTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "animateDownTimer:", userInfo: nil, repeats: false)
        self.scrollingAnimationImageView?.setImageNamed("scrollAnimation-")
        self.scrollingAnimationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 23), duration: 2.0, repeatCount: 1)
    }
    
    @IBAction private func didTapGetStartedButton() {
        self.dataSource.defaultsManager.showTutorialAtLaunch = false
        switch self.dataSource.defaultsManager.correctWatchInterface {
        case .CrownScroller:
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: CrownScrollerInterfaceContext.Bill.rawValue)
        case .ThreeButtonStepper:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: ThreeButtonStepperInterfaceContext.Bill.rawValue)
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
}
