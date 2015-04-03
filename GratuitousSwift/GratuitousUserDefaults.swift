    //
//  GratuitousUserDefaults.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/7/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaults: Printable {
    
    var description: String { return "GratuitousUserDefaults Manager: SuiteName: \(Keys.localSuiteName)" }
    private let userDefaults = NSUserDefaults(suiteName: Keys.localSuiteName) !! NSUserDefaults.standardUserDefaults()
    
    init() {
        //
        // configure the storage group appropriately so beta builds and store builds don't share storage
        //
        let appVersionCurrent = NSBundle.mainBundle().infoDictionary![Keys.CFBundleShortVersionString] as? String !! "1.0"
        if let appVersionOnDisk = self.userDefaults.objectForKey(Keys.appVersionString) as? String {
            if appVersionOnDisk != appVersionCurrent {
                // placeholder for future migration
            }
        } else {
            // might be a first run or might be upgrading from 1.0
            let standardUserDefaults = NSUserDefaults.standardUserDefaults()
            if standardUserDefaults.integerForKey(Keys.billIndexPathRow) != 0 {
                // means we're upgrading from 1.0
                self.startMigrationFromVersionOnePointZero(toVersion: appVersionCurrent)
            } else {
                // looks like a fresh install
                self.configureNewInstallWithCurrentAppVersion(appVersionCurrent)
            }
        }
    }
    
    private func startMigrationFromVersionOnePointZero(#toVersion: String) {
        NSLog("\(self): Looks like a an upgrade from 1.0: Setting defaults for new Keys")
        // first need to extract the settings from standardUserDefaults
        let standardUserDefaults = NSUserDefaults.standardUserDefaults()
        
        // get the settings
        let billIndexPathRow = standardUserDefaults.integerForKey(Keys.billIndexPathRow) - 1
        let tipIndexPathRow = standardUserDefaults.integerForKey(Keys.tipIndexPathRow) - 1
        let overrideCurrencySymbol = CurrencySign(rawValue: standardUserDefaults.integerForKey(Keys.overrideCurrencySymbol)) !! CurrencySign.Default
        let suggestedTipPercentage = standardUserDefaults.doubleForKey(Keys.suggestedTipPercentage)
        
        // then write them to the new userDefaults
        self.userDefaults.setInteger(billIndexPathRow, forKey: Keys.billIndexPathRow)
        self.userDefaults.setInteger(tipIndexPathRow, forKey: Keys.tipIndexPathRow)
        self.userDefaults.setInteger(overrideCurrencySymbol.rawValue, forKey: Keys.overrideCurrencySymbol)
        self.userDefaults.setDouble(suggestedTipPercentage, forKey: Keys.suggestedTipPercentage)
        
        // insert all the new data that was started after version 1.0
        self.userDefaults.setObject(toVersion, forKey: Keys.appVersionString)
        self.userDefaults.setBool(true, forKey: Keys.showTutorialAtLaunch)
        self.userDefaults.synchronize()
    }
    
    private func configureNewInstallWithCurrentAppVersion(currentAppVersion: String) {
        NSLog("\(self): Looks like a first run or a new version: Writing defaults to disk.")
        self.userDefaults.setObject(currentAppVersion, forKey: Keys.appVersionString)
        self.userDefaults.setInteger(25, forKey: Keys.billIndexPathRow)
        self.userDefaults.setInteger(0, forKey: Keys.tipIndexPathRow)
        self.userDefaults.setBool(true, forKey: Keys.showTutorialAtLaunch)
        self.userDefaults.setDouble(0.2, forKey: Keys.suggestedTipPercentage)
        self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: Keys.overrideCurrencySymbol)
        self.userDefaults.synchronize()
    }
    
    private var _showTutorialAtLaunch: Bool?
    var showTutorialAtLaunch: Bool {
        set {
            _showTutorialAtLaunch = newValue
            self.userDefaults.setBool(newValue, forKey: Keys.showTutorialAtLaunch)
            self.userDefaults.synchronize()
        }
        get {
            if let showTutorialAtLaunch = _showTutorialAtLaunch {
                return showTutorialAtLaunch
            } else {
                return self.userDefaults.boolForKey(Keys.showTutorialAtLaunch) !! true
            }
        }
    }
    
    private var _billIndexPathRow: Int?
    var billIndexPathRow: Int {
        set {
            // first set the tip to 0 so it performs default behaviors
            self.tipIndexPathRow = 0

            // then update instance variables and user defaults
            _billIndexPathRow = newValue
            self.userDefaults.setInteger(newValue, forKey: Keys.billIndexPathRow)
            self.userDefaults.synchronize()
        }
        get {
            if let billIndexPathRow = _billIndexPathRow {
                return billIndexPathRow
            } else {
                return self.userDefaults.integerForKey(Keys.billIndexPathRow) !! 26
            }
        }
    }
    
    private var _tipIndexPathRow: Int?
    var tipIndexPathRow: Int {
        set {
            _tipIndexPathRow = newValue
            self.userDefaults.setInteger(newValue, forKey: Keys.tipIndexPathRow)
            self.userDefaults.synchronize()
        }
        get {
            if let tipIndexPathRow = _tipIndexPathRow {
                return tipIndexPathRow
            } else {
                return self.userDefaults.integerForKey(Keys.tipIndexPathRow) !! 0
            }
        }
    }
    
    private var _overrideCurrencySymbol: CurrencySign?
    var overrideCurrencySymbol: CurrencySign {
        set {
            _overrideCurrencySymbol = newValue
            self.userDefaults.setInteger(newValue.rawValue, forKey: Keys.overrideCurrencySymbol)
            self.userDefaults.synchronize()
        }
        get {
            if let overrideCurrencySymbol = _overrideCurrencySymbol {
                return overrideCurrencySymbol
            } else {
                return CurrencySign(rawValue: self.userDefaults.integerForKey(Keys.overrideCurrencySymbol)) !! CurrencySign.Default
            }
        }
    }
    
    private var _suggestedTipPercentage: Double?
    var suggestedTipPercentage: Double {
        set {
            _suggestedTipPercentage = newValue
            self.userDefaults.setDouble(newValue, forKey: Keys.suggestedTipPercentage)
            self.userDefaults.synchronize()
        }
        get {
            if let suggestedTipPercentage = _suggestedTipPercentage {
                return suggestedTipPercentage
            } else {
                return self.userDefaults.doubleForKey(Keys.suggestedTipPercentage) !! 0.2
            }
        }
    }
    
    class func watchUIURL() -> NSURL {
        return NSURL(string: "http://www.saturdayapps.com/gratuity/watchUI.json")!
    }
    
    private struct Keys {
        #if LOCAL // Local = Not an App Store Bundle Identifier
        static let localSuiteName = "group.com.saturdayapps.Gratuity.local.storageGroup"
        #else
        static let localSuiteName = "group.com.saturdayapps.Gratuity.storageGroup"
        #endif
        
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        
        // version 1.0 and 1.1 keys
        static let billIndexPathRow = "billIndexPathRow"
        static let tipIndexPathRow = "tipIndexPathRow"
        static let overrideCurrencySymbol = "overrideCurrencySymbol"
        static let suggestedTipPercentage = "suggestedTipPercentage"
        
        // version 1.2 keys
        static let appVersionString = "appVersionString"
        static let showTutorialAtLaunch = "showTutorialAtLaunch"
    }
}
