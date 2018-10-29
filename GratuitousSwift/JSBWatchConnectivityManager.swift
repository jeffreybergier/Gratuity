//
//  JSBWatchConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/17/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

/** ----------------------------- WCSessionDelegate -----------------------------
*  The session calls the delegate methods when content is received and session
*  state changes. All delegate methods will be called on the same queue. The
*  delegate queue is a non-main serial queue. It is the client's responsibility
*  to dispatch to another queue if neccessary.
*/

import WatchConnectivity

enum WatchState {
    case notSupported
    case notPaired
    case pairedWatchAppInstalled
    case pairedWatchAppNotInstalled
    case notReachableWatchAppInstalled
    case notReachableWatchAppNotInstalled
    case reachableWatchAppInstalled
    case reachableWatchAppNotInstalled
}

protocol JSBWatchConnectivityContextDelegate: class {
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
}

protocol JSBWatchConnectivityMessageDelegate: class {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void)
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Swift.Void)
}

protocol JSBWatchConnectivityUserInfoSenderDelegate: class {
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?)
}

protocol JSBWatchConnectivityUserInfoReceiverDelegate: class {
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any])
}

protocol JSBWatchConnectivityFileTransferSenderDelegate: class {
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?)
}

protocol JSBWatchConnectivityFileTransferReceiverDelegate: class {
    func session(_ session: WCSession, didReceive file: WCSessionFile)
}

class JSBWatchConnectivityManager: NSObject, WCSessionDelegate {
    
    // MARK: Session Activation
    
    override init() {
        super.init()
        
        self.session?.delegate = self
        self.session?.activate()
    }
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.default()
        } else {
            return .none
        }
    }()
    
    weak var contextDelegate: JSBWatchConnectivityContextDelegate?
    weak var messageDelegate: JSBWatchConnectivityMessageDelegate?
    weak var userInfoSenderDelegate: JSBWatchConnectivityUserInfoSenderDelegate?
    weak var userInfoReceiverDelegate: JSBWatchConnectivityUserInfoReceiverDelegate?
    weak var fileTransferSenderDelegate: JSBWatchConnectivityFileTransferSenderDelegate?
    weak var fileTransferReceiverDelegate: JSBWatchConnectivityFileTransferReceiverDelegate?
    
    // MARK: iOS App State For Watch
    
    var watchState: WatchState = .notSupported
    
    /** Called when any of the Watch state properties change */
    #if os(iOS)
    func sessionWatchStateDidChange(_ session: WCSession) {
        var newState = WatchState.notSupported
        if session.isPaired == true {
            if session.isWatchAppInstalled == true {
                newState = .pairedWatchAppInstalled
            } else {
                newState = .pairedWatchAppNotInstalled
            }
        } else {
            newState = .notPaired
        }
        if session.isReachable == true {
            if session.isWatchAppInstalled == true {
                newState = .reachableWatchAppInstalled
            } else {
                newState = .reachableWatchAppNotInstalled
            }
        } else {
            if session.isWatchAppInstalled == true {
                newState = .notReachableWatchAppInstalled
            } else {
                newState = .notReachableWatchAppNotInstalled
            }
        }
        self.watchState = newState
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    #endif
    
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    // MARK: Incoming Interactive Messaging
    
    /** ------------------------- Interactive Messaging ------------------------- */
    
    /** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable == true {
            self.watchState = .reachableWatchAppInstalled
        } else {
            self.watchState = .notReachableWatchAppInstalled
        }
    }
    
    /** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let delegate = self.messageDelegate {
            delegate.session(session, didReceiveMessage: message, replyHandler: replyHandler)
        } else {
            log?.info("MessageDelegate Not Set: Ignoring Incoming Message: \(message)")
        }
    }
    
    /** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        if let delegate = self.messageDelegate {
            delegate.session(session, didReceiveMessageData: messageData, replyHandler: replyHandler)
        } else {
            log?.info("MessageDelegate Not Set: Ignoring Incoming Message Data: \(messageData)")
        }
    }
    
    // MARK: Incoming Background Transfer
    
    /** -------------------------- Background Transfers ------------------------- */
    
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let delegate = self.contextDelegate {
            delegate.session(session, didReceiveApplicationContext: applicationContext as [String : AnyObject])
        } else {
            log?.info("ContextDelegate Not Set: Ignoring Incoming Application Context: \(applicationContext)")
        }
    }
    
    /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let delegate = self.userInfoSenderDelegate {
            delegate.session(session, didFinish: userInfoTransfer, error: error)
        } else {
            log?.info("UserInfoSenderDelegate Not Set. Ignoring UserInfo Transfer Finished: \(userInfoTransfer) with Error: \(String(describing: error))")
        }
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        if let delegate = self.userInfoReceiverDelegate {
            delegate.session(session, didReceiveUserInfo: userInfo as [String : AnyObject])
        } else {
            log?.info("UserInfoReceiverDelegate Not Set. Ignoring Incoming UserInfo: \(userInfo)")
        }
    }
    
    /** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let delegate = self.fileTransferSenderDelegate {
            delegate.session(session, didFinish: fileTransfer, error: error)
        } else {
            log?.info("FileTransferSenderDelegate Not Set. Ignoring File Transfer Finished: \(fileTransfer) with Error: \(String(describing: error))")
        }
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        if let delegate = self.fileTransferReceiverDelegate {
            delegate.session(session, didReceive: file)
        } else {
            log?.info("FileTransferReceiverDelegate Not Set. Ignoring Incoming File: \(file)")
        }
    }
}



