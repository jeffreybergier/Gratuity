//
//  GratuitousiOSConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/3/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

protocol GratuitousiOSConnectivityManagerDelegate: class {
    func receivedContextFromWatch(context: [String : AnyObject])
}

class GratuitousiOSConnectivityManager: NSObject, WCSessionDelegate {
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
        }()
    
    weak var delegate: GratuitousiOSConnectivityManagerDelegate? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
            }
        }
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
    
    private var skipNextContextReception = false
    
    func updateWatchApplicationContext(context: [String : AnyObject]) {
        if let session = self.session where session.paired == true && self.skipNextContextReception == false {
            do {
                print("GratuitousWatchConnectivityManager<iOS>: Updating Watch Application Context")
                try session.updateApplicationContext(context)
            } catch {
                NSLog("GratuitousWatchConnectivityManager<iOS>: Failed Updating iOS Application Context: \(error)")
            }
        } else {
            self.skipNextContextReception = false
            NSLog("GratuitousWatchConnectivityManager<iOS>: Did Not Attempt to Update Watch. No Watch Paired.")
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        self.skipNextContextReception = true
        self.delegate?.receivedContextFromWatch(applicationContext)
    }
}