//
//  GratuitousWatchDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

protocol GratuitousWatchDataSourceDelegate: class {
    func setLargeInterfaceRefreshNeeded()
    func setSmallInterfaceRefreshNeeded()
}

class GratuitousWatchDataSource: GratuitousPropertyListPreferencesDelegate, GratuitousWatchConnectivityManagerDelegate {
    // This class mostly exists to reduce the number of times the app has to read and write NSUserDefaults.
    // Reads are saved into Instance Variables in this class
    // If a value is requested and the isntance variable has never been set, the value is read from NSUserDefaults.
    
    weak var delegate: GratuitousWatchDataSourceDelegate?
    
    let defaultsManager = GratuitousPropertyListPreferences()
    private let watchConnectivityManager = GratuitousWatchConnectivityManager()
    
    private let currencyFormatter = NSNumberFormatter()
    var currencyCode: String {
        let optionalCode: String? = self.currencyFormatter.currencyCode
        return optionalCode !! ""
    }
    
    init() {
        // configure currency formatter
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        self.defaultsManager.delegate = self
        self.watchConnectivityManager.delegate = self
    }
    
    func receivedContextFromiOS(context: [String : AnyObject]) {
        let oldModel = self.defaultsManager.model
        let newModel = GratuitousPropertyListPreferences.Properties(dictionary: context, fallback: oldModel)
        self.defaultsManager.model = newModel
        if newModel.overrideCurrencySymbol != oldModel.overrideCurrencySymbol {
            self.delegate?.setLargeInterfaceRefreshNeeded()
        } else {
            self.delegate?.setSmallInterfaceRefreshNeeded()
        }
    }

    func setInterfaceDataChanged() {
    
    }
    
    func setDataChanged() {
        self.watchConnectivityManager.updateiOSApplicationContext(self.defaultsManager.model.dictionaryVersion)
    }
    
    func dataNeeded(dataNeeded: GratuitousPropertyListPreferences.DataNeeded) {
        
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