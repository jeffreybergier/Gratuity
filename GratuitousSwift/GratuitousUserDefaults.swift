//
//  GratuitousUserDefaults.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/7/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaults: Printable {
    
    var description: String { return "GratuitousUserDefaults Manager: SuiteName: group.com.saturdayapps.Gratuity.storageGroup" }
    
    private let userDefaults = NSUserDefaults(suiteName: "group.com.saturdayapps.Gratuity.storageGroup") !! NSUserDefaults.standardUserDefaults()
    
    init() {
        if self.userDefaults.integerForKey("billIndexPathRow") == 0 {
            self.userDefaults.setInteger(26, forKey: "billIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: "overrideCurrencySymbol")
            self.userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
            self.userDefaults.setInteger(InterfaceState.CrownScrollInfinite.rawValue, forKey: "correctInterface")
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
    
    var correctInterface: InterfaceState {
        get {
            if let correctInterface = InterfaceState(rawValue: self.userDefaults.integerForKey("correctInterface")) {
                return correctInterface
            } else {
                return InterfaceState.CrownScrollInfinite
            }
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
