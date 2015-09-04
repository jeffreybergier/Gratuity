//
//  GratuitousiOSConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/3/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

class GratuitousiOSConnectivityManager: NSObject, WCSessionDelegate {
    
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
        // send the new preferences to the watch
        if let dictionary = notification?.userInfo as? [String : AnyObject],
            let session = self.session where session.watchAppInstalled == true {
                do {
                    print("GratuitousWatchConnectivityManager<iOS>: GratuitousPropertyListPreferencesWereChanged Fired: \(notification?.userInfo)")
                    try session.updateApplicationContext(dictionary)
                } catch {
                    print("GratuitousWatchConnectivityManager<iOS>: Failed to update application context with error: \(error)")
                }
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWereReceived", object: self, userInfo: applicationContext)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
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
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}