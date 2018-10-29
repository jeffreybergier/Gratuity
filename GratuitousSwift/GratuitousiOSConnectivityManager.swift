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
    
    fileprivate var watchConnectivityManager: JSBWatchConnectivityManager {
        return ((UIApplication.shared.delegate as! GratuitousAppDelegate).watchConnectivityManager as! JSBWatchConnectivityManager)
    }
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.shared.delegate as! GratuitousAppDelegate).preferencesSetRemotely = newValue }
    }
    
    fileprivate var remoteUpdateRateLimiterSet = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.remoteContextUpdateNeeded(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded), object: .none)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@available(iOS 9, *)
extension GratuitousiOSConnectivityManager {
    @available (iOS 9, *)
    @objc fileprivate func remoteContextUpdateNeeded(_ notification: Notification?) {
        if self.remoteUpdateRateLimiterSet == false {
            self.remoteUpdateRateLimiterSet = true
            Timer.scheduleWithDelay(3.0) { timer in
                self.remoteUpdateRateLimiterSet = false
                self.updateRemoteContext(notification)
            }
        }
    }
    
    @available (iOS 9, *)
    func updateRemoteContext(_ notification: Notification?) {
        switch self.watchConnectivityManager.watchState {
        case .notSupported, .notPaired, .pairedWatchAppNotInstalled, .notReachableWatchAppNotInstalled, .reachableWatchAppNotInstalled:
            // do nothing
            break
        case .pairedWatchAppInstalled, .notReachableWatchAppInstalled, .reachableWatchAppInstalled:
            let context = self.applicationPreferences.dictionaryCopyForKeys(.forWatch)
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
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.applicationPreferences = GratuitousUserDefaults(dictionary: applicationContext as NSDictionary, fallback: self.applicationPreferences)
    }
}

@available(iOS 9, *)
extension GratuitousiOSConnectivityManager: JSBWatchConnectivityMessageDelegate {
    @available(iOS 9.0, *)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        if let currencySymbolsNeeded = (message["SymbolImagesRequested"] as? NSNumber)?.boolValue, currencySymbolsNeeded == true {
            log?.info("Message Received: SymbolImagesRequested")
            let currencySign = GratuitousUserDefaults(dictionary: message as NSDictionary, fallback: self.applicationPreferences).overrideCurrencySymbol
            let imagesGenerated = self.generateAndTransferCurrencySymbolImagesForCurrencySign(currencySign)
            replyHandler(["GeneratingMessages" : NSNumber(value: imagesGenerated as Bool)])
        } else {
            log?.warning("Received Unknown Message: \(message)")
        }
    }
    @available(iOS 9.0, *)
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Swift.Void) {
        log?.info("Received Unknown MessageData: \(messageData)")
    }
    
    @available(iOS 9.0, *)
    fileprivate func generateAndTransferCurrencySymbolImagesForCurrencySign(_ currencySign: CurrencySign) -> Bool {
        let generator = GratuitousCurrencyStringImageGenerator()
        let tuple = generator.generateCurrencySymbolsForCurrencySign(currencySign)
        return self.initiateFileTransferToRemote(tuple)
    }
    
    @available(iOS 9.0, *)
    fileprivate func initiateFileTransferToRemote(_ tuple: (url: URL, fileName: String)?) -> Bool {
        self.applicationPreferences.currencySymbolsNeeded = false
        switch self.watchConnectivityManager.watchState {
        case .notSupported, .notPaired, .pairedWatchAppNotInstalled, .notReachableWatchAppNotInstalled, .reachableWatchAppNotInstalled:
            return false
        case .pairedWatchAppInstalled, .notReachableWatchAppInstalled, .reachableWatchAppInstalled:
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
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        self.applicationPreferences.currencySymbolsNeeded = false
        if let error = error {
            log?.error("File Transfer Failed with Error: \(error)")
        }
    }
}
