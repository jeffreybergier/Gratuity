//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let defaultsManager = GratuitousUserDefaults()
    private let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //crashlytics intializer
        Fabric.with([Crashlytics()])
        
        //initialize the view controller from the storyboard
        let tipViewController = self.storyboard.instantiateInitialViewController() as? UIViewController
        
        //configure the window
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        // Check if the date is April 24 or later to display watch info UI
        self.defaultsManager.watchInfoViewControllerShouldAppear = self.currentDateAfterTriggerDate()
        
        // if the device is an iphone 4s or an ipad, mark watchInfoViewControllerWasDismissed as true
        if self.defaultsManager.watchInfoViewControllerWasDismissed == false {
            self.defaultsManager.watchInfoViewControllerWasDismissed = self.checkForWatchInvalidDevice()
        }
        
        self.window?.rootViewController = tipViewController
        self.window?.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        self.window?.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.makeKeyAndVisible() //if window is not initialized yet, this should crash.
        
        return true
    }
    
    private func checkForWatchInvalidDevice() -> Bool {
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            return true
        case .Phone:
            let screenHeight = UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width ? UIScreen.mainScreen().bounds.size.height : UIScreen.mainScreen().bounds.size.width
            if screenHeight < 568 { // if its an iphone and if the screen is smaller than 568, its an iphone 4s and its not apple watch compatible
                return true
            } else {
                return false
            }
        case .Unspecified:
            return false
        }
    }
    
    private func currentDateAfterTriggerDate() -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let todaysDate = NSDate(timeIntervalSinceNow: 0)
        let triggerDateComponents = NSDateComponents()
        triggerDateComponents.month = 4
        triggerDateComponents.day = 24
        triggerDateComponents.year = 2015
        if let triggerDate = calendar.dateFromComponents(triggerDateComponents) {
            let dateComparison = calendar.compareDate(todaysDate, toDate: triggerDate, toUnitGranularity: NSCalendarUnit.DayCalendarUnit)
            switch dateComparison {
            case .OrderedAscending:
                return false // returns false if current date is before April 24, 2015
            case .OrderedDescending:
                return self.dateIsBeforeJuneOne(todaysDate)
            case .OrderedSame:
                return self.dateIsBeforeJuneOne(todaysDate)
            }
        }
        return false
    }
    
    private func dateIsBeforeJuneOne(currentDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let triggerDateComponents = NSDateComponents()
        triggerDateComponents.month = 6
        triggerDateComponents.day = 1
        triggerDateComponents.year = 2015
        if let triggerDate = calendar.dateFromComponents(triggerDateComponents) {
            let dateComparison = calendar.compareDate(currentDate, toDate: triggerDate, toUnitGranularity: NSCalendarUnit.DayCalendarUnit)
            switch dateComparison {
            case .OrderedAscending:
                return true // returns true if current date is before June 01, 2015
            case .OrderedDescending:
                return false
            case .OrderedSame:
                return false // returns true if current date is before June 01, 2015
            }
        }
        return false
    }
    
//    private func checkWatchUIJSON() {
//        let session = NSURLSession.sharedSession()
//        let url = GratuitousUserDefaults.watchUIURL()
//        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
//        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
//            if error == nil {
//                if let response = response as? NSHTTPURLResponse {
//                    if response.statusCode == 200 {
//                        self.extractCorrectInterfaceFromData(data)
//                    }
//                }
//            }
//        })
//        task.resume()
//    }
//    
//    private func extractCorrectInterfaceFromData(data: NSData?) {
//        if let data = data {
//            if let jsonDictionaryArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? [NSDictionary] {
//                if let watchStyleString = jsonDictionaryArray.first?["watchUIStyle"] as? String {
//                    if let interfaceState = CorrectWatchInterface.interfaceStateFromString(watchStyleString) {
//                        self.defaultsManager.correctWatchInterface = interfaceState
//                    }
//                }
//            }
//        }
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //Crashlytics.sharedInstance().crash()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

