//
//  GratuitousCurrencyFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/3/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousCurrencyFormatter: NSObject {
    
    private let currencyFormatter = NSNumberFormatter()
    
    private var selectedCurrencySymbol: CurrencySign = CurrencySign.Default {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("currencyFormatterReadyReloadView", object: nil)
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
        if let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate {
            self.selectedCurrencySymbol = appDelegate.defaultsManager.overrideCurrencySymbol
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
