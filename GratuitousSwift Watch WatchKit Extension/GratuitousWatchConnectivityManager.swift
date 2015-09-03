//
//  AssetVerificationInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/28/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

class GratuitousWatchConnectivityManager: NSObject, WCSessionDelegate {
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var delegate: AnyObject? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesChanged:", name: "GratuitousPropertyListPreferencesWereChanged", object: .None)
            }
        }
    }
    
    @objc private func preferencesChanged(notification: NSNotification?) {
        print("GratuitousWatchConnectivityManager: GratuitousPropertyListPreferencesWereChanged Fired: \(notification?.userInfo)")
        if let dictionary = notification?.userInfo as? [String : AnyObject] {
            do {
                try self.session?.updateApplicationContext(dictionary)
            } catch {
                print("GratuitousWatchConnectivityManager: Failed to update application context with error: \(error)")
            }
            
            #if os(watchOS)
                if let currencySymbolsNeeded = dictionary["currencySymbolsNeeded"] as? NSNumber where currencySymbolsNeeded.boolValue == true {
                    print("CurrencySymbols Needed on Watch. Requesting from iOS.")
                    session?.sendMessage(dictionary,
                        replyHandler: { reply in
                            if let currencySymbolsNeeded = reply["currencySymbolsNeeded"] as? NSNumber where currencySymbolsNeeded.boolValue == false {
                                GratuitousWatchDataSource.sharedInstance.defaultsManager.currencySymbolsNeeded = false
                            }
                        }, errorHandler: { error in
                            print("GratuitousWatchConnectivityManager: Error sending message to iOS app: \(dictionary)")
                    })
                    
                }
            #endif
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWereReceived", object: self, userInfo: applicationContext)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        #if os(iOS)
            var dictionary = message
            if let overrideCurrencySymbol = dictionary["overrideCurrencySymbol"] as? Int,
                let currencySymbolsNeeded = dictionary["currencySymbolsNeeded"] as? NSNumber,
                let currencySign = CurrencySign(rawValue: overrideCurrencySymbol)
                where currencySymbolsNeeded.boolValue == true {
                    let currencyStringImageGenerator = GratuitousCurrencyStringImageGenerator()
                    if let tuple = currencyStringImageGenerator.generateCurrencySymbolsForCurrencySign(currencySign),
                        session = self.session {
                            print("CurrencySymbols Needed on Watch for CurrencySign: \(currencySign). Sending...")
                            session.transferFile(tuple.url, metadata: ["fileName" : tuple.fileName])
                            // assume the file is going to make it
                            dictionary["currencySymbolsNeeded"] = NSNumber(bool: false)
                    }
            }
            replyHandler(dictionary)
        #endif
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        #if os(watchOS)
            print("GratuitousWatchConnectivityManager Watch Did Receive File: \(file)")
            if let originalFileName = file.metadata?["fileName"] as? String {
                let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let dataURL = documentsURL.URLByAppendingPathComponent(originalFileName)
                do {
                    let data = try NSData(contentsOfURL: file.fileURL, options: .DataReadingMappedIfSafe)
                    try data.writeToURL(dataURL, options: .AtomicWrite)
                    GratuitousWatchDataSource.sharedInstance.defaultsManager.currencySymbolsNeeded = false
                } catch {
                    NSLog("GratuitousWatchConnectivityManager: didReceiveFile: Failed with error: \(error)")
                }
            }
        #endif
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}