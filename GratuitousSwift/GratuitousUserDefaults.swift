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
    
    var contextDictionaryCopy: [String : AnyObject] {
        return [
            Keys.billIndexPathRow : NSNumber(integer: self.billIndexPathRow),
            Keys.tipIndexPathRow : NSNumber(integer: self.tipIndexPathRow),
            Keys.overrideCurrencySymbol : NSNumber(integer: self.overrideCurrencySymbol.rawValue),
            Keys.suggestedTipPercentage : NSNumber(double: self.suggestedTipPercentage),
            Keys.splitBillPurchased : NSNumber(bool: self.splitBillPurchased)
        ]
    }
    
    var saveToDiskDictionaryCopy: [String : AnyObject] {
        return [
            Keys.billIndexPathRow : NSNumber(integer: self.billIndexPathRow),
            Keys.tipIndexPathRow : NSNumber(integer: self.tipIndexPathRow),
            Keys.overrideCurrencySymbol : NSNumber(integer: self.overrideCurrencySymbol.rawValue),
            Keys.suggestedTipPercentage : NSNumber(double: self.suggestedTipPercentage),
            Keys.appVersionString : self.appVersionString,
            Keys.freshWatchAppInstall : NSNumber(bool: self.freshWatchAppInstall),
            Keys.splitBillPurchased : NSNumber(bool: self.splitBillPurchased)
        ]
    }
    
    var saveToDiskDataCopy: NSData? {
        let dictionary = self.saveToDiskDictionaryCopy
        return try? NSPropertyListSerialization.dataWithPropertyList(dictionary, format: .XMLFormat_v1_0, options: 0)
    }
    
    static func newFromDisk() -> GratuitousUserDefaults {
        let plistURL = GratuitousUserDefaults.locationOnDisk
        
        let plistDictionary: NSDictionary?
        do {
            let plistData = try NSData(contentsOfURL: plistURL, options: .DataReadingMappedIfSafe)
            try plistDictionary = NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: nil) as? NSDictionary
        } catch {
            NSLog("GratuitousPropertyListPreferences: Failed to read existing preferences from disk: \(error)")
            plistDictionary = .None
        }
        return GratuitousUserDefaults(dictionary: plistDictionary)
    }
    
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
    
    struct Keys {
        #if LOCAL // Local = Not an App Store Bundle Identifier
        static let localSuiteName = "group.com.saturdayapps.Gratuity.local.storageGroup"
        #else
        static let localSuiteName = "group.com.saturdayapps.Gratuity.storageGroup"
        #endif
        
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        static let propertyListFileName = "com.saturdayapps.gratuity.plist"
        
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
    
    static var preferencesURL: NSURL {
        let fileManager = NSFileManager.defaultManager()
        let libraryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
        let preferencesURL = libraryURL.URLByAppendingPathComponent("Preferences")
        return preferencesURL
    }
    
    static var locationOnDisk: NSURL {
        return GratuitousUserDefaults.preferencesURL.URLByAppendingPathComponent(Keys.propertyListFileName)
    }
}