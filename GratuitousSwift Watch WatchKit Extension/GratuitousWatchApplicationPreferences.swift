//
//  GratuitousWatchApplicationPreferences.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

class GratuitousWatchApplicationPreferences {
    
    static let sharedInstance = GratuitousWatchApplicationPreferences()
    
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
}