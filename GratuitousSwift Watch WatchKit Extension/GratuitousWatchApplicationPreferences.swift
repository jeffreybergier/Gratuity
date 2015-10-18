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
    private var _preferences: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk() {
        didSet {
            self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(_preferences)
        }
    }
    var preferences: GratuitousUserDefaults {
        return _preferences
    }
    var preferencesSetLocally: GratuitousUserDefaults {
        get { return _preferences }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesNotificationManager.postNotificationsForLocallyChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    var preferencesSetRemotely: GratuitousUserDefaults {
        get { return _preferences }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesNotificationManager.postNotificationsForRemoteChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    
    let preferencesDiskManager = GratuitousUserDefaultsDiskManager()
    let preferencesNotificationManager = GratuitousDefaultsObserver()
    let watchConnectivityManager = JSBWatchConnectivityManager()
    let customiOSCommunicationManager = GratuitousWatchConnectivityManager()
    
    init() {
        self.watchConnectivityManager.contextDelegate = self.customiOSCommunicationManager
        self.watchConnectivityManager.fileTransferDelegate = self.customiOSCommunicationManager
    }
}