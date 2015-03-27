    //
//  GratuitousUserDefaults.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/7/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaults: Printable {
    
    var description: String { return "GratuitousUserDefaults Manager: SuiteName: \(self.suiteName)" }
    private let suiteName: String
    private let userDefaults: NSUserDefaults
    
    init() {
        //
        // configure the storage group appropriately so beta builds and store builds don't share storage
        //
        #if LOCAL // Local = Not an App Store Bundle Identifier
        let localSuiteName = "group.com.saturdayapps.Gratuity.local.storageGroup"
        #else
        let localSuiteName = "group.com.saturdayapps.Gratuity.storageGroup"
        #endif
        
        self.userDefaults = NSUserDefaults(suiteName: localSuiteName) !! NSUserDefaults.standardUserDefaults()
        self.suiteName = localSuiteName
        
        let appVersionCurrent = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String !! "1.0"
        let appVersionOnDisk = self.userDefaults.objectForKey("appVersionString") as? String
        
        if let appVersionOnDisk = appVersionOnDisk {
            self.startMigration(fromVersion: appVersionOnDisk, toVersion: appVersionCurrent)
        } else {
            let oldWayOfCheckingIfDefaultsSet = self.userDefaults.integerForKey("billIndexPathRow")
            if oldWayOfCheckingIfDefaultsSet == 0 { // 0 is what is returned when nothing has been set for the key
                self.configureNewInstallWithCurrentAppVersion(appVersionCurrent)
            } else {
                self.startMigration(fromVersion: "1.0", toVersion: appVersionCurrent)
            }
        }
    }
    
    private func startMigration(#fromVersion: String?, toVersion: String?) {
        if let fromVersion = fromVersion {
            if let toVersion = toVersion {
                if fromVersion == "1.0" {
                    NSLog("\(self): Looks like a an upgrade from 1.0: Setting defaults for new Keys")
                    // insert all the new data that was started after version 1.0
                    self.userDefaults.setObject(toVersion, forKey: "appVersionString")
                    self.userDefaults.setInteger(201, forKey: "numberOfRowsInBillTableForWatch")
                    self.userDefaults.setInteger(0, forKey: "watchAppRunCount")
                    self.userDefaults.setBool(true, forKey: "watchAppRunCountShouldBeIncremented")
                    self.userDefaults.setInteger(CorrectWatchInterface.CrownScroller.rawValue, forKey: "correctInterface")
                    self.userDefaults.synchronize()
                }
            }
        }
    }
    
    private func configureNewInstallWithCurrentAppVersion(appVersion: String) {
        NSLog("\(self): Looks like a first run or a new version: Writing defaults to disk.")
        self.userDefaults.setObject(appVersion, forKey: "appVersionString")
        self.userDefaults.setInteger(25, forKey: "billIndexPathRow")
        self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
        self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: "overrideCurrencySymbol")
        self.userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
        self.userDefaults.setInteger(201, forKey: "numberOfRowsInBillTableForWatch")
        self.userDefaults.setInteger(0, forKey: "watchAppRunCount")
        self.userDefaults.setBool(true, forKey: "watchAppRunCountShouldBeIncremented")
        self.userDefaults.setInteger(CorrectWatchInterface.CrownScroller.rawValue, forKey: "correctInterface")
        self.userDefaults.synchronize()
    }
    
    private var _watchAppRunCountShouldBeIncremented: Bool?
    var watchAppRunCountShouldBeIncremented: Bool {
        set {
            _watchAppRunCountShouldBeIncremented = newValue
            self.userDefaults.setBool(newValue, forKey: "watchAppRunCountShouldBeIncremented")
            self.userDefaults.synchronize()
        }
        get {
            if let watchAppRunCountShouldBeIncremented = _watchAppRunCountShouldBeIncremented {
                return watchAppRunCountShouldBeIncremented
            } else {
                return self.userDefaults.boolForKey("watchAppRunCountShouldBeIncremented") !! true
            }
        }
    }
    
    private var _watchAppRunCount: Int?
    var watchAppRunCount: Int {
        set {
            _watchAppRunCount = newValue
            self.userDefaults.setInteger(newValue, forKey: "watchAppRunCount")
            self.userDefaults.synchronize()
        }
        get {
            if let watchAppRunCount = _watchAppRunCount {
                return watchAppRunCount
            } else {
                return self.userDefaults.integerForKey("watchAppRunCount") !! 0
            }
        }
    }
    
    private var _billIndexPathRow: Int?
    var billIndexPathRow: Int {
        set {
            _billIndexPathRow = newValue
            self.tipIndexPathRow = 0
            self.userDefaults.setInteger(newValue, forKey: "billIndexPathRow")
            self.userDefaults.synchronize()
        }
        get {
            if let billIndexPathRow = _billIndexPathRow {
                return billIndexPathRow
            } else {
                return self.userDefaults.integerForKey("billIndexPathRow") !! 26
            }
        }
    }
    
    private var _numberOfRowsInBillTableForWatch: Int?
    var numberOfRowsInBillTableForWatch: Int {
        set {
            _numberOfRowsInBillTableForWatch = newValue
            self.userDefaults.setInteger(newValue, forKey: "numberOfRowsInBillTableForWatch")
            self.userDefaults.synchronize()
        }
        get {
            if let numberOfRowsInBillTableForWatch = _numberOfRowsInBillTableForWatch {
                return numberOfRowsInBillTableForWatch
            } else {
                return self.userDefaults.integerForKey("numberOfRowsInBillTableForWatch") !! 201
            }
        }
    }
    
    private var _tipIndexPathRow: Int?
    var tipIndexPathRow: Int {
        set {
            _tipIndexPathRow = newValue
            self.userDefaults.setInteger(newValue, forKey: "tipIndexPathRow")
            self.userDefaults.synchronize()
        }
        get {
            if let tipIndexPathRow = _tipIndexPathRow {
                return tipIndexPathRow
            } else {
                return self.userDefaults.integerForKey("tipIndexPathRow") !! 0
            }
        }
    }
    
    private var _overrideCurrencySymbol: CurrencySign?
    var overrideCurrencySymbol: CurrencySign {
        set {
            _overrideCurrencySymbol = newValue
            self.userDefaults.setInteger(newValue.rawValue, forKey: "overrideCurrencySymbol")
            self.userDefaults.synchronize()
        }
        get {
            if let overrideCurrencySymbol = _overrideCurrencySymbol {
                return overrideCurrencySymbol
            } else {
                return CurrencySign(rawValue: self.userDefaults.integerForKey("overrideCurrencySymbol")) !! CurrencySign.Default
            }
        }
    }
    
    private var _correctWatchInterface: CorrectWatchInterface?
    var correctWatchInterface: CorrectWatchInterface {
        set {
            _correctWatchInterface = newValue
            self.userDefaults.setInteger(newValue.rawValue, forKey: "correctInterface")
            self.userDefaults.synchronize()
        }
        get {
            if let correctWatchInterface = _correctWatchInterface {
                return correctWatchInterface
            } else {
                return CorrectWatchInterface(rawValue: self.userDefaults.integerForKey("correctInterface")) !! CorrectWatchInterface.CrownScroller
            }
        }
    }
    
    private var _suggestedTipPercentage: Double?
    var suggestedTipPercentage: Double {
        set {
            _suggestedTipPercentage = newValue
            self.userDefaults.setDouble(newValue, forKey: "suggestedTipPercentage")
            self.userDefaults.synchronize()
        }
        get {
            if let suggestedTipPercentage = _suggestedTipPercentage {
                return suggestedTipPercentage
            } else {
                return self.userDefaults.doubleForKey("suggestedTipPercentage") !! 0.2
            }
        }
    }
    
    class func watchUIURL() -> NSURL {
        return NSURL(string: "http://www.saturdayapps.com/gratuity/watchUI.json")!
    }
}
