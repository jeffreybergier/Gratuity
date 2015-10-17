//
//  GratuitousNumberFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/14/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousNumberFormatter: NSNumberFormatter {
    enum Style {
        case RespondsToLocaleChanges
        case DoNotRespondToLocaleChanges
    }
    
    init(style: Style) {
        super.init()
        
        self.locale = DefaultKeys.locale
        self.maximumFractionDigits = DefaultKeys.maximumFractionDigits
        self.minimumFractionDigits = DefaultKeys.minimumFractionDigits
        self.alwaysShowsDecimalSeparator = DefaultKeys.alwaysShowsDecimalSeparator
        self.numberStyle = DefaultKeys.numberStyle
        
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
    
    func currencySymbolFromCurrencySign(sign: CurrencySign) -> String {
        switch sign {
        case .Default:
            return self.currencyCode
        default:
            return sign.string()
        }
    }
    
    func currencyNameFromCurrencySign(sign: CurrencySign) -> String {
        switch sign {
        case .Default:
            return self.currencyCode
        default:
            return sign.stringForFileName()
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
            currencyString = "\(self.currencySymbolFromCurrencySign(sign))\(amount)"
        }
        return currencyString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let locale = aDecoder.decodeObjectForKey(CoderKeys.locale) as? NSLocale {
            self.locale = locale
        } else {
            self.locale = DefaultKeys.locale
        }
        
        if let maximumFractionDigits = aDecoder.decodeObjectForKey(CoderKeys.maximumFractionDigits) as? NSNumber {
            self.maximumFractionDigits = maximumFractionDigits.integerValue
        } else {
            self.maximumFractionDigits = DefaultKeys.maximumFractionDigits
        }
        
        if let minimumFractionDigits = aDecoder.decodeObjectForKey(CoderKeys.minimumFractionDigits) as? NSNumber {
            self.minimumFractionDigits = minimumFractionDigits.integerValue
        } else {
            self.minimumFractionDigits = DefaultKeys.minimumFractionDigits
        }
        
        if let alwaysShowsDecimalSeparator = aDecoder.decodeObjectForKey(CoderKeys.alwaysShowsDecimalSeparator) as? NSNumber {
            self.alwaysShowsDecimalSeparator = alwaysShowsDecimalSeparator.boolValue
        } else {
            self.alwaysShowsDecimalSeparator = DefaultKeys.alwaysShowsDecimalSeparator
        }
        
        if let numberStyleNumber = aDecoder.decodeObjectForKey(CoderKeys.minimumFractionDigits) as? NSNumber,
            let numberStyle = NSNumberFormatterStyle(rawValue: numberStyleNumber.unsignedLongValue) {
                self.numberStyle = numberStyle
        } else {
            self.numberStyle = DefaultKeys.numberStyle
        }
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        
        aCoder.encodeObject(self.locale, forKey: CoderKeys.locale)
        aCoder.encodeObject(NSNumber(integer: self.maximumFractionDigits), forKey: CoderKeys.maximumFractionDigits)
        aCoder.encodeObject(NSNumber(integer: self.minimumFractionDigits), forKey: CoderKeys.minimumFractionDigits)
        aCoder.encodeObject(NSNumber(bool: self.alwaysShowsDecimalSeparator), forKey: CoderKeys.alwaysShowsDecimalSeparator)
        aCoder.encodeObject(NSNumber(unsignedLong: self.numberStyle.rawValue), forKey: CoderKeys.numberStyle)
    }
    
    private struct DefaultKeys {
        static let locale = NSLocale.currentLocale()
        static let maximumFractionDigits: Int = 0
        static let minimumFractionDigits: Int = 0
        static let alwaysShowsDecimalSeparator = false
        static let numberStyle = NSNumberFormatterStyle.CurrencyStyle
    }
    
    private struct CoderKeys {
        static let locale = "locale"
        static let maximumFractionDigits = "maximumFractionDigits"
        static let minimumFractionDigits = "minimumFractionDigits"
        static let alwaysShowsDecimalSeparator = "alwaysShowsDecimalSeparator"
        static let numberStyle = "numberStyle"
    }
}

extension CurrencySign {
    func stringForFileName() -> String {
        switch self {
        case .Default:
            fatalError()
            return "Default"
        case .Dollar:
            return "Dollar"
        case .Pound:
            return "Pound"
        case .Euro:
            return "Euro"
        case .Yen:
            return "Yen"
        case .NoSign:
            return "None"
        }
    }
}