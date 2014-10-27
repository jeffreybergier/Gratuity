//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private weak var tipViewController: TipViewController?
    let currencyFormatter = NSNumberFormatter()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
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
    
    func prepareCurrencyFormatter() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "localeDidChange", name: NSCurrentLocaleDidChangeNotification, object: nil)
        
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    }
    
    func localeDidChange() {
        let tempVariable = NSLocale.currentLocale()
        self.currencyFormatter.locale = NSLocale.currentLocale()
        
        self.tipViewController?.localeDidChange()
    }
    
    func prepareUserDefaults() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.integerForKey("billIndexPathRow") == 0 {
            userDefaults.setInteger(19, forKey: "billIndexPathRow")
            userDefaults.setInteger(0, forKey: "tipIndexPathRow")
            userDefaults.synchronize()
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

