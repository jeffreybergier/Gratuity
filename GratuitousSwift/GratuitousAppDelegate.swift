//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

@UIApplicationMain
final class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Required iOS Properties Properties
    var window: UIWindow?
        
    // MARK: App Preferences Management Properties
    fileprivate var _preferences: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk() {
        didSet {
            self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(_preferences)
        }
    }
    var preferences: GratuitousUserDefaults {
        return _preferences
    }
    var preferencesSetLocally: GratuitousUserDefaults {
        get { return self.preferences }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesNotificationManager.postNotificationsForLocallyChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    var preferencesSetRemotely: GratuitousUserDefaults {
        get { return self.preferences }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                let oldC = DefaultsCalculations(preferences: oldValue)
                let newC = DefaultsCalculations(preferences: newValue)
                if oldC != newC {
                    self.postNewCalculationToAnswers(newValue)
                }
                self.preferencesNotificationManager.postNotificationsForRemoteChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    
    fileprivate let preferencesDiskManager = GratuitousUserDefaultsDiskManager()
    fileprivate let preferencesNotificationManager = GratuitousDefaultsObserver()
    
    // MARK: State Restoration Properties
    let storyboard: UIStoryboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    let presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .right, animate: false)
    let presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .bottom, animate: false)
    
    // MARK: Watch Connectivity Properties
    let watchConnectivityManager: AnyObject? = {
        if #available(iOS 9, *) {
            return JSBWatchConnectivityManager()
        } else {
            return .none
        }
    }()
    fileprivate let customWatchCommunicationManager: AnyObject? = {
        if #available(iOS 9, *) {
            return GratuitousiOSConnectivityManager()
        } else {
            return .none
        }
    }()
    
    // MARK: iOS App Launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        
        /*
        //crashlytics intializer
        #if DEBUG
            self.log.setup(.Verbose, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: .None, fileLogLevel: .None)
            self.log.info("Debug Build: Not Loading Fabric")
        #endif
        #if RELEASE
            self.log.setup(.Warning, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: .None, fileLogLevel: .None)
            self.log.info("Release Build: Loading Fabric")
            Fabric.with([Crashlytics.self(), Answers.self()])
        #endif
        */
        
        self.window?.tintColor = GratuitousUIConstant.lightTextColor()
        self.window?.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        
        if #available(iOS 9, *) {
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.contextDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.messageDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.fileTransferSenderDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
        }
        
        let purchaseManager = GratuitousPurchaseManager()
        self.preferencesSetLocally.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
        
        return true
    }
    
    // MARK: Watch Calculations Analytics
    fileprivate let currencyFormatter = GratuitousNumberFormatter(style: .respondsToLocaleChanges)
    fileprivate func postNewCalculationToAnswers(_ preferences: GratuitousUserDefaults) {
        let c = DefaultsCalculations(preferences: preferences)
        
        var answersAttributes: [String : Any] = [
            "BillAmount" : NSNumber(value: c.billAmount as Int),
            "TipAmount" : NSNumber(value: c.tipAmount as Int),
            "TipPercentage" : NSNumber(value: c.tipPercentage as Int),
            "TotalAmount" : NSNumber(value: c.totalAmount as Int),
            "SystemLocale" : self.currencyFormatter.locale.identifier
        ]
        answersAttributes["LocationZipCode"] = self.preferences.lastLocation?.zipCode
        answersAttributes["LocationCity"] = self.preferences.lastLocation?.city
        answersAttributes["LocationRegion"] = self.preferences.lastLocation?.region
        answersAttributes["LocationCountry"] = self.preferences.lastLocation?.country
        answersAttributes["LocationCountryCode"] = self.preferences.lastLocation?.countryCode
    }
    
    // MARK: iOS App Going to the Background
    func applicationWillResignActive(_ application: UIApplication) {
        self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(self.preferences)
    }
}

