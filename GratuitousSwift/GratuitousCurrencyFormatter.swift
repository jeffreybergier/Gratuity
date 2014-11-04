//
//  GratuitousCurrencyFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/3/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousCurrencyFormatter: NSObject {
    
    private let CURRENCYSIGNDEFAULT = 0
    private let CURRENCYSIGNDOLLAR = 1
    private let CURRENCYSIGNPOUND = 2
    private let CURRENCYSIGNEURO = 3
    private let CURRENCYSIGNYEN = 4
    private let CURRENCYSIGNNONE = 5
    
    private let currencyFormatter = NSNumberFormatter()
    weak var tipViewControllerDelegate: TipViewController?
    
    private var selectedCurrencySymbol: Int = 0 {
        didSet {
            self.tipViewControllerDelegate?.localeDidChange()
        }
    }
    
    override init() {
        super.init()
        self.prepareCurrencyFormatter()
    }
    
    func prepareCurrencyFormatter() {
        //prepare NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeInSystem:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeWasOverridenByUser:", name: "overrideCurrencySymbolUpdatedOnDisk", object: nil)
        
        self.localeWasOverridenByUser(nil)
        
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    }
    
    func localeDidChangeInSystem(notification: NSNotification?) {
        let tempVariable = NSLocale.currentLocale()
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.selectedCurrencySymbol = self.CURRENCYSIGNDEFAULT
    }
    
    func localeWasOverridenByUser(notification: NSNotification?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currencyOverrideOnDisk = userDefaults.integerForKey("overrideCurrencySymbol")
        switch currencyOverrideOnDisk {
        case self.CURRENCYSIGNDEFAULT:
            self.selectedCurrencySymbol = self.CURRENCYSIGNDEFAULT
        case self.CURRENCYSIGNDOLLAR:
            self.selectedCurrencySymbol = self.CURRENCYSIGNDOLLAR
        case self.CURRENCYSIGNPOUND:
            self.selectedCurrencySymbol = self.CURRENCYSIGNPOUND
        case self.CURRENCYSIGNEURO:
            self.selectedCurrencySymbol = self.CURRENCYSIGNEURO
        case self.CURRENCYSIGNYEN:
            self.selectedCurrencySymbol = self.CURRENCYSIGNYEN
        case self.CURRENCYSIGNNONE:
            self.selectedCurrencySymbol = self.CURRENCYSIGNNONE
        default:
            println("AppDelegate: Locale Was Override By User: Switch Case Defaulted. This should not happen. Resetting to default")
            self.selectedCurrencySymbol = self.CURRENCYSIGNDEFAULT
        }
    }

    func currencyFormattedString(number: NSNumber) -> String? {
        var currencyFormattedString = "!"
        
        switch self.selectedCurrencySymbol {
        case self.CURRENCYSIGNDEFAULT:
            if let localeString = self.currencyFormatter.stringFromNumber(number) {
                currencyFormattedString = localeString
            } else {
                println("AppDelegate: NSNumberFormatter was asked for a StringFromNumber but it was not returned. This should not happen")
            }
        case self.CURRENCYSIGNDOLLAR:
            currencyFormattedString = NSString(format: "$%.0f", number.doubleValue)
        case self.CURRENCYSIGNPOUND:
            currencyFormattedString = NSString(format: "£%.0f", number.doubleValue)
        case self.CURRENCYSIGNEURO:
            currencyFormattedString = NSString(format: "€%.0f", number.doubleValue)
        case self.CURRENCYSIGNYEN:
            currencyFormattedString = NSString(format: "¥%.0f", number.doubleValue)
        case self.CURRENCYSIGNNONE:
            currencyFormattedString = NSString(format: "%.0f", number.doubleValue)
        default:
            println("AppDelegate: currencyFormattedString Requested by Switch Case Defaulted. This should not happen")
        }
        
        return currencyFormattedString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
