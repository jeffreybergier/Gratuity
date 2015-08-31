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
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "propertyListWasDirtied:", name: "GratuitousPropertyListPreferencesWasDirtied", object: .None)
            }
        }
    }
    
    @objc private func propertyListWasDirtied(notification: NSNotification?) {
        if let session = self.session,
            let delegate = self.interfaceControllerDelegate {
                print("GratuitousWatchConnectivityManager: Sending Message from Watch to iOS")
                session.sendMessage(delegate.dataSource.defaultsManager.dictionaryVersion,
                    replyHandler: { reply in
                        print("GratuitousWatchConnectivityManager: Reply Recieved from iOS: \(reply)")
                        if let dataSaved = reply["DataSaved"] as? NSNumber
                        where dataSaved.boolValue == true {
                            self.interfaceControllerDelegate?.dataSource.defaultsManager.dirtied = false
                        }
                    },
                    errorHandler: { error in
                        print("GratuitousWatchConnectivityManager: Error: \(error)")
                })
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("GratuitousWatchConnectivityManager: didReceiveMessage: \(message)")
        var replyDictionary: [String : AnyObject] = [
            "Hello" : "Hellos from WatchOS",
            "DataSaved" : NSNumber(bool: false)
        ]
        if let delegate = self.interfaceControllerDelegate where delegate.dataSource.defaultsManager.replaceStateWithDictionary(message) == true {
            if delegate.dataSource.defaultsManager.writeToDisk() == true {
                replyDictionary["DataSaved"] = NSNumber(bool: true)
            }
        }
        replyHandler(replyDictionary)
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        if let metadata = file.metadata,
            let fileType = metadata["FileType"] as? String {
                switch fileType {
                case "Preferences":
                    break
                case "CurrencyData":
                    if let currencyCode = metadata["CurrencyCode"] as? String,
                        let data = NSData(contentsOfURL: file.fileURL) {
                            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                            let dataURL = documentsURL.URLByAppendingPathComponent("\(currencyCode)Currency.data")
                            data.writeToURL(dataURL, atomically: true)
                            self.interfaceControllerDelegate?.dataSource.defaultsManager.currencySymbolsNeeded = false
                            self.interfaceControllerDelegate?.dataOnDiskChanged()
                    }
                default:
                    break
                }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}