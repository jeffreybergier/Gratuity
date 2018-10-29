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
    case NotSupported
    case NotPaired
    case PairedWatchAppInstalled
    case PairedWatchAppNotInstalled
    case NotReachableWatchAppInstalled
    case NotReachableWatchAppNotInstalled
    case ReachableWatchAppInstalled
    case ReachableWatchAppNotInstalled
}

@available (iOS 9, watchOS 2, *)
protocol JSBWatchConnectivityContextDelegate: class {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
}

@available (iOS 9, watchOS 2, *)
protocol JSBWatchConnectivityMessageDelegate: class {
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void)
}

@available (iOS 9, watchOS 2, *)
protocol JSBWatchConnectivityUserInfoSenderDelegate: class {
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?)
}

@available (iOS 9, watchOS 2, *)
protocol JSBWatchConnectivityUserInfoReceiverDelegate: class {
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject])
}

@available (iOS 9, watchOS 2, *)
protocol JSBWatchConnectivityFileTransferSenderDelegate: class {
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?)
}

@available (iOS 9, watchOS 2, *)
protocol JSBWatchConnectivityFileTransferReceiverDelegate: class {
    func session(session: WCSession, didReceiveFile file: WCSessionFile)
}

@available (iOS 9, watchOS 2, *)
class JSBWatchConnectivityManager: NSObject, WCSessionDelegate {
    
    // MARK: Session Activation
    
    override init() {
        super.init()
        
        self.session?.delegate = self
        self.session?.activateSession()
    }
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var contextDelegate: JSBWatchConnectivityContextDelegate?
    weak var messageDelegate: JSBWatchConnectivityMessageDelegate?
    weak var userInfoSenderDelegate: JSBWatchConnectivityUserInfoSenderDelegate?
    weak var userInfoReceiverDelegate: JSBWatchConnectivityUserInfoReceiverDelegate?
    weak var fileTransferSenderDelegate: JSBWatchConnectivityFileTransferSenderDelegate?
    weak var fileTransferReceiverDelegate: JSBWatchConnectivityFileTransferReceiverDelegate?
    
    // MARK: iOS App State For Watch
    
    var watchState: WatchState = .NotSupported
    
    /** Called when any of the Watch state properties change */
    #if os(iOS)
    func sessionWatchStateDidChange(session: WCSession) {
        var newState = WatchState.NotSupported
        if session.paired == true {
            if session.watchAppInstalled == true {
                newState = .PairedWatchAppInstalled
            } else {
                newState = .PairedWatchAppNotInstalled
            }
        } else {
            newState = .NotPaired
        }
        if session.reachable == true {
            if session.watchAppInstalled == true {
                newState = .ReachableWatchAppInstalled
            } else {
                newState = .ReachableWatchAppNotInstalled
            }
        } else {
            if session.watchAppInstalled == true {
                newState = .NotReachableWatchAppInstalled
            } else {
                newState = .NotReachableWatchAppNotInstalled
            }
        }
        self.watchState = newState
    }
    #endif
    
    // MARK: Incoming Interactive Messaging
    
    /** ------------------------- Interactive Messaging ------------------------- */
    
    /** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
    func sessionReachabilityDidChange(session: WCSession) {
        if session.reachable == true {
            self.watchState = .ReachableWatchAppInstalled
        } else {
            self.watchState = .NotReachableWatchAppInstalled
        }
    }
    
    /** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let delegate = self.messageDelegate {
            delegate.session(session, didReceiveMessage: message, replyHandler: replyHandler)
        } else {
            log?.info("MessageDelegate Not Set: Ignoring Incoming Message: \(message)")
        }
    }
    
    /** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        if let delegate = self.messageDelegate {
            delegate.session(session, didReceiveMessageData: messageData, replyHandler: replyHandler)
        } else {
            log?.info("MessageDelegate Not Set: Ignoring Incoming Message Data: \(messageData)")
        }
    }
    
    // MARK: Incoming Background Transfer
    
    /** -------------------------- Background Transfers ------------------------- */
    
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let delegate = self.contextDelegate {
            delegate.session(session, didReceiveApplicationContext: applicationContext)
        } else {
            log?.info("ContextDelegate Not Set: Ignoring Incoming Application Context: \(applicationContext)")
        }
    }
    
    /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        if let delegate = self.userInfoSenderDelegate {
            delegate.session(session, didFinishUserInfoTransfer: userInfoTransfer, error: error)
        } else {
            log?.info("UserInfoSenderDelegate Not Set. Ignoring UserInfo Transfer Finished: \(userInfoTransfer) with Error: \(error)")
        }
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        if let delegate = self.userInfoReceiverDelegate {
            delegate.session(session, didReceiveUserInfo: userInfo)
        } else {
            log?.info("UserInfoReceiverDelegate Not Set. Ignoring Incoming UserInfo: \(userInfo)")
        }
    }
    
    /** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        if let delegate = self.fileTransferSenderDelegate {
            delegate.session(session, didFinishFileTransfer: fileTransfer, error: error)
        } else {
            log?.info("FileTransferSenderDelegate Not Set. Ignoring File Transfer Finished: \(fileTransfer) with Error: \(error)")
        }
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        if let delegate = self.fileTransferReceiverDelegate {
            delegate.session(session, didReceiveFile: file)
        } else {
            log?.info("FileTransferReceiverDelegate Not Set. Ignoring Incoming File: \(file)")
        }
    }
}



