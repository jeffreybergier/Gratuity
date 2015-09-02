//
//  AssetVerificationInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/28/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

protocol WatchConnectivityDelegate: class {
    
}

class GratuitousWatchConnectivityManager: NSObject, WCSessionDelegate {
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var delegate: WatchConnectivityDelegate? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesChanged:", name: "GratuitousPropertyListPreferencesWereChanged", object: .None)
                //NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferencesChanged:", name: "GratuitousPropertyListPreferencesWereReceived", object: .None)
            }
        }
    }
    
    @objc private func preferencesChanged(notification: NSNotification?) {
        print("GratuitousWatchConnectivityManager: GratuitousPropertyListPreferencesWereChanged Fired: \(notification?.userInfo)")
        if var dictionary = notification?.userInfo as? [String : AnyObject] {
            #if os(iOS)
                if let overrideCurrencySymbol = notification?.userInfo?["overrideCurrencySymbol"] as? Int,
                    let currencySymbolsNeeded = notification?.userInfo?["currencySymbolsNeeded"] as? NSNumber,
                    let currencySign = CurrencySign(rawValue: overrideCurrencySymbol)
                    where currencySymbolsNeeded.boolValue == true {
                        let currencyStringImageGenerator = GratuitousCurrencyStringImageGenerator()
                        if let tuple = currencyStringImageGenerator.generateCurrencySymbolsForCurrencySign(currencySign),
                            session = self.session {
                                print("CurrencySymbols Needed on Watch for CurrencySign: \(currencySign). Sending...")
                                session.transferFile(tuple.url, metadata: ["fileName" : tuple.fileName])
                                // assume the file is going to make it
                                dictionary["currencySymbolsNeeded"] = NSNumber(bool: false)
                                NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWereReceived", object: self, userInfo: dictionary)
                        }
                }
            #endif
            
            do {
                try self.session?.updateApplicationContext(dictionary)
            } catch {
                print("GratuitousWatchConnectivityManager: Failed to update application context with error: \(error)")
            }
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWereReceived", object: self, userInfo: applicationContext)
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        #if os(watchOS)
            print("GratuitousWatchConnectivityManager Watch Did Receive File: \(file)")
            if let originalFileName = file.metadata?["filename"] as? String {
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
}