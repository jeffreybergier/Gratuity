//
//  GratuitousAppDelegate+WatchConnectivity.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

extension GratuitousAppDelegate {
    @available (iOS 9, *)
    @objc private func remoteContextUpdateNeeded(notification: NSNotification?) {
        if self.remoteUpdateRateLimiterSet == false {
            self.remoteUpdateRateLimiterSet = true
            NSTimer.scheduleWithDelay(3.0) { timer in
                self.remoteUpdateRateLimiterSet = false
                self.updateRemoteContext(notification)
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

extension GratuitousAppDelegate: JSBWatchConnectivityMessageDelegate {
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let currencySymbolsNeeded = (message["SymbolImagesRequested"] as? NSNumber)?.boolValue where currencySymbolsNeeded == true {
            self.log.info("Message Received: SymbolImagesRequested")
            let currencySign = GratuitousUserDefaults(dictionary: message, fallback: self.localPreferences).overrideCurrencySymbol
            let imagesGenerated = self.generateAndTransferCurrencySymbolImagesForCurrencySign(currencySign)
            replyHandler(["GeneratingMessages" : NSNumber(bool: imagesGenerated)])
        } else {
            self.log.warning("Received Unknown Message: \(message)")
        }
    }
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        self.log.info("Received Unknown MessageData: \(messageData)")
    }
    
    @available(iOS 9.0, *)
    private func generateAndTransferCurrencySymbolImagesForCurrencySign(currencySign: CurrencySign) -> Bool {
        let generator = GratuitousCurrencyStringImageGenerator()
        let tuple = generator.generateCurrencySymbolsForCurrencySign(currencySign)
        return self.initiateFileTransferToRemote(tuple)
    }
    
    @available(iOS 9.0, *)
    private func initiateFileTransferToRemote(tuple: (url: NSURL, fileName: String)?) -> Bool {
        if let tuple = tuple {
            (self.watchConnectivityManager as? JSBWatchConnectivityManager)?.session?.transferFile(tuple.url, metadata: ["FileName" : tuple.fileName])
            return true
        } else {
            return false
        }
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
