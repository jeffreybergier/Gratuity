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
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWereReceived", object: self, userInfo: applicationContext)
    }
}