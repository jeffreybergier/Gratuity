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
    var splitBillPurchased: Bool
    var lastLocation: JSBIPLocation?
}

extension GratuitousUserDefaults: Equatable { }

func ==(lhs: GratuitousUserDefaults, rhs: GratuitousUserDefaults) -> Bool {
    return lhs.dictionaryCopyForKeys(.ForCurrencySymbolsNeeded) as NSDictionary == rhs.dictionaryCopyForKeys(.ForCurrencySymbolsNeeded) as NSDictionary
}

extension GratuitousUserDefaults {
    enum DictionaryCopyKeys {
        case ForCurrencySymbolsNeeded, ForWatch, ForDisk
    }
    
    func dictionaryCopyForKeys(keys: DictionaryCopyKeys) -> [String : AnyObject] {
        var dictionary = [String : AnyObject]()
        switch keys {
        case .ForCurrencySymbolsNeeded:
            dictionary[Keys.currencySymbolsNeeded] = self.currencySymbolsNeeded
            fallthrough
        case .ForDisk:
            dictionary[Keys.appVersionString] = self.appVersionString
            dictionary[Keys.locationZipCode] = self.lastLocation?.zipCode
            dictionary[Keys.locationCity] = self.lastLocation?.city
            dictionary[Keys.locationCountry] = self.lastLocation?.country
            dictionary[Keys.locationCountryCode] = self.lastLocation?.countryCode
            fallthrough
        case .ForWatch:
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
        if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
            let value = splitBillPurchased.boolValue
            self.splitBillPurchased = value
        } else {
            splitBillPurchased = false
        }
        
        var lastLocationFromDictionary = JSBIPLocation()
        if let zipCode = dictionary?[Keys.locationZipCode] as? String {
            lastLocationFromDictionary.zipCode = zipCode
        } else {
            lastLocationFromDictionary.zipCode = fallback.lastLocation?.zipCode
        }
        if let city = dictionary?[Keys.locationCity] as? String {
            lastLocationFromDictionary.city = city
        } else {
            lastLocationFromDictionary.city = fallback.lastLocation?.city
        }
        if let region = dictionary?[Keys.locationRegion] as? String {
            lastLocationFromDictionary.region = region
        } else {
            lastLocationFromDictionary.region = fallback.lastLocation?.region
        }
        if let country = dictionary?[Keys.locationCountry] as? String {
            lastLocationFromDictionary.country = country
        } else {
            lastLocationFromDictionary.country = fallback.lastLocation?.country
        }
        if let countryCode = dictionary?[Keys.locationCountryCode] as? String {
            lastLocationFromDictionary.countryCode = countryCode
        } else {
            lastLocationFromDictionary.countryCode = fallback.lastLocation?.countryCode
        }
        if lastLocationFromDictionary.isEmpty == false {
            self.lastLocation = lastLocationFromDictionary
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
        if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
            let value = splitBillPurchased.boolValue
            self.splitBillPurchased = value
        } else {
            splitBillPurchased = false
        }
        
        var lastLocationFromDictionary = JSBIPLocation()
        if let zipCode = dictionary?[Keys.locationZipCode] as? String {
            lastLocationFromDictionary.zipCode = zipCode
        }
        if let city = dictionary?[Keys.locationCity] as? String {
            lastLocationFromDictionary.city = city
        }
        if let region = dictionary?[Keys.locationRegion] as? String {
            lastLocationFromDictionary.region = region
        }
        if let country = dictionary?[Keys.locationCountry] as? String {
            lastLocationFromDictionary.country = country
        }
        if let countryCode = dictionary?[Keys.locationCountryCode] as? String {
            lastLocationFromDictionary.countryCode = countryCode
        }
        if lastLocationFromDictionary.isEmpty == false {
            self.lastLocation = lastLocationFromDictionary
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
        static let locationZipCode = "locationZipCode"
        static let locationCity = "locationCity"
        static let locationRegion = "locationRegion"
        static let locationCountry = "locationCountry"
        static let locationCountryCode = "locationCountryCode"

    }
}

struct DefaultsCalculations {
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

extension DefaultsCalculations: Equatable { }
func ==(lhs: DefaultsCalculations, rhs: DefaultsCalculations) -> Bool {
    var equal = true
    
    if lhs.tipAmount != rhs.tipAmount {
        equal = false
    }
    if lhs.billAmount != rhs.billAmount {
        equal = false
    }
    if lhs.tipPercentage != rhs.tipPercentage {
        equal = false
    }
    if lhs.totalAmount != rhs.totalAmount {
        equal = false
    }
    
    return equal
}

func !=(lhs: DefaultsCalculations, rhs: DefaultsCalculations) -> Bool {
    if lhs == rhs {
        return false
    } else {
        return true
    }
}