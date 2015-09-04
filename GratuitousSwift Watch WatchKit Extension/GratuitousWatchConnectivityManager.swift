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
        // send the new preferences to the Phone
        if let dictionary = notification?.userInfo as? [String : AnyObject],
            let session = self.session {
                do {
                    print("GratuitousWatchConnectivityManager<WatchOS>: GratuitousPropertyListPreferencesWereChanged Fired: \(notification?.userInfo)")
                    try session.updateApplicationContext(dictionary)
                } catch {
                    print("GratuitousWatchConnectivityManager<WatchOS>: Failed to update application context with error: \(error)")
                }
        }
        
        // if currency symbols are missing, wake up the phone and request new ones.
        if let dictionary = notification?.userInfo as? [String : AnyObject],
            let session = self.session,
            let currencySymbolsNeeded = dictionary["currencySymbolsNeeded"] as? NSNumber where currencySymbolsNeeded.boolValue == true {
                print("<WatchOS>: CurrencySymbols Needed on Watch. Requesting from iOS.")
                session.sendMessage(dictionary,
                    replyHandler: { reply in
                        if let currencySymbolsNeeded = reply["currencySymbolsNeeded"] as? NSNumber where currencySymbolsNeeded.boolValue == false {
                            GratuitousWatchDataSource.sharedInstance.defaultsManager.currencySymbolsNeeded = false
                        }
                    }, errorHandler: { error in
                        print("GratuitousWatchConnectivityManager<WatchOS>: Error sending message to iOS app: \(dictionary)")
                })
                
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWereReceived", object: self, userInfo: applicationContext)
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("GratuitousWatchConnectivityManager Watch Did Receive File: \(file)")
        if let originalFileName = file.metadata?["fileName"] as? String {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let dataURL = documentsURL.URLByAppendingPathComponent(originalFileName)
            do {
                let data = try NSData(contentsOfURL: file.fileURL, options: .DataReadingMappedIfSafe)
                try data.writeToURL(dataURL, options: .AtomicWrite)
                GratuitousWatchDataSource.sharedInstance.defaultsManager.currencySymbolsNeeded = false
                NSNotificationCenter.defaultCenter().postNotificationName("overrideCurrencySymbolUpdatedOnDisk", object: self, userInfo: nil)
            } catch {
                NSLog("GratuitousWatchConnectivityManager: didReceiveFile: Failed with error: \(error)")
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}