//
//  GratuitousCurrencyFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/3/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousCurrencyFormatter {
    
    private let currencyFormatter = NSNumberFormatter()
    
    private var selectedCurrencySymbol: CurrencySign = CurrencySign.Default {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("currencyFormatterReadyReloadView", object: nil)
        }
    }
    
    init() {
        self.prepareCurrencyFormatter()
    }
    
    private func prepareCurrencyFormatter() {
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
    
    @objc private func localeDidChangeInSystem(notification: NSNotification?) {
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.selectedCurrencySymbol = CurrencySign.Default
    }
    
    @objc private func localeWasOverridenByUser(notification: NSNotification?) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate {
            self.selectedCurrencySymbol = appDelegate.defaultsManager.overrideCurrencySymbol
        }
    }
    
    func currencyFormattedString(number: Int) -> String {
        let currencyString: String
        switch self.selectedCurrencySymbol {
        case .Default:
            currencyString = self.currencyFormatter.stringFromNumber(number) !! "\(number)"
        case .None:
            currencyString = "\(number)"
        default:
            currencyString = "\(self.selectedCurrencySymbol.string())\(number)"
        }
        return currencyString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
