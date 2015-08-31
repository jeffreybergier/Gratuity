//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import WatchConnectivity
//import Fabric
//import Crashlytics

@UIApplicationMain
class GratuitousAppDelegate: UIResponder, UIApplicationDelegate, WatchConnectivityDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let defaultsManager = GratuitousPropertyListPreferences()
    private let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    private let currencyFormatter = GratuitousCurrencyFormatter()
    private let watchManager = GratuitousiOSWatchConnectivityManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
//        Fabric.with([Crashlytics()])
        
        self.watchManager.watchConnectivityDelegate = self
        
        //initialize the view controller from the storyboard
        let tipViewController = self.storyboard.instantiateInitialViewController()
        
        //configure the window
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        self.window?.rootViewController = tipViewController
        self.window?.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        self.window?.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.makeKeyAndVisible() //if window is not initialized yet, this should crash.
    
        return true
    }
    
    func generateNewCurrencySymbols() -> (url: NSURL, currencyCode: String) {
        //let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
        let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
        //let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
        
        let imageGenerator = GratuitousLabelImageGenerator()
        var images = [UIImage]()
        for i in 1 ... 250 {
            let string = NSAttributedString(string: self.currencyFormatter.currencyFormattedString(i), attributes: valueTextAttributes)
            if let image = imageGenerator.generateImageForAttributedString(string) {
                images += [image]
            }
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(images)
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let dataURL = documentsURL.URLByAppendingPathComponent("imageArray.data")
        data.writeToURL(dataURL, atomically: true)
        return (dataURL, self.currencyFormatter.currencyCode)
    }
    
//    func applicationWillResignActive(application: UIApplication) {
//        self.defaultsManager.writeToDisk()
//    }
//    
//    func applicationWillTerminate(application: UIApplication) {
//        self.defaultsManager.writeToDisk()
//    }
}

