//
//  GratuitousWatchConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/17/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

final class GratuitousWatchConnectivityManager {
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return GratuitousWatchApplicationPreferences.sharedInstance.preferences }
        set { GratuitousWatchApplicationPreferences.sharedInstance.preferencesSetRemotely = newValue }
    }
    fileprivate var watchConnectivityManager: JSBWatchConnectivityManager {
        return GratuitousWatchApplicationPreferences.sharedInstance.watchConnectivityManager
    }
    
    fileprivate var remoteUpdateRateLimiterSet = false
    fileprivate var requestedCurrencySymbols = false
    
    init() {
        /*
        #if DEBUG
            self.setup(.Verbose, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: .None, fileLogLevel: .None)
        #endif
        #if RELEASE
            self.log.setup(.Warning, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: .None, fileLogLevel: .None)
        #endif
        */
        NotificationCenter.default.addObserver(self, selector: #selector(self.remoteContextUpdateNeeded(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.RemoteContextUpdateNeeded), object: .none)
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencySymbolsNeededFromRemote(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolsNeededFromRemote), object: .none)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension GratuitousWatchConnectivityManager: JSBWatchConnectivityContextDelegate {
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        self.applicationPreferences = GratuitousUserDefaults(dictionary: applicationContext as NSDictionary, fallback: self.applicationPreferences)
    }
    
    @objc fileprivate func remoteContextUpdateNeeded(_ notification: Notification?) {
        if self.remoteUpdateRateLimiterSet == false {
            self.remoteUpdateRateLimiterSet = true
            Timer.scheduleWithDelay(3.0) { timer in
                self.remoteUpdateRateLimiterSet = false
                self.updateRemoteContext(notification)
            }
        }
    }
    
    fileprivate func updateRemoteContext(_ notification: Notification?) {
        let context = self.applicationPreferences.dictionaryCopyForKeys(.forWatch)
        do {
            try self.watchConnectivityManager.session?.updateApplicationContext(context)
        } catch {
            log?.error("Updating Remote Context: \(context) Failed with Error: \(error)")
        }
    }
}

extension GratuitousWatchConnectivityManager: JSBWatchConnectivityFileTransferReceiverDelegate {
    func session(_ session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        log?.warning("Unknown File Transfer: \(fileTransfer) to Remote Device Finished with Error: \(error)")
    }
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        self.requestedCurrencySymbols = false
        if let symbolFileName = file.metadata?["FileName"] as? String, let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationURL = documentsURL.appendingPathComponent(symbolFileName)
            if FileManager.default.fileExists(atPath: destinationURL.path) == false {
                log?.info("Did Receive Currency Files from Remote")
                do {
                    let data = try Data(contentsOf: file.fileURL, options: .mappedIfSafe)
                    try data.write(to: destinationURL, options: .atomicWrite)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.CurrencySymbolChanged), object: self, userInfo: self.applicationPreferences.dictionaryCopyForKeys(.forCurrencySymbolsNeeded))
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
    @objc fileprivate func currencySymbolsNeededFromRemote(_ notification: Notification?) {
        if self.requestedCurrencySymbols == false {
            self.requestedCurrencySymbols = true
            
            var message = GratuitousUserDefaults(dictionary: notification?.userInfo as! NSDictionary, fallback: self.applicationPreferences).dictionaryCopyForKeys(.forWatch)
            message["SymbolImagesRequested"] = NSNumber(value: true as Bool)
            
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
