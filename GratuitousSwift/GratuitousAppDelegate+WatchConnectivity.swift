//
//  GratuitousAppDelegate+WatchConnectivity.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

extension GratuitousAppDelegate {
    @available (iOS 9, *)
    func transferBulkCurrencySymbolsIfNeeded() {
        //on first run make a last ditch effort to send a lot of currency symbols to the watch
        //this may prevent waiting on the watch later
        if let watchConnectivityManager = self.watchConnectivityManager as? GratuitousiOSConnectivityManager,
            let session = watchConnectivityManager.session
            where session.paired == true && session.watchAppInstalled == true {
                if self.defaultsManager.freshWatchAppInstall == true {
                    self.defaultsManager.freshWatchAppInstall = false
                    let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
                    dispatch_async(backgroundQueue) {
                        let generator = GratuitousCurrencyStringImageGenerator()
                        if let files = generator.generateAllCurrencySymbols() {
                            watchConnectivityManager.transferBulkData(files)
                        }
                    }
                }
        } else {
            // watch app not installed or watch not paired
            self.defaultsManager.freshWatchAppInstall = true
        }
    }

}
