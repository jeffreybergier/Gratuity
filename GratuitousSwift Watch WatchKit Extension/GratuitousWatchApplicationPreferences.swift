//
//  GratuitousWatchApplicationPreferences.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

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
        self.watchConnectivityManager.fileTransferReceiverDelegate = self.customiOSCommunicationManager
    }
}

struct Calculations {
    var tipAmount: Int
    var billAmount: Int
    var tipPercentage: Int
    var totalAmount: Int
    
    init(preferences: GratuitousUserDefaults) {
        let billAmount = preferences.billIndexPathRow
        let tipAmount: Int
        if preferences.tipIndexPathRow > 0 {
            tipAmount = preferences.tipIndexPathRow
        } else {
            tipAmount = Int(round(Double(billAmount) * preferences.suggestedTipPercentage))
        }
        
        let tipPercentage = Int(round((Double(tipAmount) / Double(billAmount)) * 100))
        
        self.tipPercentage = tipPercentage
        self.tipAmount = tipAmount
        self.billAmount = billAmount
        self.totalAmount = billAmount + tipAmount
    }
}