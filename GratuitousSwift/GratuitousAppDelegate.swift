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
    var window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //crashlytics intializer
        Fabric.with([Crashlytics()])
        
        //prepare nsuserdefaults
        self.prepareUserDefaults()
        
        //initialize the view controller from the storyboard
        let tipViewController = self.storyboard.instantiateInitialViewController() as TipViewController
        
        //configure the window
        self.window.rootViewController = tipViewController
        self.window.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        self.window.tintColor = GratuitousUIConstant.lightTextColor()
        self.window.makeKeyAndVisible()
        
        return true
    }
    
    func prepareUserDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.integerForKey("billIndexPathRow") == 0 {
            userDefaults.setInteger(19, forKey: "billIndexPathRow")
            userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: "overrideCurrencySymbol")
            userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
            userDefaults.synchronize()
        }
    }

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

