//
//  AssetVerificationInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/28/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

protocol GratuitousWatchConnectivityDelegate: class {
    func dataOnDiskChanged()
}

class GratuitousWatchConnectivityManager: NSObject, WCSessionDelegate {
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var interfaceControllerDelegate: GratuitousWatchConnectivityDelegate? {
        didSet {
            if let session = self.session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        let fileName = file.metadata!["CurrencyCode"] as! String
        if let data = NSData(contentsOfURL: file.fileURL) {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let dataURL = documentsURL.URLByAppendingPathComponent("\(fileName)Currency.data")
            data.writeToURL(dataURL, atomically: true)
            self.interfaceControllerDelegate?.dataOnDiskChanged()
        }
    }
    
    func requestDataFromPhone() {
        let session = WCSession.defaultSession()
        if session.reachable {
            session.sendMessage([:], replyHandler: .None, errorHandler: .None)
        }
    }
}