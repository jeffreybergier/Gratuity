//
//  GratuitousWatchConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/17/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import XCGLogger
import WatchConnectivity

final class GratuitousWatchConnectivityManager {
    private let log = XCGLogger.defaultInstance()
    
    private var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.remotePreferences }
        set { GratuitousWatchApplicationPreferences.sharedInstance.remotePreferences = newValue }
    }
    private var watchConnectivityManager: JSBWatchConnectivityManager {
        return GratuitousWatchApplicationPreferences.sharedInstance.watchConnectivityManager
    }
    
    private var remoteUpdateRateLimiterSet = false
    private var requestedCurrencySymbols = false
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteContextUpdateNeeded:", name: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySymbolsNeededFromRemote:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolsNeededFromRemote, object: .None)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension GratuitousWatchConnectivityManager: JSBWatchConnectivityContextDelegate {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.applicationPreferences = GratuitousUserDefaults(dictionary: applicationContext, fallback: self.applicationPreferences)
    }
    
    @objc private func remoteContextUpdateNeeded(notification: NSNotification?) {
        if self.remoteUpdateRateLimiterSet == false {
            self.remoteUpdateRateLimiterSet = true
            NSTimer.scheduleWithDelay(3.0) { timer in
                self.remoteUpdateRateLimiterSet = false
                self.updateRemoteContext(notification)
            }
        }
    }
    
    private func updateRemoteContext(notification: NSNotification?) {
        let context = self.applicationPreferences.dictionaryCopyForKeys(.WatchOnly)
        do {
            try self.watchConnectivityManager.session?.updateApplicationContext(context)
        } catch {
            self.log.error("Updating Remote Context: \(context) Failed with Error: \(error)")
        }
    }
}

extension GratuitousWatchConnectivityManager: JSBWatchConnectivityFileTransferDelegate {
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        self.log.warning("Unknown File Transfer: \(fileTransfer) to Remote Device Finished with Error: \(error)")
    }
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        self.requestedCurrencySymbols = false
        if let originalFileName = file.metadata?["FileName"] as? String,
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let dataURL = documentsURL.URLByAppendingPathComponent(originalFileName)
                self.log.info("Did Receive Currency Files from Remote")
                do {
                    let data = try NSData(contentsOfURL: file.fileURL, options: .DataReadingMappedIfSafe)
                    try data.writeToURL(dataURL, options: .AtomicWrite)
                    NSNotificationCenter.defaultCenter().postNotificationName(GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: self, userInfo: self.applicationPreferences.dictionaryCopyForKeys(.All))
                } catch {
                    self.log.error("File Save Failed with Error: \(error)")
                }
        } else {
            self.log.error("No Currency Symbols Found in Received File")
        }
    }
}

extension GratuitousWatchConnectivityManager {
    @objc private func currencySymbolsNeededFromRemote(notification: NSNotification?) {
        if self.requestedCurrencySymbols == false {
            self.requestedCurrencySymbols = true
            
            var message = GratuitousUserDefaults(dictionary: notification?.userInfo, fallback: self.applicationPreferences).dictionaryCopyForKeys(.WatchOnly)
            message["SymbolImagesRequested"] = NSNumber(bool: true)
            
            self.watchConnectivityManager.session?.sendMessage(message,
                replyHandler: { reply in
                    self.requestedCurrencySymbols = false
                },
                errorHandler: { error in
                    self.requestedCurrencySymbols = false
                    self.log.error("Sending Message Failed with Error: \(error)")
                }
            )
            self.log.info("Currency Symbols Needed: Message Sent to Remote")
        }
    }
}