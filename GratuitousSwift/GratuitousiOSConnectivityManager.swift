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

@available(iOS 9, *)
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
        if let overrideCurrencySymbol = dictionary["overrideCurrencySymbol"] as? NSNumber,
            let currencySymbolsNeeded = dictionary["currencySymbolsNeeded"] as? NSNumber,
            let currencySign = CurrencySign(rawValue: overrideCurrencySymbol.integerValue)
            where currencySymbolsNeeded.boolValue == true {
                let currencyStringImageGenerator = GratuitousCurrencyStringImageGenerator()
                if let tuple = currencyStringImageGenerator.generateCurrencySymbolsForCurrencySign(currencySign) {
                    print("CurrencySymbols Needed on Watch: Sending URL: \(tuple.url.path!)")
                    session.transferFile(tuple.url, metadata: ["fileName" : tuple.fileName])
                    // assume the file is going to make it
                    dictionary["currencySymbolsNeeded"] = NSNumber(bool: false)
                }
        }
        replyHandler(dictionary)
    }
    
    func updateWatchApplicationContext(context: [String : AnyObject]?) {
        guard let context = context else { return }
        if let session = self.session where session.paired == true && session.watchAppInstalled {
            do {
                print("GratuitousWatchConnectivityManager<iOS>: Updating Watch Application Context")
                try session.updateApplicationContext(context)
            } catch {
                NSLog("GratuitousWatchConnectivityManager<iOS>: Failed Updating iOS Application Context: \(error)")
            }
        } else {
            NSLog("GratuitousWatchConnectivityManager<iOS>: Did Not Attempt to Update Watch. No Watch Paired.")
        }
    }
    
    func transferBulkData(tuples: [(url: NSURL, fileName: String)]) {
        if let session = self.session where session.paired == true && session.watchAppInstalled == true {
            for tuple in tuples {
                session.transferFile(tuple.url, metadata: ["fileName" : tuple.fileName])
            }
        }
    }

    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        self.delegate?.receivedContextFromWatch(applicationContext)
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print("GratuitousWatchConnectivityManager: didFinishFileTransfer: \(fileTransfer) with error: \(error)")
    }

}