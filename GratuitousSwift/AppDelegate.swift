//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let CURRENCYSIGNDEFAULT = 0
    private let CURRENCYSIGNDOLLAR = 1
    private let CURRENCYSIGNPOUND = 2
    private let CURRENCYSIGNEURO = 3
    private let CURRENCYSIGNYEN = 4
    private let CURRENCYSIGNNONE = 5
    
    private weak var tipViewController: TipViewController?

    var window: UIWindow?
    private var selectedCurrencySymbol: Int = 0 {
        didSet {
            self.tipViewController?.localeDidChange()
        }
    }
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let currencyFormatter = NSNumberFormatter()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //crashlytics intializer
        //Crashlytics.sharedInstance().debugMode = true
        Fabric.with([Crashlytics()])
        
        //prepare NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChangeInSystem:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeWasOverridenByUser:", name: "overrideCurrencySymbolUpdatedOnDisk", object: nil)
        
        //prepare currency formatter and nsuserdefaults
        self.prepareUserDefaults()
        self.prepareCurrencyFormatter()
                
        //initialize the window and the view controller
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
        self.tipViewController = storyboard.instantiateInitialViewController() as? TipViewController
        
        //configure the window
        if let tipViewController = self.tipViewController {
            self.window?.rootViewController = tipViewController
        } else {
            println("AppDelegate: TipViewController failed optional unwrapping. You should never receive this warning.")
        }
        self.window?.backgroundColor = GratuitousColorSelector.darkBackgroundColor();
        self.window?.tintColor = GratuitousColorSelector.lightTextColor()
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func currencyFormattedString(number: NSNumber) -> String? {
        var currencyFormattedString = "!"
        
        switch self.selectedCurrencySymbol {
        case self.CURRENCYSIGNDEFAULT:
            if let localeString = self.currencyFormatter.stringFromNumber(number) {
                currencyFormattedString = localeString
            } else {
                println("AppDelegate: NSNumberFormatter was asked for a StringFromNumber but it was not returned. This should not happen")
            }
        case self.CURRENCYSIGNDOLLAR:
            currencyFormattedString = NSString(format: "$%.0f", number.doubleValue)
        case self.CURRENCYSIGNPOUND:
            currencyFormattedString = NSString(format: "£%.0f", number.doubleValue)
        case self.CURRENCYSIGNEURO:
            currencyFormattedString = NSString(format: "€%.0f", number.doubleValue)
        case self.CURRENCYSIGNYEN:
            currencyFormattedString = NSString(format: "¥%.0f", number.doubleValue)
        case self.CURRENCYSIGNNONE:
            currencyFormattedString = NSString(format: "%.0f", number.doubleValue)
        default:
            println("AppDelegate: currencyFormattedString Requested by Switch Case Defaulted. This should not happen")
        }
        
        return currencyFormattedString
    }
    
    func prepareCurrencyFormatter() {
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    }
    
    func localeDidChangeInSystem(notification: NSNotification?) {
        let tempVariable = NSLocale.currentLocale()
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.selectedCurrencySymbol = self.CURRENCYSIGNDEFAULT
    }
    
    func localeWasOverridenByUser(notification: NSNotification?) {
        let currencyOverrideOnDisk = self.userDefaults.integerForKey("overrideCurrencySymbol")
        switch currencyOverrideOnDisk {
        case self.CURRENCYSIGNDEFAULT:
            self.selectedCurrencySymbol = self.CURRENCYSIGNDEFAULT
        case self.CURRENCYSIGNDOLLAR:
            self.selectedCurrencySymbol = self.CURRENCYSIGNDOLLAR
        case self.CURRENCYSIGNPOUND:
            self.selectedCurrencySymbol = self.CURRENCYSIGNPOUND
        case self.CURRENCYSIGNEURO:
            self.selectedCurrencySymbol = self.CURRENCYSIGNEURO
        case self.CURRENCYSIGNYEN:
            self.selectedCurrencySymbol = self.CURRENCYSIGNYEN
        case self.CURRENCYSIGNNONE:
            self.selectedCurrencySymbol = self.CURRENCYSIGNNONE
        default:
            println("AppDelegate: Locale Was Override By User: Switch Case Defaulted. This should not happen. Resetting to default")
            self.selectedCurrencySymbol = self.CURRENCYSIGNDEFAULT
        }
    }
    
    func prepareUserDefaults() {
        if self.userDefaults.integerForKey("billIndexPathRow") == 0 {
            self.userDefaults.setInteger(19, forKey: "billIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            self.userDefaults.setInteger(0, forKey: "overrideCurrencySymbol")
            self.userDefaults.setDouble(0.2, forKey: "suggestedTipPercentage")
            self.userDefaults.synchronize()
        } else {
            self.localeWasOverridenByUser(nil)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //Crashlytics.sharedInstance().crash()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}

