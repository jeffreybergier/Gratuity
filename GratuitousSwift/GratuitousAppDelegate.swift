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
import XCGLogger

@UIApplicationMain
final class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Required iOS Properties Properties
    var window: UIWindow?
    
    let log = XCGLogger.defaultInstance()
    
    // MARK: App Preferences Management Properties
    private var _preferences: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk() {
        didSet {
            self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(_preferences)
        }
    }
    var preferences: GratuitousUserDefaults {
        return _preferences
    }
    var preferencesSetLocally: GratuitousUserDefaults {
        get { return self.preferences }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesNotificationManager.postNotificationsForLocallyChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    var preferencesSetRemotely: GratuitousUserDefaults {
        get { return self.preferences }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesNotificationManager.postNotificationsForRemoteChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    
    private let preferencesDiskManager = GratuitousUserDefaultsDiskManager()
    private let preferencesNotificationManager = GratuitousDefaultsObserver()
    
    // MARK: State Restoration Properties
    let storyboard: UIStoryboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    let presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .Right, animate: false)
    let presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .Bottom, animate: false)
    
    // MARK: Watch Connectivity Properties
    let watchConnectivityManager: AnyObject? = {
        if #available(iOS 9, *) {
            return JSBWatchConnectivityManager()
        } else {
            return .None
        }
    }()
    private let customWatchCommunicationManager: AnyObject? = {
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
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.contextDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.messageDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
        }
        
        let purchaseManager = GratuitousPurchaseManager()
        self.preferencesSetLocally.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
        
        return true
    }
    
    // MARK: iOS App Going to the Background
    func applicationWillResignActive(application: UIApplication) {
        self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(self.preferences)
    }
}

