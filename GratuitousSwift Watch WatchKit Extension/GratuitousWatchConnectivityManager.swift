//
//  AssetVerificationInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/28/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

protocol GratuitousWatchConnectivityManagerDelegate: class {
    func receivedContextFromiOS(context: [String : AnyObject])
    func receivedCurrencySymbolPromiseFromiOS()
    func receivedCurrencySymbolsFromiOS()
}

class GratuitousWatchConnectivityManager: NSObject, WCSessionDelegate {
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
        }()
    
    weak var delegate: GratuitousWatchConnectivityManagerDelegate? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    func updateiOSApplicationContext(context: [String : AnyObject]) {
        if let session = self.session {
            do {
                print("GratuitousWatchConnectivityManager<WatchOS>: Updating iOS Application Context")
                try session.updateApplicationContext(context)
            } catch {
                print("GratuitousWatchConnectivityManager<WatchOS>: Failed Updating iOS Application Context: \(error)")
            }
        }
    }
    
    func requestDataFromiOSDevice(dataNeeded: GratuitousPropertyListPreferences.DataNeeded) {
        if let session = session {
            switch dataNeeded {
            case .CurrencySymbols(let sign):
                print("GratuitousWatchConnectivityManager<WatchOS>: Currency Symbols Needed. Requesting from iOS Device")
                let message = [
                    "currencySymbolsNeeded" : NSNumber(bool: true),
                    "overrideCurrencySymbol" : NSNumber(integer: sign.rawValue),
                ]
                session.sendMessage(message,
                    replyHandler: { reply in
                        if let currencySymbolsNeeded = reply["currencySymbolsNeeded"] as? NSNumber where currencySymbolsNeeded.boolValue == false {
                            self.delegate?.receivedCurrencySymbolPromiseFromiOS()
                        }
                    }, errorHandler: { error in
                        print("GratuitousWatchConnectivityManager<WatchOS>: Error sending message to iOS app)")
                })
            }
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        self.delegate?.receivedContextFromiOS(applicationContext)
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("GratuitousWatchConnectivityManager Watch Did Receive File: \(file)")
        if let originalFileName = file.metadata?["fileName"] as? String {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let dataURL = documentsURL.URLByAppendingPathComponent(originalFileName)
            do {
                let data = try NSData(contentsOfURL: file.fileURL, options: .DataReadingMappedIfSafe)
                try data.writeToURL(dataURL, options: .AtomicWrite)
                self.delegate?.receivedCurrencySymbolsFromiOS()
            } catch {
                NSLog("GratuitousWatchConnectivityManager: didReceiveFile: Failed with error: \(error)")
            }
        }
    }
}