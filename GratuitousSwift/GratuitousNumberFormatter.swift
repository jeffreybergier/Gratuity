//
//  GratuitousNumberFormatter.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/14/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousNumberFormatter: NumberFormatter {
    
    enum Style2 {
        case respondsToLocaleChanges
        case doNotRespondToLocaleChanges
    }
    
    init(style: GratuitousNumberFormatter.Style2) {
        super.init()
        
        self.locale = DefaultKeys.locale
        self.maximumFractionDigits = DefaultKeys.maximumFractionDigits
        self.minimumFractionDigits = DefaultKeys.minimumFractionDigits
        self.alwaysShowsDecimalSeparator = DefaultKeys.alwaysShowsDecimalSeparator
        self.numberStyle = DefaultKeys.numberStyle
        
        switch style {
        case .respondsToLocaleChanges:
            NotificationCenter.default.addObserver(self, selector: #selector(self.localeDidChangeInSystem(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: .none)
        case .doNotRespondToLocaleChanges:
            break
        }
    }
    
    @objc fileprivate func localeDidChangeInSystem(_ notification: Notification?) {
        self.locale = Locale.current
    }
    
    func currencySymbolFromCurrencySign(_ sign: CurrencySign) -> String {
        switch sign {
        case .default:
            return self.currencyCode
        default:
            return sign.string()
        }
    }
    
    func currencyNameFromCurrencySign(_ sign: CurrencySign) -> String {
        switch sign {
        case .default:
            return self.currencyCode
        default:
            return sign.stringForFileName()
        }
    }
    
    func currencyFormattedStringWithCurrencySign(_ sign: CurrencySign, amount: Int) -> String {
        let currencyString: String
        switch sign {
        case .default:
            currencyString = self.string(from: NSNumber(value: amount)) !! "\(amount)"
        case .noSign:
            currencyString = "\(amount)"
        default:
            currencyString = "\(self.currencySymbolFromCurrencySign(sign))\(amount)"
        }
        return currencyString
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let locale = aDecoder.decodeObject(forKey: CoderKeys.locale) as? Locale {
            self.locale = locale
        } else {
            self.locale = DefaultKeys.locale
        }
        
        if let maximumFractionDigits = aDecoder.decodeObject(forKey: CoderKeys.maximumFractionDigits) as? NSNumber {
            self.maximumFractionDigits = maximumFractionDigits.intValue
        } else {
            self.maximumFractionDigits = DefaultKeys.maximumFractionDigits
        }
        
        if let minimumFractionDigits = aDecoder.decodeObject(forKey: CoderKeys.minimumFractionDigits) as? NSNumber {
            self.minimumFractionDigits = minimumFractionDigits.intValue
        } else {
            self.minimumFractionDigits = DefaultKeys.minimumFractionDigits
        }
        
        if let alwaysShowsDecimalSeparator = aDecoder.decodeObject(forKey: CoderKeys.alwaysShowsDecimalSeparator) as? NSNumber {
            self.alwaysShowsDecimalSeparator = alwaysShowsDecimalSeparator.boolValue
        } else {
            self.alwaysShowsDecimalSeparator = DefaultKeys.alwaysShowsDecimalSeparator
        }
        
        if let numberStyleNumber = aDecoder.decodeObject(forKey: CoderKeys.minimumFractionDigits) as? NSNumber,
            let numberStyle = NumberFormatter.Style(rawValue: numberStyleNumber.uintValue) {
                self.numberStyle = numberStyle
        } else {
            self.numberStyle = DefaultKeys.numberStyle
        }
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        aCoder.encode(self.locale, forKey: CoderKeys.locale)
        aCoder.encode(NSNumber(value: self.maximumFractionDigits as Int), forKey: CoderKeys.maximumFractionDigits)
        aCoder.encode(NSNumber(value: self.minimumFractionDigits as Int), forKey: CoderKeys.minimumFractionDigits)
        aCoder.encode(NSNumber(value: self.alwaysShowsDecimalSeparator as Bool), forKey: CoderKeys.alwaysShowsDecimalSeparator)
        aCoder.encode(NSNumber(value: self.numberStyle.rawValue as UInt), forKey: CoderKeys.numberStyle)
    }
    
    fileprivate struct DefaultKeys {
        static let locale = Locale.current
        static let maximumFractionDigits: Int = 0
        static let minimumFractionDigits: Int = 0
        static let alwaysShowsDecimalSeparator = false
        static let numberStyle = NumberFormatter.Style.currency
    }
    
    fileprivate struct CoderKeys {
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
        case .default:
            return "Default"
        case .dollar:
            return "Dollar"
        case .pound:
            return "Pound"
        case .euro:
            return "Euro"
        case .yen:
            return "Yen"
        case .noSign:
            return "None"
        }
    }
}
