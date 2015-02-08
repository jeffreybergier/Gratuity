//
//  GratuitousUserDefaults.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/7/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaults {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    init() {
        if self.userDefaults.integerForKey("billIndexPathRow") == 0 {
            self.userDefaults.setInteger(26, forKey: "billIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            self.userDefaults.setInteger(CurrencySign.Default.rawValue, forKey: "overrideCurrencySymbol")
            self.userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
            self.userDefaults.synchronize()
        }
    }
    
    var billIndexPathRow: Int {
        set {
            self.userDefaults.setInteger(newValue, forKey: "billIndexPathRow")
            self.userDefaults.synchronize()
        }
        get {
            return self.userDefaults.integerForKey("billIndexPathRow") !! 26
        }
    }
    
    var tipIndexPathRow: Int {
        set {
            self.userDefaults.setInteger(newValue, forKey: "tipIndexPathRow")
            self.userDefaults.synchronize()
        }
        get {
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
