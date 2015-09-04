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
    
    var selectedCurrencySymbol: CurrencySign = CurrencySign.Default {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("currencyFormatterReadyReloadView", object: self)
        }
    }
    
    init(respondToNotifications: Bool) {
        if respondToNotifications == true {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeInSystem:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        }
        
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
    
    var currencyCode: String {
        switch self.selectedCurrencySymbol {
        case .Default:
            return self.currencyFormatter.currencyCode
        case .Dollar:
            return "Dollar"
        case .Pound:
            return "Pound"
        case .Euro:
            return "Euro"
        case .Yen:
            return "Yen"
        case .None:
            return "None"
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
