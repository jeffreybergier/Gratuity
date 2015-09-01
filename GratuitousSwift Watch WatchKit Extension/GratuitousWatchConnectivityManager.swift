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
    func dataOnDiskChanged()
    var dataSource:GratuitousWatchDataSource { get }
}

class GratuitousWatchConnectivityManager: NSObject, WCSessionDelegate {
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var interfaceControllerDelegate: WatchConnectivityDelegate? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
}