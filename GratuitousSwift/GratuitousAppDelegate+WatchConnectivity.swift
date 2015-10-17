//
//  GratuitousAppDelegate+WatchConnectivity.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

extension GratuitousAppDelegate: GratuitousiOSConnectivityManagerDelegate {
    @available (iOS 9, *)
    func receivedContextFromWatch(context: [String : AnyObject]) {
        let updatedPreferences = GratuitousUserDefaults(dictionary: context, fallback: self.localPreferences)
        self.remotePreferences = updatedPreferences
    }
}

extension GratuitousAppDelegate: GratuitousDefaultsObserverRemoteDelegate {
    func receivedRemotePreferences(preferences: GratuitousUserDefaults) {
        if #available(iOS 9, *) {
            (self.watchConnectivityManager as! GratuitousiOSConnectivityManager).updateWatchApplicationContext(preferences.dictionaryCopyForKeys(.WatchOnly))
        }
    }
}

extension GratuitousAppDelegate {
    @available (iOS 9, *)
    func transferBulkCurrencySymbolsIfNeeded() {
        //on first run make a last ditch effort to send a lot of currency symbols to the watch
        //this may prevent waiting on the watch later
        if let watchConnectivityManager = self.watchConnectivityManager as? GratuitousiOSConnectivityManager,
            let session = watchConnectivityManager.session
            where session.paired == true && session.watchAppInstalled == true {
                
                if self.localPreferences.freshWatchAppInstall == true {
                    self.localPreferences.freshWatchAppInstall = false
                    let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
                    dispatch_async(backgroundQueue) {
                        let generator = GratuitousCurrencyStringImageGenerator()
                        if let files = generator.generateAllCurrencySymbols() {
                            watchConnectivityManager.transferBulkData(files)
                        }
                    }
                }
                
        } else {
            // watch app not installed or watch not paired
            self.localPreferences.freshWatchAppInstall = true
        }
    }
}
