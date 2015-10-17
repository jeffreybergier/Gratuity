//
//  GratuitousAppDelegate+AppOpenClose.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved
//

extension GratuitousAppDelegate {
    // MARK: iOS App Launch
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
        //Fabric.with([Crashlytics()])
        
        self.window!.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        
        if #available(iOS 9, *) {
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.contextDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.messageDelegate = (self.customWatchCommunicationManager as? GratuitousiOSConnectivityManager)
        }
        
        let purchaseManager = GratuitousPurchaseManager()
        self.localPreferences.splitBillPurchased = purchaseManager.verifySplitBillPurchaseTransaction()
        
        return true
    }
    
    // MARK: iOS App Going to the Background
    func applicationWillResignActive(application: UIApplication) {
        self.preferencesDiskManager.writeUserDefaultsToPreferencesFile(self.localPreferences)
    }
}