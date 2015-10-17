//
//  GratuitousUserDefaults.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/14/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

struct GratuitousUserDefaults {
    var currencySymbolsNeeded: Bool
    var appVersionString: String
    var billIndexPathRow: Int
    var tipIndexPathRow: Int
    var overrideCurrencySymbol: CurrencySign
    var suggestedTipPercentage: Double
    var freshWatchAppInstall: Bool
    var splitBillPurchased: Bool
}

extension GratuitousUserDefaults: Equatable { }

func ==(lhs: GratuitousUserDefaults, rhs: GratuitousUserDefaults) -> Bool {
    if lhs.currencySymbolsNeeded == true || rhs.currencySymbolsNeeded == true {
        return false
    }
    return lhs.dictionaryCopyForKeys(.All) as NSDictionary == rhs.dictionaryCopyForKeys(.All) as NSDictionary
}

extension GratuitousUserDefaults {
    enum DictionaryCopyKeys {
        case All, WatchOnly
    }
    
    func dictionaryCopyForKeys(keys: DictionaryCopyKeys) -> [String : AnyObject] {
        var dictionary = [String : AnyObject]()
        switch keys {
        case .All:
            dictionary[Keys.appVersionString] = self.appVersionString
            dictionary[Keys.freshWatchAppInstall] = NSNumber(bool: self.freshWatchAppInstall)
            fallthrough
        case .WatchOnly:
            dictionary[Keys.billIndexPathRow] = NSNumber(integer: self.billIndexPathRow)
            dictionary[Keys.tipIndexPathRow] = NSNumber(integer: self.tipIndexPathRow)
            dictionary[Keys.overrideCurrencySymbol] = NSNumber(integer: self.overrideCurrencySymbol.rawValue)
            dictionary[Keys.suggestedTipPercentage] = NSNumber(double: self.suggestedTipPercentage)
            dictionary[Keys.splitBillPurchased] = NSNumber(bool: self.splitBillPurchased)
        }
        return dictionary
    }
}

extension GratuitousUserDefaults {

    init(dictionary: NSDictionary?, fallback: GratuitousUserDefaults) {
        // version 1.0 and 1.0.1 keys
        if let billIndexPathRow = dictionary?[Keys.billIndexPathRow] as? NSNumber {
            self.billIndexPathRow = billIndexPathRow.integerValue
        } else {
            self.billIndexPathRow = fallback.billIndexPathRow
        }
        if let tipIndexPathRow = dictionary?[Keys.tipIndexPathRow] as? NSNumber {
            self.tipIndexPathRow = tipIndexPathRow.integerValue
        } else {
            self.tipIndexPathRow = fallback.tipIndexPathRow
        }
        if let overrideCurrencySymbol = dictionary?[Keys.overrideCurrencySymbol] as? NSNumber,
            symbolEnum = CurrencySign(rawValue: overrideCurrencySymbol.integerValue) {
                self.overrideCurrencySymbol = symbolEnum
        } else {
            self.overrideCurrencySymbol = fallback.overrideCurrencySymbol
        }
        if let suggestedTipPercentage = dictionary?[Keys.suggestedTipPercentage] as? NSNumber {
            self.suggestedTipPercentage = suggestedTipPercentage.doubleValue
        } else {
            self.suggestedTipPercentage = fallback.suggestedTipPercentage
        }
        // version 1.1 keys
        if let appVersionString = dictionary?[Keys.appVersionString] as? String {
            self.appVersionString = appVersionString
        } else {
            self.appVersionString = fallback.appVersionString
        }
        // version 1.2 keys
        if let freshWatchAppInstall = dictionary?[Keys.freshWatchAppInstall] as? NSNumber {
            let value = freshWatchAppInstall.boolValue
            self.freshWatchAppInstall = value
        } else {
            self.freshWatchAppInstall = true
        }
        if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
            let value = splitBillPurchased.boolValue
            self.splitBillPurchased = value
        } else {
            splitBillPurchased = false
        }
        // ignored from disk version. Always set to false on load
        self.currencySymbolsNeeded = fallback.currencySymbolsNeeded
    }
    
    init(dictionary: NSDictionary?) {
        // version 1.0 and 1.0.1 keys
        if let billIndexPathRow = dictionary?[Keys.billIndexPathRow] as? NSNumber {
            self.billIndexPathRow = billIndexPathRow.integerValue
        } else {
            self.billIndexPathRow = 25
        }
        if let tipIndexPathRow = dictionary?[Keys.tipIndexPathRow] as? NSNumber {
            self.tipIndexPathRow = tipIndexPathRow.integerValue
        } else {
            self.tipIndexPathRow = 0
        }
        if let overrideCurrencySymbol = dictionary?[Keys.overrideCurrencySymbol] as? NSNumber,
            symbolEnum = CurrencySign(rawValue: overrideCurrencySymbol.integerValue) {
                self.overrideCurrencySymbol = symbolEnum
        } else {
            self.overrideCurrencySymbol = .Default
        }
        if let suggestedTipPercentage = dictionary?[Keys.suggestedTipPercentage] as? NSNumber {
            self.suggestedTipPercentage = suggestedTipPercentage.doubleValue
        } else {
            self.suggestedTipPercentage = 0.2
        }
        // version 1.1 keys
        if let appVersionString = dictionary?[Keys.appVersionString] as? String {
            self.appVersionString = appVersionString
        } else {
            self.appVersionString = "1.1.0"
        }
        // version 1.2 keys
        if let freshWatchAppInstall = dictionary?[Keys.freshWatchAppInstall] as? NSNumber {
            let value = freshWatchAppInstall.boolValue
            self.freshWatchAppInstall = value
        } else {
            self.freshWatchAppInstall = true
        }
        if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
            let value = splitBillPurchased.boolValue
            self.splitBillPurchased = value
        } else {
            splitBillPurchased = false
        }
        // ignored from disk version. Always set to false on load
        self.currencySymbolsNeeded = false
    }
}

extension GratuitousUserDefaults {
    struct Keys {
        static let localSuiteName = "group.com.saturdayapps.Gratuity.storageGroup"
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        
        // version 1.0 and 1.0.1 keys
        static let billIndexPathRow = "billIndexPathRow"
        static let tipIndexPathRow = "tipIndexPathRow"
        static let overrideCurrencySymbol = "overrideCurrencySymbol"
        static let suggestedTipPercentage = "suggestedTipPercentage"
        
        // version 1.1 keys
        static let appVersionString = "appVersionString"
        static let showTutorialAtLaunch = "showTutorialAtLaunch"
        static let watchInfoViewControllerShouldAppear = "watchInfoViewControllerShouldAppear"
        static let watchInfoViewControllerWasDismissed = "watchInfoViewControllerWasDismissed"
        
        // version 1.2 keys
        static let currencySymbolsNeeded = "currencySymbolsNeeded"
        static let freshWatchAppInstall = "freshWatchAppInstall"
        static let splitBillPurchased = "splitBillPurchased"
    }
}