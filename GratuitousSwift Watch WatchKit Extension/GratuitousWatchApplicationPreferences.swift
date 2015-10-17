//
//  GratuitousWatchApplicationPreferences.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity
import XCGLogger

class GratuitousWatchApplicationPreferences {
    
    static let sharedInstance = GratuitousWatchApplicationPreferences()
    
    private let log = XCGLogger.defaultInstance()
    
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
    let watchConnectivityManager = JSBWatchConnectivityManager()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteContextUpdateNeeded:", name: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded, object: .None)
        self.watchConnectivityManager.contextDelegate = self
    }
    
    var remoteUpdateRateLimiterSet = false
}

extension GratuitousWatchApplicationPreferences {
    @objc private func remoteContextUpdateNeeded(notification: NSNotification?) {
        if self.remoteUpdateRateLimiterSet == false {
            self.remoteUpdateRateLimiterSet = true
            NSTimer.scheduleWithDelay(3.0) { timer in
                self.remoteUpdateRateLimiterSet = false
                self.updateRemoteContext(notification)
            }
        }
    }
    
    private func updateRemoteContext(notification: NSNotification?) {
        let context = notification?.userInfo as? [String : AnyObject] !! self.localPreferences.dictionaryCopyForKeys(.WatchOnly)
        do {
            try self.watchConnectivityManager.session?.updateApplicationContext(context)
        } catch {
            self.log.error("Updating Remote Context: \(context) Failed with Error: \(error)")
        }
    }
}

extension GratuitousWatchApplicationPreferences: JSBWatchConnectivityContextDelegate {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.remotePreferences = GratuitousUserDefaults(dictionary: applicationContext, fallback: self.remotePreferences)
    }
}