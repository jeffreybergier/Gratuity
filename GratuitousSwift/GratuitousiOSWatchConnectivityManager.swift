//
//  GratuitousiOSWatchConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/30/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

protocol WatchConnectivityDelegate: class {
    func generateNewCurrencySymbols() -> (url: NSURL, currencyCode: String)
    var defaultsManager: GratuitousPropertyListPreferences { get }
}

class GratuitousiOSWatchConnectivityManager: NSObject, WCSessionDelegate {
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var watchConnectivityDelegate: WatchConnectivityDelegate? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "propertyListWasDirtied:", name: "GratuitousPropertyListPreferencesWasDirtied", object: .None)
            }
        }
    }
    
    @objc private func propertyListWasDirtied(notification: NSNotification?) {
        if let session = self.session,
            let delegate = self.watchConnectivityDelegate {
                print("GratuitousiOSWatchConnectivityManager: Sending Message from iOS to Watch")
                session.sendMessage(delegate.defaultsManager.dictionaryVersion,
                        replyHandler: { reply in
                            print("GratuitousiOSWatchConnectivityManager: Reply Recieved from Watch: \(reply)")
                        },
                        errorHandler: { error in
                            print("GratuitousiOSWatchConnectivityManager: Error: \(error)")
                            session.transferFile(GratuitousPropertyListPreferences.locationOnDisk, metadata: ["FileType" : "Preferences"])
                    })
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("GratuitousiOSWatchConnectivityManager: didReceiveMessage: \(message)")
        var replyDictionary: [String : AnyObject] = [
            "Hello" : "Hellos from iOS",
            "DataSaved" : NSNumber(bool: false)
        ]
        
        if let delegate = self.watchConnectivityDelegate where delegate.defaultsManager.replaceStateWithDictionary(message) == true {
            if delegate.defaultsManager.writeToDisk() == true {
                replyDictionary["DataSaved"] = NSNumber(bool: true)
            }
        }
        
        if let currencySymbolsNeeded = message[GratuitousPropertyListPreferences.Keys.currencySymbolsNeeded] as? NSNumber,
            let delegate = self.watchConnectivityDelegate
            where currencySymbolsNeeded.boolValue == true {
                print("GratuitousiOSWatchConnectivityManager: New Currency Symbols needed. Sending them over.")
                let result = delegate.generateNewCurrencySymbols()
                session.transferFile(result.url, metadata: [
                    "FileType" : "CurrencyData",
                    "CurrencySymbol" : result.currencyCode
                    ])
                replyDictionary["CurrencySign"] = "Sending Over New \(result.currencyCode) Symbols..."
        }
        
        replyHandler(replyDictionary)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
