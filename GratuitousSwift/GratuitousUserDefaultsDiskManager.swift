//
//  GratuitousUserDefaultsDiskManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaultsDiskManager {
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get {
            #if os(watchOS)
                return GratuitousWatchApplicationPreferences.sharedInstance.preferences
            #elseif os(iOS)
                return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences
            #endif
        }
    }
    
    fileprivate let manager = JSBDictionaryPLISTPreferenceManager()
    
    //private var writeTimerAlreadySet = false
    
    // This should work, but it doesn't on the watch :(
    /*
    func writeUserDefaultsToPreferencesFileWithRateLimit(defaults: GratuitousUserDefaults) {
        if self.writeTimerAlreadySet == false {
            self.writeTimerAlreadySet = true
            NSTimer.scheduleWithDelay(3.0) { timer in
                self.writeTimerAlreadySet = false
                self.writeUserDefaultsToPreferencesFile(self.applicationPreferences)
            }
        }
    }
    */
    
    func writeUserDefaultsToPreferencesFile(_ defaults: GratuitousUserDefaults) {
        let backgroundQueue = DispatchQueue.global(qos: .userInteractive)
        backgroundQueue.async {
            do {
                try self.manager.writePreferencesDictionary(defaults.dictionaryCopyForKeys(.forDisk) as NSDictionary,
                                                            toLocation: .preferencesPLISTFileWithinPreferencesURL,
                                                            protection: .completeFileProtection)
            } catch {
                log?.error("Failed to write preferences to disk with error: \(error)")
            }
        }
    }
    
    func dictionaryFromPreferencesFile() -> NSDictionary? {
        do {
            return try self.manager.dictionaryByReadingPLISTFromDiskLocation(.preferencesPLISTFileWithinPreferencesURL)
        } catch {
            log?.error("Failed to read preferences from disk: \(error)")
            return .none
        }
    }
}

extension GratuitousUserDefaults {
    static func defaultsFromDisk() -> GratuitousUserDefaults {
        let manager = GratuitousUserDefaultsDiskManager()
        return GratuitousUserDefaults(dictionary: manager.dictionaryFromPreferencesFile())
    }
}
