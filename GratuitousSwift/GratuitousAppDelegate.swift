//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import WatchConnectivity
import Fabric
import Crashlytics

@UIApplicationMain
final class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Required iOS Properties Properties
    var window: UIWindow?
    
    // MARK: App Preferences Management Properties
    var defaultsManager: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk() {
        didSet {
            if oldValue != self.defaultsManager {
                self.defaultsDiskManager.writeUserDefaultsToPreferencesFile(self.defaultsManager)
                self.defaultsNotificationManager.postNotificationsForChangedDefaults(old: oldValue, new: self.defaultsManager)
            }
        }
    }
    private let defaultsDiskManager = GratuitousUserDefaultsDiskManager()
    private let defaultsNotificationManager = GratuitousDefaultsObserver()
    
    // MARK: State Restoration Properties
    let storyboard: UIStoryboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    let presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .Right, animate: false)
    let presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .Bottom, animate: false)
    
    // MARK: Watch Connectivity Properties
    let watchConnectivityManager: AnyObject? = {
        if #available(iOS 9, *) {
            return GratuitousiOSConnectivityManager()
        } else {
            return .None
        }
    }()
    
    // MARK: iOS App Launch
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
        //Fabric.with([Crashlytics()])
        
        self.window!.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        
        if #available(iOS 9, *) {
            self.transferBulkCurrencySymbolsIfNeeded()
        }
        
        let purchaseManager = GratuitousPurchaseManager()
        self.defaultsManager.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
        
        return true
    }
    
    // MARK: iOS App Going to the Background
    func applicationWillResignActive(application: UIApplication) {
        self.defaultsDiskManager.writeUserDefaultsToPreferencesFile(self.defaultsManager)
    }
}

