//
//  GratuitousSwiftiOSDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/4/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit
import StoreKit

protocol GratuitousiOSDataSourceDelegate: class {
    func setInterfaceRefreshNeeded()
}

final class GratuitousiOSDataSource: GratuitousPropertyListPreferencesDelegate, GratuitousiOSConnectivityManagerDelegate {
    
    weak var delegate: GratuitousiOSDataSourceDelegate?
    let watchConnectivityManager: AnyObject?
    
    private let currencyFormatter = NSNumberFormatter()
    private let defaultsManager = (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).defaultsManager
    
    var currencyCode: String {
        switch self.defaultsManager.overrideCurrencySymbol {
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
        case .NoSign:
            return "None"
        }
    }
    
    enum Use {
        case AppLifeTime, Temporary
    }
    
    init(use: Use) {
        switch use {
        case .Temporary:
            self.watchConnectivityManager = .None
        case .AppLifeTime:
            if #available(iOS 9, *) {
                self.watchConnectivityManager = GratuitousiOSConnectivityManager()
            } else {
                self.watchConnectivityManager = .None
            }
        }
        
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        switch use {
        case .Temporary:
            break
        case .AppLifeTime:
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeInSystem:", name: NSCurrentLocaleDidChangeNotification, object: .None)
            
            self.defaultsManager.delegate = self
            if #available(iOS 9, *) {
                (self.watchConnectivityManager as? GratuitousiOSConnectivityManager)?.delegate = self
            }
        }
    }

    func receivedContextFromWatch(context: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            let oldModel = self.defaultsManager.model
            let newModel = GratuitousPropertyListPreferences.Properties(dictionary: context, fallback: oldModel)
            self.defaultsManager.model = newModel
            self.delegate?.setInterfaceRefreshNeeded()
        }
    }
    
    func setInterfaceDataChanged() {
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.setInterfaceRefreshNeeded()
        }
    }
    
    func setDataChanged() {
        if #available(iOS 9, *) {
            (self.watchConnectivityManager as? GratuitousiOSConnectivityManager)?.updateWatchApplicationContext(self.defaultsManager.model.contextDictionaryCopy)
        }
    }
    
    func dataNeeded(dataNeeded: GratuitousPropertyListPreferences.DataNeeded) {
        // not used on iOS
    }
    
    @objc private func localeDidChangeInSystem(notification: NSNotification?) {
        self.currencyFormatter.locale = NSLocale.currentLocale()
    }
    
    func currencyFormattedString(amount: Int) -> String {
        let currentCurrencySymbol = self.defaultsManager.overrideCurrencySymbol
        return self.currencyFormattedStringWithCurrencySign(currentCurrencySymbol, amount: amount)
    }
    
    func currencyFormattedStringWithCurrencySign(currencySign: CurrencySign, amount: Int) -> String {
        let currencyString: String
        switch currencySign {
        case .Default:
            currencyString = self.currencyFormatter.stringFromNumber(amount) !! "\(amount)"
        case .NoSign:
            currencyString = "\(amount)"
        default:
            currencyString = "\(defaultsManager.overrideCurrencySymbol.string())\(amount)"
        }
        return currencyString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}