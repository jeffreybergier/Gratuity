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
    let defaultsManager: GratuitousPropertyListPreferences = GratuitousPropertyListPreferences()
    let purchaseManager: GratuitousPurchaseManager?
    let watchConnectivityManager: AnyObject?
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
    
    private struct eG9aJ2Ev2rOrk8eF1caM3aG5dor4eeD9Duc2Yeb3yIm0by4hu0 {
        static var Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El: String {
            let bytes: [CChar] = [0x63, 0x6f, 0x6d, 0x2e, 0x73, 0x61, 0x74, 0x75, 0x72, 0x64, 0x61, 0x79, 0x61, 0x70, 0x70, 0x73, 0x2e, 0x47, 0x72, 0x61, 0x74, 0x75, 0x69, 0x74, 0x79]
            return NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
        }
    }
    
    init(use: Use) {
        switch use {
        case .Temporary:
            self.watchConnectivityManager = .None
            self.purchaseManager = .None
        case .AppLifeTime:
            self.purchaseManager = GratuitousPurchaseManager(requestAvailableProductsImmediately: true)
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
            
            let verifier = RMStoreAppReceiptVerifier()
            verifier.bundleIdentifier = eG9aJ2Ev2rOrk8eF1caM3aG5dor4eeD9Duc2Yeb3yIm0by4hu0.Scej9Uj9vIrth8Ev7quaG9vob6iP8buK5ferS8yoak3Fots5El
            // first verify the receipt. If it does not verify, mark the purchase as false
            if verifier.verifyAppReceipt() == true {
                // if it does verify AND the purchase is marked as false in the settings, then we can check for purhcases
                if self.defaultsManager.splitBillPurchased == false {
                    let purchases = RMAppReceipt.bundleReceipt().inAppPurchases
                    purchases.forEach() { purchase in
                        switch purchase.productIdentifier {
                        case GratuitousPurchaseManager.SplitBillProduct.identifierString:
                            self.defaultsManager.splitBillPurchased = true
                        default:
                            break
                        }
                    }
                }
            } else {
                self.defaultsManager.splitBillPurchased = false
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
    
    func currencyFormattedString(number: Int) -> String {
        let currencyString: String
        switch self.defaultsManager.overrideCurrencySymbol {
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