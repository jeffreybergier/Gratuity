//
//  GratuitousCurrencyFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/3/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousCurrencyFormatter: NSObject {
    
//    private let CURRENCYSIGNDEFAULT = 0
//    private let CURRENCYSIGNDOLLAR = 1
//    private let CURRENCYSIGNPOUND = 2
//    private let CURRENCYSIGNEURO = 3
//    private let CURRENCYSIGNYEN = 4
//    private let CURRENCYSIGNNONE = 5
    
    private let currencyFormatter = NSNumberFormatter()
    weak var tipViewControllerDelegate: TipViewController?
    
    private var selectedCurrencySymbol: CurrencySign = CurrencySign.Default {
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
        self.selectedCurrencySymbol = CurrencySign.Default
    }
    
    func localeWasOverridenByUser(notification: NSNotification?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currencyOverrideOnDisk = userDefaults.integerForKey("overrideCurrencySymbol")
        if let currencySign = CurrencySign(rawValue: currencyOverrideOnDisk) {
            self.selectedCurrencySymbol = currencySign
        } else {
            println("GratuitousCurrencyFormatter: Locale Was Override By User: Switch Case Defaulted. This should not happen. Resetting to default")
            self.selectedCurrencySymbol = CurrencySign.Default
        }
    }

    func currencyFormattedString(number: NSNumber) -> String? {
        var currencyFormattedString = "!"
        
        if self.selectedCurrencySymbol == CurrencySign.Default {
            if let localeString = self.currencyFormatter.stringFromNumber(number){
                currencyFormattedString = localeString
            } else {
                println("GratuitousCurrencyFormatter: Currency Formatter did not return a string. This should not happen.")
            }
        } else {
            currencyFormattedString = NSString(format: "%@%.0f", self.selectedCurrencySymbol.string(), number.doubleValue)
        }
        
        return currencyFormattedString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
