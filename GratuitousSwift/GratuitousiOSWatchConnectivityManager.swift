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
            }
        }
    }
}
