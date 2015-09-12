//
//  GratuitousSwiftiOSDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/4/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

protocol GratuitousiOSDataSourceDelegate: class {
    func setInterfaceRefreshNeeded()
}

class GratuitousiOSDataSource: GratuitousPropertyListPreferencesDelegate, GratuitousiOSConnectivityManagerDelegate {
    // This class mostly exists to reduce the number of times the app has to read and write NSUserDefaults.
    // Reads are saved into Instance Variables in this class
    // If a value is requested and the isntance variable has never been set, the value is read from NSUserDefaults.
    
    weak var delegate: GratuitousiOSDataSourceDelegate?
    let defaultsManager = GratuitousPropertyListPreferences()
    let watchConnectivityManager: GratuitousiOSConnectivityManager?
    private let currencyFormatter = NSNumberFormatter()
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
        case .AppLifeTime:
            self.watchConnectivityManager = GratuitousiOSConnectivityManager()
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
            self.watchConnectivityManager?.delegate = self
            
            if self.defaultsManager.freshWatchAppInstall == true {
                self.bulkTransferCurrencySymbols()
            }
        }
    }
    
    private func bulkTransferCurrencySymbols() {
        //on first run make a last ditch effort to send a lot of currency symbols to the watch
        //this may prevent waiting on the watch later
        if let watchConnectivityManager = self.watchConnectivityManager,
            let session = watchConnectivityManager.session
            where session.paired == true && session.watchAppInstalled == true {
                let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
                dispatch_async(backgroundQueue) {
                    let generator = GratuitousCurrencyStringImageGenerator()
                    if let files = generator.generateAllCurrencySymbols() {
                        watchConnectivityManager.transferBulkData(files)
                    }
                }
                self.defaultsManager.freshWatchAppInstall = false
        } else {
            self.defaultsManager.freshWatchAppInstall = true
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
        self.watchConnectivityManager?.updateWatchApplicationContext(self.defaultsManager.model.contextDictionaryCopy)
    }
    
    func dataNeeded(dataNeeded: GratuitousPropertyListPreferences.DataNeeded) {
        // not used on iOS
    }
    
    @objc private func localeDidChangeInSystem(notification: NSNotification?) {
        self.currencyFormatter.locale = NSLocale.currentLocale()
    }
    
    func currencyFormattedString(number: Int) -> String {
        let currencyString: String
        switch self.defaultsManager.overrideCurrencySymbol {
        case .Default:
            currencyString = self.currencyFormatter.stringFromNumber(number) !! "\(number)"
        case .None:
            currencyString = "\(number)"
        default:
            currencyString = "\(self.defaultsManager.overrideCurrencySymbol.string())\(number)"
        }
        return currencyString
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}