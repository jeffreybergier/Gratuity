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
    var description: String { return "GratuitousUserDefaults Manager: SuiteName: group.com.saturdayapps.Gratuity.storageGroup" }
    private let userDefaults = NSUserDefaults(suiteName: "group.com.saturdayapps.Gratuity.storageGroup") !! NSUserDefaults.standardUserDefaults()
    
    init() {
        var currentAppVersionEqualsDataVersionOnDisk = false
        let appVersionCurrent = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String !! "1.0"
        let appVersionOnDisk = self.userDefaults.objectForKey("appVersionString") as? String
        if let appVersionOnDisk = appVersionOnDisk {
            if appVersionOnDisk == appVersionCurrent {
                currentAppVersionEqualsDataVersionOnDisk = true
            }
        }
        if currentAppVersionEqualsDataVersionOnDisk == false {
            self.userDefaults.setObject(appVersionCurrent, forKey: "appVersionString")
            self.userDefaults.setInteger(25, forKey: "billIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: "overrideCurrencySymbol")
            self.userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
            self.userDefaults.setInteger(CorrectWatchInterface.ThreeButtonStepper.rawValue, forKey: "correctInterface")
            self.userDefaults.synchronize()
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
            self.userDefaults.setDouble(newValue, forKey: "suggestedTipPercentage")
            self.userDefaults.synchronize()
        }
        get {
            return self.userDefaults.doubleForKey("suggestedTipPercentage") !! 0.2
        }
    }
}
