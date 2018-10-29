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
    var billIndexPathRow: Int
    var tipIndexPathRow: Int
    var overrideCurrencySymbol: CurrencySign
    var suggestedTipPercentage: Double
    var splitBillPurchased: Bool
    var lastLocation: JSBIPLocation?
}

extension GratuitousUserDefaults: Equatable { }

func ==(lhs: GratuitousUserDefaults, rhs: GratuitousUserDefaults) -> Bool {
    return lhs.dictionaryCopyForKeys(.forCurrencySymbolsNeeded) as NSDictionary == rhs.dictionaryCopyForKeys(.forCurrencySymbolsNeeded) as NSDictionary
}

extension GratuitousUserDefaults {
    enum DictionaryCopyKeys {
        case forCurrencySymbolsNeeded, forWatch, forDisk
    }
    
    func dictionaryCopyForKeys(_ keys: DictionaryCopyKeys) -> [String : AnyObject] {
        var dictionary = [String : AnyObject]()
        switch keys {
        case .forCurrencySymbolsNeeded:
            dictionary[Keys.currencySymbolsNeeded] = self.currencySymbolsNeeded as AnyObject
            fallthrough
        case .forDisk:
            dictionary[Keys.locationZipCode] = self.lastLocation?.zipCode as AnyObject
            dictionary[Keys.locationCity] = self.lastLocation?.city as AnyObject
            dictionary[Keys.locationCountry] = self.lastLocation?.country as AnyObject
            dictionary[Keys.locationCountryCode] = self.lastLocation?.countryCode as AnyObject
            fallthrough
        case .forWatch:
            dictionary[Keys.billIndexPathRow] = NSNumber(value: self.billIndexPathRow as Int)
            dictionary[Keys.tipIndexPathRow] = NSNumber(value: self.tipIndexPathRow as Int)
            dictionary[Keys.overrideCurrencySymbol] = NSNumber(value: self.overrideCurrencySymbol.rawValue as Int)
            dictionary[Keys.suggestedTipPercentage] = NSNumber(value: self.suggestedTipPercentage as Double)
            dictionary[Keys.splitBillPurchased] = NSNumber(value: self.splitBillPurchased as Bool)
        }
        return dictionary
    }
}

extension GratuitousUserDefaults {

    init(dictionary: NSDictionary?, fallback: GratuitousUserDefaults? = .none) {
        // version 1.0 and 1.0.1 keys
        if let billIndexPathRow = dictionary?[Keys.billIndexPathRow] as? NSNumber {
            self.billIndexPathRow = billIndexPathRow.intValue
        } else if let billIndexPathRow = fallback?.billIndexPathRow {
            self.billIndexPathRow = billIndexPathRow
        } else {
            self.billIndexPathRow = 25
        }
        if let tipIndexPathRow = dictionary?[Keys.tipIndexPathRow] as? NSNumber {
            self.tipIndexPathRow = tipIndexPathRow.intValue
        } else if let tipIndexPathRow = fallback?.tipIndexPathRow {
            self.tipIndexPathRow = tipIndexPathRow
        } else {
            self.tipIndexPathRow = 0
        }
        if let overrideCurrencySymbol = dictionary?[Keys.overrideCurrencySymbol] as? NSNumber,
            let symbolEnum = CurrencySign(rawValue: overrideCurrencySymbol.intValue) {
                self.overrideCurrencySymbol = symbolEnum
        } else if let overrideCurrencySymbol = fallback?.overrideCurrencySymbol {
            self.overrideCurrencySymbol = overrideCurrencySymbol
        } else {
            self.overrideCurrencySymbol = .default
        }
        if let suggestedTipPercentage = dictionary?[Keys.suggestedTipPercentage] as? NSNumber {
            self.suggestedTipPercentage = suggestedTipPercentage.doubleValue
        } else if let suggestedTipPercentage = fallback?.suggestedTipPercentage {
            self.suggestedTipPercentage = suggestedTipPercentage
        } else {
            self.suggestedTipPercentage = 0.2
        }
        // version 1.2 keys
        if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
            let value = splitBillPurchased.boolValue
            self.splitBillPurchased = value
        } else if let splitBillPurchased = fallback?.splitBillPurchased {
            self.splitBillPurchased = splitBillPurchased
        } else {
            self.splitBillPurchased = false
        }
        
        var lastLocationFromDictionary = JSBIPLocation()
        if let zipCode = dictionary?[Keys.locationZipCode] as? String {
            lastLocationFromDictionary.zipCode = zipCode
        } else {
            lastLocationFromDictionary.zipCode = fallback?.lastLocation?.zipCode
        }
        if let city = dictionary?[Keys.locationCity] as? String {
            lastLocationFromDictionary.city = city
        } else {
            lastLocationFromDictionary.city = fallback?.lastLocation?.city
        }
        if let region = dictionary?[Keys.locationRegion] as? String {
            lastLocationFromDictionary.region = region
        } else {
            lastLocationFromDictionary.region = fallback?.lastLocation?.region
        }
        if let country = dictionary?[Keys.locationCountry] as? String {
            lastLocationFromDictionary.country = country
        } else {
            lastLocationFromDictionary.country = fallback?.lastLocation?.country
        }
        if let countryCode = dictionary?[Keys.locationCountryCode] as? String {
            lastLocationFromDictionary.countryCode = countryCode
        } else {
            lastLocationFromDictionary.countryCode = fallback?.lastLocation?.countryCode
        }
        if lastLocationFromDictionary.isEmpty == false {
            self.lastLocation = lastLocationFromDictionary
        }
        // ignored from disk version. Always set to false on load
        self.currencySymbolsNeeded = fallback?.currencySymbolsNeeded ?? false
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
        let rawTipPercentage = Double(tipAmount) /? Double(billAmount)
        let tipPercentage = Int(round(rawTipPercentage * 100))
        
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
