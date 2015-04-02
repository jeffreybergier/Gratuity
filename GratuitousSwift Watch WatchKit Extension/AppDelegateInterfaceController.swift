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
        
        // check my server for which UI the watch should use
        self.checkWatchUIJSON()
        
        // configure the timer to fix an issue where sometimes the UI would not push to the correct interface controller.
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "delayPushAppropriateInterfaceController:", userInfo: nil, repeats: false)
    }
    
    @objc private func delayPushAppropriateInterfaceController(timer: NSTimer?) {
        timer?.invalidate()
        
        if self.dataSource.defaultsManager.showTutorialAtLaunch == true {
            self.pushControllerWithName("TutorialInterfaceController", context: nil)
        } else {
            switch self.dataSource.defaultsManager.correctWatchInterface {
            case .CrownScroller:
                self.pushControllerWithName("CrownScrollBillInterfaceController", context: CrownScrollerInterfaceContext.Bill.rawValue)
            case .ThreeButtonStepper:
                self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: ThreeButtonStepperInterfaceContext.Bill.rawValue)
            }
        }
    }
    
    private func checkWatchUIJSON() {
        let session = NSURLSession.sharedSession()
        let url = GratuitousUserDefaults.watchUIURL()
        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode == 200 {
                        self.extractCorrectInterfaceFromData(data)
                    }
                }
            }
        })
        task.resume()
    }
    
    private func extractCorrectInterfaceFromData(data: NSData?) {
        if let data = data {
            if let jsonDictionaryArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? [NSDictionary] {
                if let watchStyleString = jsonDictionaryArray.first?["watchUIStyle"] as? String {
                    if let interfaceState = CorrectWatchInterface.interfaceStateFromString(watchStyleString) {
                        self.dataSource.defaultsManager.correctWatchInterface = interfaceState
                    }
                }
            }
        }
    }
}
