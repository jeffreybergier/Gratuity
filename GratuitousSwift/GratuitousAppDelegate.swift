//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import Fabric
import Crashlytics
import XCGLogger

@UIApplicationMain
final class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Required iOS Properties Properties
    var window: UIWindow?
    
    let log = XCGLogger.defaultInstance()
    
    // MARK: App Preferences Management Properties
    private var _preferences: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk() {
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
    
    private let preferencesDiskManager = GratuitousUserDefaultsDiskManager()
    private let preferencesNotificationManager = GratuitousDefaultsObserver()
    
    // MARK: State Restoration Properties
    let storyboard: UIStoryboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    let presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .Right, animate: false)
    let presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .Bottom, animate: false)
    
    // MARK: Watch Connectivity Properties
    let watchConnectivityManager: AnyObject? = {
        if #available(iOS 9, *) {
            return JSBWatchConnectivityManager()
        } else {
            return .None
        }
    }()
    private let customWatchCommunicationManager: AnyObject? = {
        if #available(iOS 9, *) {
            return GratuitousiOSConnectivityManager()
        } else {
            return .None
        }
    }()
    
    // MARK: iOS App Launch
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
        Fabric.with([Crashlytics.self(), Answers.self()])
        
        self.window?.tintColor = GratuitousUIConstant.lightTextColor()
        self.window?.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        
        if #available(iOS 9, *) {
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.contextDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.messageDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.fileTransferSenderDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
        }
        
        let purchaseManager = GratuitousPurchaseManager()
        self.preferencesSetLocally.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
        
        JSBIPGeocoder(service: JSBIPGeoService.All).geocode() { (location, error) in
            if let location = location as? JSBIPLocation {
                self.preferencesSetLocally.lastLocation = location
            }
            Answers.logCustomEventWithName(AnswersString.Launched, customAttributes: self.preferences.dictionaryCopyForKeys(.ForDisk))
        }
        
        return true
    }
    
    // MARK: Watch Calculations Analytics
    private let currencyFormatter = GratuitousNumberFormatter(style: .RespondsToLocaleChanges)
    private func postNewCalculationToAnswers(preferences: GratuitousUserDefaults) {
        let c = DefaultsCalculations(preferences: preferences)
        
        var answersAttributes = [
            "BillAmount" : NSNumber(integer: c.billAmount),
            "TipAmount" : NSNumber(integer: c.tipAmount),
            "TipPercentage" : NSNumber(integer: c.tipPercentage),
            "TotalAmount" : NSNumber(integer: c.totalAmount),
            "SystemLocale" : self.currencyFormatter.locale.localeIdentifier
        ]
        answersAttributes["LocationZipCode"] = self.preferences.lastLocation?.zipCode
        answersAttributes["LocationCity"] = self.preferences.lastLocation?.city
        answersAttributes["LocationRegion"] = self.preferences.lastLocation?.region
        answersAttributes["LocationCountry"] = self.preferences.lastLocation?.country
        answersAttributes["LocationCountryCode"] = self.preferences.lastLocation?.countryCode
        
        Answers.logCustomEventWithName(AnswersString.NewWatchTipCalculated, customAttributes: answersAttributes)
    }
    
    // MARK: iOS App Going to the Background
    func applicationWillResignActive(application: UIApplication) {
        self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(self.preferences)
        Answers.logCustomEventWithName(AnswersString.Backgrounded, customAttributes: self.preferences.dictionaryCopyForKeys(.ForDisk))
    }
}

