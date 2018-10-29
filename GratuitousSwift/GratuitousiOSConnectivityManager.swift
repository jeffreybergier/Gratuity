//
//  GratuitousiOSConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/3/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

@available(iOS 9, *)
final class GratuitousiOSConnectivityManager {
    
    private var watchConnectivityManager: JSBWatchConnectivityManager {
        return ((UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).watchConnectivityManager as! JSBWatchConnectivityManager)
    }
    
    private var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferencesSetRemotely = newValue }
    }
    
    private var remoteUpdateRateLimiterSet = false
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.remoteContextUpdateNeeded(_:)), name: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded, object: .None)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

@available(iOS 9, *)
extension GratuitousiOSConnectivityManager {
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
        switch self.watchConnectivityManager.watchState {
        case .NotSupported, .NotPaired, .PairedWatchAppNotInstalled, .NotReachableWatchAppNotInstalled, .ReachableWatchAppNotInstalled:
            // do nothing
            break
        case .PairedWatchAppInstalled, .NotReachableWatchAppInstalled, .ReachableWatchAppInstalled:
            let context = self.applicationPreferences.dictionaryCopyForKeys(.ForWatch)
            do {
                try self.watchConnectivityManager.session?.updateApplicationContext(context)
            } catch {
                log?.error("Updating Remote Context: \(context) Failed with Error: \(error)")
            }
        }
    }
}

@available(iOS 9, *)
extension GratuitousiOSConnectivityManager: JSBWatchConnectivityContextDelegate {
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.applicationPreferences = GratuitousUserDefaults(dictionary: applicationContext, fallback: self.applicationPreferences)
    }
}

@available(iOS 9, *)
extension GratuitousiOSConnectivityManager: JSBWatchConnectivityMessageDelegate {
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let currencySymbolsNeeded = (message["SymbolImagesRequested"] as? NSNumber)?.boolValue where currencySymbolsNeeded == true {
            log?.info("Message Received: SymbolImagesRequested")
            let currencySign = GratuitousUserDefaults(dictionary: message, fallback: self.applicationPreferences).overrideCurrencySymbol
            let imagesGenerated = self.generateAndTransferCurrencySymbolImagesForCurrencySign(currencySign)
            replyHandler(["GeneratingMessages" : NSNumber(bool: imagesGenerated)])
        } else {
            log?.warning("Received Unknown Message: \(message)")
        }
    }
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        log?.info("Received Unknown MessageData: \(messageData)")
    }
    
    @available(iOS 9.0, *)
    private func generateAndTransferCurrencySymbolImagesForCurrencySign(currencySign: CurrencySign) -> Bool {
        let generator = GratuitousCurrencyStringImageGenerator()
        let tuple = generator.generateCurrencySymbolsForCurrencySign(currencySign)
        return self.initiateFileTransferToRemote(tuple)
    }
    
    @available(iOS 9.0, *)
    private func initiateFileTransferToRemote(tuple: (url: NSURL, fileName: String)?) -> Bool {
        self.applicationPreferences.currencySymbolsNeeded = false
        switch self.watchConnectivityManager.watchState {
        case .NotSupported, .NotPaired, .PairedWatchAppNotInstalled, .NotReachableWatchAppNotInstalled, .ReachableWatchAppNotInstalled:
            return false
        case .PairedWatchAppInstalled, .NotReachableWatchAppInstalled, .ReachableWatchAppInstalled:
            if let tuple = tuple {
                self.watchConnectivityManager.session?.transferFile(tuple.url, metadata: ["FileName" : tuple.fileName])
                return true
            } else {
                return false
            }
        }
    }
}

@available(iOS 9, *)
extension GratuitousiOSConnectivityManager: JSBWatchConnectivityFileTransferSenderDelegate {
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        self.applicationPreferences.currencySymbolsNeeded = false
        if let error = error {
            log?.error("File Transfer Failed with Error: \(error)")
        }
    }
}