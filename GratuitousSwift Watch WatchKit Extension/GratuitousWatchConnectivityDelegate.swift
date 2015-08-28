//
//  GratuitousWatchConnectivityDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/27/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import UIKit
import WatchConnectivity

@available(watchOS 2, *)
class GratuitousWatchConnectivityDelegate: NSObject, WCSessionDelegate {
    
    var wcSessionIsSupported = false
    
    override init() {
        print("GratuitousWatchConnectivityDelegate: Init")
        super.init()
        if WCSession.isSupported() {
            self.wcSessionIsSupported = true
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            print("GratuitousWatchConnectivityDelegate: Init Finished with Session: \(session)")
        }
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        print("GratuitousWatchConnectivityDelegate: sessionWatchStateDidChange: \(session)")
    }
    
    /** -------------------------- Background Transfers ------------------------- */
    
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityDelegate: didReceiveApplicationContext: \(applicationContext)")
    }
    
    /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        print("GratuitousWatchConnectivityDelegate: didFinishUserInfoTransfer: \(userInfoTransfer)")
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("GratuitousWatchConnectivityDelegate: didReceiveUserInfo: \(userInfo)")
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("GratuitousWatchConnectivityDelegate: didReceiveFile: \(file)")
        if let data = NSData(contentsOfURL: file.fileURL) {
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let dataURL = documentsURL.URLByAppendingPathComponent("dollarAmounts.data")
            data.writeToURL(dataURL, atomically: true)
            print("Data written to disk on the watch")
        }
    }

    
}
