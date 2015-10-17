//
//  GratuitousAppDelegate+WatchConnectivity.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

extension GratuitousAppDelegate {
    @objc private func remoteContextUpdateNeeded(notification: NSNotification?) {
        if #available(iOS 9, *) {
            if self.remoteUpdateRateLimiterSet == false {
                self.remoteUpdateRateLimiterSet = true
                NSTimer.scheduleWithDelay(3.0) { timer in
                    self.remoteUpdateRateLimiterSet = false
                    self.updateRemoteContext(notification)
                }
            }
        }
    }
    
    @available (iOS 9, *)
    func updateRemoteContext(notification: NSNotification?) {
        let context = notification?.userInfo as? [String : AnyObject] !! self.localPreferences.dictionaryCopyForKeys(.WatchOnly)
        do {
            try (self.watchConnectivityManager as! JSBWatchConnectivityManager).session?.updateApplicationContext(context)
        } catch {
            self.log.error("Updating Remote Context: \(context) Failed with Error: \(error)")
        }
    }
}

extension GratuitousAppDelegate: JSBWatchConnectivityContextDelegate {
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.remotePreferences = GratuitousUserDefaults(dictionary: applicationContext, fallback: self.remotePreferences)
    }
}

extension GratuitousAppDelegate {
//    @available (iOS 9, *)
//    func transferBulkCurrencySymbolsIfNeeded() {
//        //on first run make a last ditch effort to send a lot of currency symbols to the watch
//        //this may prevent waiting on the watch later
//        if let watchConnectivityManager = self.watchConnectivityManager as? JSBWatchConnectivityManager,
//            let session = watchConnectivityManager.session
//            where session.paired == true && session.watchAppInstalled == true {
//                
//                if self.localPreferences.freshWatchAppInstall == true {
//                    self.localPreferences.freshWatchAppInstall = false
//                    let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
//                    dispatch_async(backgroundQueue) {
//                        let generator = GratuitousCurrencyStringImageGenerator()
//                        if let files = generator.generateAllCurrencySymbols() {
//                            watchConnectivityManager.transferBulkData(files)
//                        }
//                    }
//                }
//                
//        } else {
//            // watch app not installed or watch not paired
//            self.localPreferences.freshWatchAppInstall = true
//        }
//    }
}
