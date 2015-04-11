//
//  AppDelegateInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class AppDelegateInterfaceController: WKInterfaceController {
    
    @IBOutlet private weak var animationImageView: WKInterfaceImage?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override func willActivate() {
        super.willActivate()
        
        // start animating
        self.animationImageView?.setImageNamed("gratuityCap4-")
        self.animationImageView?.startAnimatingWithImagesInRange(NSRange(location: 0, length: 39), duration: 2, repeatCount: 10)
        
        // configure the timer to fix an issue where sometimes the UI would not push to the correct interface controller.
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "delayPushAppropriateInterfaceController:", userInfo: nil, repeats: false)
    }
    
    @objc private func delayPushAppropriateInterfaceController(timer: NSTimer?) {
        timer?.invalidate()
        
        if self.dataSource.defaultsManager.showTutorialAtLaunch == true {
            self.pushControllerWithName("TutorialInterfaceController", context: nil)
        } else {
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: CrownScrollerInterfaceContext.Bill.rawValue)
        }
    }
}
