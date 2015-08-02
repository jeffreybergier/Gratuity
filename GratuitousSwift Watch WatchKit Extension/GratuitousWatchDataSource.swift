//
//  GratuitousWatchDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class GratuitousWatchDataSource {
    // This class mostly exists to reduce the number of times the app has to read and write NSUserDefaults.
    // Reads are saved into Instance Variables in this class
    // If a value is requested and the isntance variable has never been set, the value is read from NSUserDefaults.
    
    let defaultsManager = GratuitousUserDefaults()
    private let currencyFormatter = NSNumberFormatter()
    
    init() {
        // configure crashlytics in an instance that won't disappear
        Fabric.with([Crashlytics()])
        
        // configure currency formatter
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    }
    
    //this code allows this object to be a singleton
    class var sharedInstance: GratuitousWatchDataSource {
        struct Static {
            static var instance: GratuitousWatchDataSource?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GratuitousWatchDataSource()
        }
        
        return Static.instance!
    }
    
    func currencyStringFromInteger(integerValue: Int?) -> String {
        var currencyString = "$–"
        if let integerValue = integerValue {
            let currentCurrencyFormat = self.defaultsManager.overrideCurrencySymbol
            switch currentCurrencyFormat {
            case .Default:
                if let defaultString = self.currencyFormatter.stringFromNumber(integerValue) {
                    currencyString = defaultString
                } else {
                    fallthrough
                }
            case .None:
                currencyString = "\(integerValue)"
            default:
                currencyString = "\(currentCurrencyFormat.string())\(integerValue)"
            }
        }
        return currencyString
    }
    
    func percentStringFromRawDouble(doubleValue: Double?) -> String {
        if let doubleValue = doubleValue {
            if isnan(doubleValue) == false && isinf(doubleValue) == false {
                return "\(Int(round(doubleValue * 100)))%"
            }
        }
        return "– %"
    }
    
    class func optionalDivision(top top: Double, bottom: Double) -> Double? {
        let division = top/bottom
        if isinf(division) == false && isnan(division) == false {
            return division
        }
        return nil
    }
}