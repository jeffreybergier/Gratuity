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
class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let dataSource = GratuitousiOSDataSource(respondToNotifications: true)
    private let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
//        Fabric.with([Crashlytics()])
                
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
}

