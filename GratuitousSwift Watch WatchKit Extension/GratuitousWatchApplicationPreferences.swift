//
//  GratuitousWatchApplicationPreferences.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/16/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity
import XCGLogger

class GratuitousWatchApplicationPreferences {
    
    static let sharedInstance = GratuitousWatchApplicationPreferences()
    
    private let log = XCGLogger.defaultInstance()
    
    // MARK: App Preferences Management Properties
    private var _preferences: GratuitousUserDefaults = GratuitousUserDefaults.defaultsFromDisk()
    var localPreferences: GratuitousUserDefaults {
        get {
            return _preferences
        }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesDiskManager.writeUserDefaultsToPreferencesFileWithRateLimit(newValue)
                self.preferencesNotificationManager.postNotificationsForLocallyChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    var remotePreferences: GratuitousUserDefaults {
        get {
            return _preferences
        }
        set {
            if _preferences != newValue {
                let oldValue = _preferences
                _preferences = newValue
                self.preferencesDiskManager.writeUserDefaultsToPreferencesFileWithRateLimit(newValue)
                self.preferencesNotificationManager.postNotificationsForRemoteChangedDefaults(old: oldValue, new: newValue)
            }
        }
    }
    
    let preferencesDiskManager = GratuitousUserDefaultsDiskManager()
    let preferencesNotificationManager = GratuitousDefaultsObserver()
    let watchConnectivityManager = JSBWatchConnectivityManager()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteContextUpdateNeeded:", name: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currencySymbolsNeededFromRemote:", name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolsNeededFromRemote, object: .None)
        
        self.watchConnectivityManager.contextDelegate = self
        self.watchConnectivityManager.fileTransferDelegate = self
    }
    
    var remoteUpdateRateLimiterSet = false
    var requestedCurrencySymbols = false
    
    deinit {
        
    }
}

extension GratuitousWatchApplicationPreferences: JSBWatchConnectivityContextDelegate {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.remotePreferences = GratuitousUserDefaults(dictionary: applicationContext, fallback: self.remotePreferences)
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
        let context = notification?.userInfo as? [String : AnyObject] !! self.localPreferences.dictionaryCopyForKeys(.WatchOnly)
        do {
            try self.watchConnectivityManager.session?.updateApplicationContext(context)
        } catch {
            self.log.error("Updating Remote Context: \(context) Failed with Error: \(error)")
        }
    }
}

extension GratuitousWatchApplicationPreferences: JSBWatchConnectivityFileTransferDelegate {
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        self.log.warning("Unknown File Transfer: \(fileTransfer) to Remote Device Finished with Error: \(error)")
    }
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        self.requestedCurrencySymbols = false
        self.log.info("DidReceiveFile: \(file)")
        if let originalFileName = file.metadata?["FileName"] as? String,
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let dataURL = documentsURL.URLByAppendingPathComponent(originalFileName)
                do {
                    let data = try NSData(contentsOfURL: file.fileURL, options: .DataReadingMappedIfSafe)
                    try data.writeToURL(dataURL, options: .AtomicWrite)
                    NSNotificationCenter.defaultCenter().postNotificationName(GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: self, userInfo: self.localPreferences.dictionaryCopyForKeys(.All))
                } catch {
                    self.log.error("File Save Failed with Error: \(error)")
                }
        } else {
            self.log.error("No Currency Symbols Found in File: \(file)")
        }
    }
}

extension GratuitousWatchApplicationPreferences {
    @objc private func currencySymbolsNeededFromRemote(notification: NSNotification?) {
        if self.requestedCurrencySymbols == false {
            self.requestedCurrencySymbols = true
            
            var message = GratuitousUserDefaults(dictionary: notification?.userInfo, fallback: self.localPreferences).dictionaryCopyForKeys(.WatchOnly)
            message["SymbolImagesRequested"] = NSNumber(bool: true)
            
            self.watchConnectivityManager.session?.sendMessage(message,
                replyHandler: { reply in
                    self.log.info("Reply Received: \(reply) for Message: \(message)")
                },
                errorHandler: { error in
                    self.log.error("Error Received: \(error) for Message: \(message)")
                }
            )
            self.log.info("Currency Symbols Needed: Message Sent to iOS: \(message)")
       }
    }
}