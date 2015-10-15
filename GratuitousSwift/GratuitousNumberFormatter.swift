//
//  GratuitousNumberFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/14/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

extension NSNumberFormatter {
    enum Style {
        case RespondsToLocaleChanges
        case DoNotRespondToLocaleChanges
    }
    
    convenience init(style: Style) {
        self.init()
        
        self.locale = NSLocale.currentLocale()
        self.maximumFractionDigits = 0
        self.minimumFractionDigits = 0
        self.alwaysShowsDecimalSeparator = false
        self.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        switch style {
        case .RespondsToLocaleChanges:
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeInSystem:", name: NSCurrentLocaleDidChangeNotification, object: .None)
        case .DoNotRespondToLocaleChanges:
            break
        }
    }
    
    @objc private func localeDidChangeInSystem(notification: NSNotification?) {
        self.locale = NSLocale.currentLocale()
    }
    
    func currencyCodeFromCurrencySign(sign: CurrencySign) -> String {
        switch sign {
        case .Default:
            return self.currencyCode
        case .Dollar:
            return "$"
        case .Pound:
            return "£"
        case .Euro:
            return "€"
        case .Yen:
            return "Y"
        case .NoSign:
            return ""
        }
    }
    
    func currencyFormattedStringWithCurrencySign(sign: CurrencySign, amount: Int) -> String {
        let currencyString: String
        switch sign {
        case .Default:
            currencyString = self.stringFromNumber(amount) !! "\(amount)"
        case .NoSign:
            currencyString = "\(amount)"
        default:
            currencyString = "\(self.currencyCodeFromCurrencySign(sign))\(amount)"
        }
        return currencyString
    }
}