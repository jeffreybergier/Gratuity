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

class GratuitousiOSDataSource: GratuitousPropertyListPreferencesDelegate, GratuitousiOSConnectivityManagerDelegate {
    // This class mostly exists to reduce the number of times the app has to read and write NSUserDefaults.
    // Reads are saved into Instance Variables in this class
    // If a value is requested and the isntance variable has never been set, the value is read from NSUserDefaults.
    
    weak var delegate: GratuitousiOSDataSourceDelegate?
    let defaultsManager: GratuitousPropertyListPreferences?
    let purchaseManager: GratuitousPurchaseManager?
    let watchConnectivityManager: AnyObject?
    private let currencyFormatter = NSNumberFormatter()
    var currencyCode: String {
        guard let defaultsManager = self.defaultsManager else { return "None" }
        switch defaultsManager.overrideCurrencySymbol {
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
    
    enum Use {
        case AppLifeTime, Temporary
    }
    
    init(use: Use) {
        switch use {
        case .Temporary:
            self.watchConnectivityManager = .None
            self.defaultsManager = .None
            self.purchaseManager = .None
        case .AppLifeTime:
            self.defaultsManager = GratuitousPropertyListPreferences()
            self.purchaseManager = GratuitousPurchaseManager(requestImmediately: true)
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
            
            self.defaultsManager?.delegate = self
            if #available(iOS 9, *) {
                (self.watchConnectivityManager as? GratuitousiOSConnectivityManager)?.delegate = self
            }
        }
    }
    
    func receivedContextFromWatch(context: [String : AnyObject]) {
        guard let defaultsManager = self.defaultsManager else { return }
        dispatch_async(dispatch_get_main_queue()) {
            let oldModel = defaultsManager.model
            let newModel = GratuitousPropertyListPreferences.Properties(dictionary: context, fallback: oldModel)
            defaultsManager.model = newModel
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
            (self.watchConnectivityManager as? GratuitousiOSConnectivityManager)?.updateWatchApplicationContext(self.defaultsManager?.model.contextDictionaryCopy)
        }
    }
    
    func dataNeeded(dataNeeded: GratuitousPropertyListPreferences.DataNeeded) {
        // not used on iOS
    }
    
    @objc private func localeDidChangeInSystem(notification: NSNotification?) {
        self.currencyFormatter.locale = NSLocale.currentLocale()
    }
    
    func currencyFormattedString(number: Int) -> String {
        guard let defaultsManager = self.defaultsManager else { return "\(number)" }
        let currencyString: String
        switch defaultsManager.overrideCurrencySymbol {
        case .Default:
            currencyString = self.currencyFormatter.stringFromNumber(number) !! "\(number)"
        case .None:
            currencyString = "\(number)"
        default:
            currencyString = "\(defaultsManager.overrideCurrencySymbol.string())\(number)"
        }
        return currencyString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}