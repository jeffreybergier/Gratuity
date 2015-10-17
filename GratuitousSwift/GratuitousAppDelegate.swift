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
    private var _preferences: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk()
    var localPreferences: GratuitousUserDefaults {
        get {
            return _preferences
        }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesDiskManager.writeUserDefaultsToPreferencesFileWithRateLimit(newValue)
                self.preferencesNotificationManager.postNotificationsForLocallyChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    var remotePreferences: GratuitousUserDefaults {
        get {
            return _preferences
        }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesDiskManager.writeUserDefaultsToPreferencesFileWithRateLimit(newValue)
                self.preferencesNotificationManager.postNotificationsForRemoteChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    
    let preferencesDiskManager = GratuitousUserDefaultsDiskManager()
    let preferencesNotificationManager = GratuitousDefaultsObserver()
    
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
    let customWatchCommunicationManager: AnyObject? = {
        if #available(iOS 9, *) {
            return GratuitousiOSConnectivityManager()
        } else {
            return .None
        }
    }()
}

