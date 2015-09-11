//
//  GratuitousiOSConnectivityManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/3/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import WatchKit
import WatchConnectivity

protocol GratuitousiOSConnectivityManagerDelegate: class {
    func receivedContextFromWatch(context: [String : AnyObject])
}

class GratuitousiOSConnectivityManager: NSObject, WCSessionDelegate {
    
    let session: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    weak var delegate: GratuitousiOSConnectivityManagerDelegate? {
        didSet {
            if let session = self.session {
                session.addObserver(self, forKeyPath: "watchAppInstalled", options: .New, context: &kvoContext)
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    private var kvoContext = 0
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
            if let newValue = change?["new"] as? NSNumber {
                print("GratuitousiOSConnectivityManager: Watch App Installed Changed to \(newValue.boolValue)")
            }
        }
    }
        
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        var dictionary = message
        if let overrideCurrencySymbol = dictionary["overrideCurrencySymbol"] as? NSNumber,
            let currencySymbolsNeeded = dictionary["currencySymbolsNeeded"] as? NSNumber,
            let currencySign = CurrencySign(rawValue: overrideCurrencySymbol.integerValue)
            where currencySymbolsNeeded.boolValue == true {
                let currencyStringImageGenerator = GratuitousCurrencyStringImageGenerator()
                if let tuple = currencyStringImageGenerator.generateCurrencySymbolsForCurrencySign(currencySign),
                    session = self.session {
                        print("CurrencySymbols Needed on Watch for CurrencySign: \(currencySign). Sending...")
                        session.transferFile(tuple.url, metadata: ["fileName" : tuple.fileName])
                        // assume the file is going to make it
                        dictionary["currencySymbolsNeeded"] = NSNumber(bool: false)
                }
        }
        replyHandler(dictionary)
    }
    
    func updateWatchApplicationContext(context: [String : AnyObject]) {
        if let session = self.session where session.paired == true {
            do {
                print("GratuitousWatchConnectivityManager<iOS>: Updating Watch Application Context")
                try session.updateApplicationContext(context)
            } catch {
                NSLog("GratuitousWatchConnectivityManager<iOS>: Failed Updating iOS Application Context: \(error)")
            }
        } else {
            NSLog("GratuitousWatchConnectivityManager<iOS>: Did Not Attempt to Update Watch. No Watch Paired.")
        }
    }
    
//    func transferBulkData(tuples: [(url: NSURL, fileName: String)]) {
//        let watchAppInstalled = session?.watchAppInstalled
//        if let session = self.session {//where session.paired == true && session.watchAppInstalled == true {
//            print(session.outstandingFileTransfers)
//            for (index, tuple) in tuples.enumerate() {
//                let indexDouble = Double(index)
//                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(indexDouble * Double(NSEC_PER_SEC)))
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    session.transferFile(tuple.url, metadata: ["fileName" : tuple.fileName])
//                    print(session.outstandingFileTransfers)
//                }
//            }
//        }
//    }
    
    //on first run make a last ditch effort to send a lot of currency symbols to the watch
    //this may prevent waiting on the watch later
//    if let dataSource = self.dataSource,
//    let session = dataSource.watchConnectivityManager.session {
//        let paired = session.paired
//        let installed = session.watchAppInstalled
//        let firstRun = dataSource.defaultsManager.iOSFirstRun
//        dataSource.defaultsManager.iOSFirstRun = true
//        if session.paired == true && session.watchAppInstalled == true && dataSource.defaultsManager.iOSFirstRun == true {
//            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
//            dispatch_async(backgroundQueue) {
//                let generator = GratuitousCurrencyStringImageGenerator()
//                if let files = generator.generateAllCurrencySymbols() {
//                    dataSource.watchConnectivityManager.transferBulkData(files)
//                }
//            }
//        }
//    }
    
    //    func generateAllCurrencySymbols() -> [(url: NSURL, fileName: String)]? {
    //        let dataSource = GratuitousiOSDataSource(use: .Temporary)
    //        var tuples = [(url: NSURL, fileName: String)]()
    //        for i in 0 ..< 10 {
    //            if let currencySign = CurrencySign(rawValue: i) {
    //                dataSource.defaultsManager.overrideCurrencySymbol = currencySign
    //                if let url = self.generateNewCurrencySymbolsFromConfiguredCurrencyFormatter(dataSource) {
    //                    if let lastPathComponent = url.lastPathComponent {
    //                        tuples += [(url: url, fileName: lastPathComponent)]
    //                    }
    //                }
    //            } else {
    //                break
    //            }
    //        }
    //        if tuples.isEmpty == false { return tuples } else { return .None }
    //    }


    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousWatchConnectivityManager: didReceiveApplicationContext: \(applicationContext)")
        self.delegate?.receivedContextFromWatch(applicationContext)
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print("GratuitousWatchConnectivityManager: didFinishFileTransfer with error: \(error)")
    }

}