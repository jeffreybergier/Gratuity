//
//  AppDelegateInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class AppDelegateInterfaceController: WKInterfaceController {
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override func willActivate() {
        super.willActivate()
        
        //check my server for which UI the watch should use
        self.checkWatchUIJSON()
        
        switch self.dataSource.correctWatchInterface {
        case .CrownScrollInfinite:
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: InterfaceControllerContext.CrownScrollInfinite.rawValue)
        case .CrownScrollPaged:
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: InterfaceControllerContext.CrownScrollPagedTens.rawValue)
        case .ThreeButtonStepper:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
//        case .StepperInfinite:
//            self.pushControllerWithName("StepperInfiniteInterfaceController", context: InterfaceControllerContext.StepperInfinite.rawValue)
//        case .StepperPaged:
//            self.pushControllerWithName("StepperTensInterfaceController", context: InterfaceControllerContext.StepperPagedTens.rawValue)
        }
    }
    
    private func checkWatchUIJSON() {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "http://www.saturdayapps.com/gratuity/watchUI.json")!
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
                        self.dataSource.correctWatchInterface = interfaceState
                    }
                }
            }
        }
    }
}
