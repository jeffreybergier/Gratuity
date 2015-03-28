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
        self.userDefaults.setInteger(0, forKey: Keys.watchAppRunCount)
        self.userDefaults.setBool(true, forKey: Keys.watchAppRunCountShouldBeIncremented)
        self.userDefaults.setInteger(201, forKey: Keys.numberOfRowsInBillTableForWatch)
        self.userDefaults.setInteger(CorrectWatchInterface.CrownScroller.rawValue, forKey: Keys.correctWatchInterface)
        self.userDefaults.synchronize()
    }
    
    private func configureNewInstallWithCurrentAppVersion(currentAppVersion: String) {
        NSLog("\(self): Looks like a first run or a new version: Writing defaults to disk.")
        self.userDefaults.setObject(currentAppVersion, forKey: Keys.appVersionString)
        self.userDefaults.setInteger(25, forKey: Keys.billIndexPathRow)
        self.userDefaults.setInteger(0, forKey: Keys.tipIndexPathRow)
        self.userDefaults.setInteger(0, forKey: Keys.watchAppRunCount)
        self.userDefaults.setDouble(0.2, forKey: Keys.suggestedTipPercentage)
        self.userDefaults.setInteger(201, forKey: Keys.numberOfRowsInBillTableForWatch)
        self.userDefaults.setBool(true, forKey: Keys.watchAppRunCountShouldBeIncremented)
        self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: Keys.overrideCurrencySymbol)
        self.userDefaults.setInteger(CorrectWatchInterface.CrownScroller.rawValue, forKey: Keys.correctWatchInterface)
        self.userDefaults.synchronize()
    }
    
    private var _watchAppRunCountShouldBeIncremented: Bool?
    var watchAppRunCountShouldBeIncremented: Bool {
        set {
            _watchAppRunCountShouldBeIncremented = newValue
            self.userDefaults.setBool(newValue, forKey: Keys.watchAppRunCountShouldBeIncremented)
            self.userDefaults.synchronize()
        }
        get {
            if let watchAppRunCountShouldBeIncremented = _watchAppRunCountShouldBeIncremented {
                return watchAppRunCountShouldBeIncremented
            } else {
                return self.userDefaults.boolForKey(Keys.watchAppRunCountShouldBeIncremented) !! true
            }
        }
    }
    
    private var _watchAppRunCount: Int?
    var watchAppRunCount: Int {
        set {
            _watchAppRunCount = newValue
            self.userDefaults.setInteger(newValue, forKey: Keys.watchAppRunCount)
            self.userDefaults.synchronize()
        }
        get {
            if let watchAppRunCount = _watchAppRunCount {
                return watchAppRunCount
            } else {
                return self.userDefaults.integerForKey(Keys.watchAppRunCount) !! 0
            }
        }
    }
    
    private var _billIndexPathRow: Int?
    var billIndexPathRow: Int {
        set {
            _billIndexPathRow = newValue
            self.userDefaults.setInteger(0, forKey: Keys.tipIndexPathRow) // save a synchronize by not using //self.tipIndexPathRow = 0
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
    
    private var _numberOfRowsInBillTableForWatch: Int?
    var numberOfRowsInBillTableForWatch: Int {
        set {
            _numberOfRowsInBillTableForWatch = newValue
            self.userDefaults.setInteger(newValue, forKey: Keys.numberOfRowsInBillTableForWatch)
            self.userDefaults.synchronize()
        }
        get {
            if let numberOfRowsInBillTableForWatch = _numberOfRowsInBillTableForWatch {
                return numberOfRowsInBillTableForWatch
            } else {
                return self.userDefaults.integerForKey(Keys.numberOfRowsInBillTableForWatch) !! 201
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
    
    private var _correctWatchInterface: CorrectWatchInterface?
    var correctWatchInterface: CorrectWatchInterface {
        set {
            _correctWatchInterface = newValue
            self.userDefaults.setInteger(newValue.rawValue, forKey: Keys.correctWatchInterface)
            self.userDefaults.synchronize()
        }
        get {
            if let correctWatchInterface = _correctWatchInterface {
                return correctWatchInterface
            } else {
                return CorrectWatchInterface(rawValue: self.userDefaults.integerForKey(Keys.correctWatchInterface)) !! CorrectWatchInterface.CrownScroller
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
        static let watchAppRunCount = "watchAppRunCount"
        static let correctWatchInterface = "correctWatchInterface"
        static let numberOfRowsInBillTableForWatch = "numberOfRowsInBillTableForWatch"
        static let watchAppRunCountShouldBeIncremented = "watchAppRunCountShouldBeIncremented"
    }
}
