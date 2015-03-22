    //
//  GratuitousUserDefaults.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/7/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaults: Printable {
    
    class func watchUIURL() -> NSURL {
        return NSURL(string: "http://www.saturdayapps.com/gratuity/watchUI.json")!
    }
    
    var description: String { return "GratuitousUserDefaults Manager: SuiteName: \(self.suiteName)" }
    private let userDefaults: NSUserDefaults
    private let suiteName: String
    
    init() {
        #if LOCAL
            let localSuiteName = "group.com.saturdayapps.Gratuity.local.storageGroup"
        #else
            let localSuiteName = "group.com.saturdayapps.Gratuity.storageGroup"
        #endif
        self.userDefaults = NSUserDefaults(suiteName: localSuiteName) !! NSUserDefaults.standardUserDefaults()
        self.suiteName = localSuiteName
        
        var currentAppVersionEqualsDataVersionOnDisk = false
        let appVersionCurrent = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String !! "1.0"
        let appVersionOnDisk = self.userDefaults.objectForKey("appVersionString") as? String
        if let appVersionOnDisk = appVersionOnDisk {
            if appVersionOnDisk == appVersionCurrent {
                currentAppVersionEqualsDataVersionOnDisk = true
            }
        }
        if currentAppVersionEqualsDataVersionOnDisk == false {
            NSLog("\(self): Looks like a first run or a new version: Writing defaults to disk.")
            self.userDefaults.setObject(appVersionCurrent, forKey: "appVersionString")
            self.userDefaults.setInteger(25, forKey: "billIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: "overrideCurrencySymbol")
            self.userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
            self.userDefaults.setInteger(201, forKey: "numberOfRowsInBillTableForWatch")
            self.userDefaults.setInteger(0, forKey: "watchAppRunCount")
            self.userDefaults.setBool(true, forKey: "watchAppRunCountShouldBeIncremented")
            self.userDefaults.setInteger(CorrectWatchInterface.CrownScrollInfinite.rawValue, forKey: "correctInterface")
            self.userDefaults.synchronize()
        } else {
            self.userDefaults.setBool(true, forKey: "watchAppRunCountShouldBeIncremented")
        }
    }
    
    var watchAppRunCountShouldBeIncremented: Bool {
        set {
            println("wrote should be incremented to disk: \(newValue)")
            self.userDefaults.setBool(newValue, forKey: "watchAppRunCountShouldBeIncremented")
            self.userDefaults.synchronize()
        }
        get {
            let shouldBeIncremented = self.userDefaults.boolForKey("watchAppRunCountShouldBeIncremented") !! true
            println("read should be incremented: \(shouldBeIncremented) from disk")
            return self.userDefaults.boolForKey("watchAppRunCountShouldBeIncremented") !! true
        }
    }
    
    var watchAppRunCount: Int {
        set {
            println("wrote runcount to disk: \(newValue)")
            self.userDefaults.setInteger(newValue, forKey: "watchAppRunCount")
            self.userDefaults.synchronize()
        }
        get {
            let runcount = self.userDefaults.integerForKey("watchAppRunCount") !! 0
            println("read runcount \(runcount) from disk")
            return self.userDefaults.integerForKey("watchAppRunCount") !! 0
        }
    }
    
    var billIndexPathRow: Int {
        set {
            self.userDefaults.setInteger(newValue, forKey: "billIndexPathRow")
            println("Writing Bill \(newValue) to Disk")
            self.userDefaults.synchronize()
        }
        get {
            let diskValue = self.userDefaults.integerForKey("billIndexPathRow") !! 26
            println("Reading Bill \(diskValue) from Disk")
            return self.userDefaults.integerForKey("billIndexPathRow") !! 26
        }
    }
    
    var numberOfRowsInBillTableForWatch: Int {
        set {
            self.userDefaults.setInteger(newValue, forKey: "numberOfRowsInBillTableForWatch")
            self.userDefaults.synchronize()
        }
        get {
            return self.userDefaults.integerForKey("numberOfRowsInBillTableForWatch") !! 201
        }
    }
    
    var tipIndexPathRow: Int {
        set {
            println("Writing Tip \(newValue) to Disk")
            self.userDefaults.setInteger(newValue, forKey: "tipIndexPathRow")
            self.userDefaults.synchronize()
        }
        get {
            let diskValue = self.userDefaults.integerForKey("tipIndexPathRow") !! 0
            println("Reading Tip \(diskValue) from Disk")
            return self.userDefaults.integerForKey("tipIndexPathRow") !! 0
        }
    }
    
    var overrideCurrencySymbol: CurrencySign {
        set {
            self.userDefaults.setInteger(newValue.rawValue, forKey: "overrideCurrencySymbol")
            self.userDefaults.synchronize()
        }
        get {
            return CurrencySign(rawValue: self.userDefaults.integerForKey("overrideCurrencySymbol")) !! CurrencySign.Default
        }
    }
    
    var correctWatchInterface: CorrectWatchInterface {
        get {
            return CorrectWatchInterface(rawValue: self.userDefaults.integerForKey("correctInterface")) !! CorrectWatchInterface.CrownScrollInfinite
        }
        set {
            self.userDefaults.setInteger(newValue.rawValue, forKey: "correctInterface")
        }
    }
    
    var suggestedTipPercentage: Double {
        set {
            println("writing suggested tip percentage to disk \(newValue)")
            self.userDefaults.setDouble(newValue, forKey: "suggestedTipPercentage")
            self.userDefaults.synchronize()
        }
        get {
            let value = self.userDefaults.doubleForKey("suggestedTipPercentage") !! 0.2
            println("reading suggested tip percentage from disk \(value)")
            return self.userDefaults.doubleForKey("suggestedTipPercentage") !! 0.2
        }
    }
}
