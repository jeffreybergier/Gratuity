//
//  GratuitousWatchConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/17/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

final class GratuitousWatchConnectivityManager {
    
    private var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.preferences }
        set { GratuitousWatchApplicationPreferences.sharedInstance.preferencesSetRemotely = newValue }
    }
    private var watchConnectivityManager: JSBWatchConnectivityManager {
        return GratuitousWatchApplicationPreferences.sharedInstance.watchConnectivityManager
    }
    
    private var remoteUpdateRateLimiterSet = false
    private var requestedCurrencySymbols = false
    
    init() {
        /*
        #if DEBUG
            self.setup(.Verbose, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: .None, fileLogLevel: .None)
        #endif
        #if RELEASE
            self.log.setup(.Warning, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: .None, fileLogLevel: .None)
        #endif
        */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.remoteContextUpdateNeeded(_:)), name: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.currencySymbolsNeededFromRemote(_:)), name: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolsNeededFromRemote, object: .None)
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
        let context = self.applicationPreferences.dictionaryCopyForKeys(.ForWatch)
        do {
            try self.watchConnectivityManager.session?.updateApplicationContext(context)
        } catch {
            log?.error("Updating Remote Context: \(context) Failed with Error: \(error)")
        }
    }
}

extension GratuitousWatchConnectivityManager: JSBWatchConnectivityFileTransferReceiverDelegate {
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        log?.warning("Unknown File Transfer: \(fileTransfer) to Remote Device Finished with Error: \(error)")
    }
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        self.requestedCurrencySymbols = false
        if let symbolFileName = file.metadata?["FileName"] as? String, let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
            let destinationURL = documentsURL.URLByAppendingPathComponent(symbolFileName)
            if NSFileManager.defaultManager().fileExistsAtPath(destinationURL.path!) == false {
                log?.info("Did Receive Currency Files from Remote")
                do {
                    let data = try NSData(contentsOfURL: file.fileURL, options: .DataReadingMappedIfSafe)
                    try data.writeToURL(destinationURL, options: .AtomicWrite)
                    NSNotificationCenter.defaultCenter().postNotificationName(GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged, object: self, userInfo: self.applicationPreferences.dictionaryCopyForKeys(.ForCurrencySymbolsNeeded))
                } catch {
                    log?.error("File Save Failed with Error: \(error)")
                }
            } else {
                log?.info("Did Receive Currency Files from Remote. However, they already exist locally")
            }
        } else {
            log?.error("No Currency Symbols Found in Received File")
        }
    }
}

extension GratuitousWatchConnectivityManager {
    @objc private func currencySymbolsNeededFromRemote(notification: NSNotification?) {
        if self.requestedCurrencySymbols == false {
            self.requestedCurrencySymbols = true
            
            var message = GratuitousUserDefaults(dictionary: notification?.userInfo, fallback: self.applicationPreferences).dictionaryCopyForKeys(.ForWatch)
            message["SymbolImagesRequested"] = NSNumber(bool: true)
            
            self.watchConnectivityManager.session?.sendMessage(message,
                replyHandler: { reply in
                    self.requestedCurrencySymbols = false
                },
                errorHandler: { error in
                    self.requestedCurrencySymbols = false
                    log?.error("Sending Message Failed with Error: \(error)")
                }
            )
            log?.info("Currency Symbols Needed: Message Sent to Remote")
        }
    }
}