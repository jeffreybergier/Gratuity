//
//  GratuitousWatchConnectivityDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/27/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchConnectivity

@available(iOS 9, *)
class GratuitousiOSConnectivityDelegate: NSObject, WCSessionDelegate {
    
    var wcSessionIsSupported = false
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            self.wcSessionIsSupported = true
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        print("GratuitousiOSConnectivityDelegate: sessionWatchStateDidChange: \(session)")
    }
    
    func sendDataAtURL(dataURL: NSURL) {
        WCSession.defaultSession().transferFile(dataURL, metadata: .None)
    }
    
    /** -------------------------- Background Transfers ------------------------- */
    
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousiOSConnectivityDelegate: didReceiveApplicationContext: \(applicationContext)")
    }
    
    /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        print("GratuitousiOSConnectivityDelegate: didFinishUserInfoTransfer: \(userInfoTransfer)")
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("GratuitousiOSConnectivityDelegate: didReceiveUserInfo: \(userInfo)")
    }
    
    /** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print("GratuitousiOSConnectivityDelegate: didFinishFileTransfer: \(fileTransfer)")
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("GratuitousiOSConnectivityDelegate: didReceiveFile: \(file)")
    }

}