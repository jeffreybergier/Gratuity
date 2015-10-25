//
//  GratuitousUserDefaultsDiskManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import XCGLogger

class GratuitousUserDefaultsDiskManager {
    
    private var applicationPreferences: GratuitousUserDefaults {
        get {
            #if os(watchOS)
                return GratuitousWatchApplicationPreferences.sharedInstance.preferences
            #elseif os(iOS)
                return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences
            #endif
        }
    }
    
    private let manager = JSBDictionaryPLISTPreferenceManager()
    private let log = XCGLogger.defaultInstance()
    
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
    
    func writeUserDefaultsToPreferencesFile(defaults: GratuitousUserDefaults) {
        let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
        dispatch_async(backgroundQueue) {
            do {
                try self.manager.writePreferencesDictionary(defaults.dictionaryCopyForKeys(.ForDisk), toLocation: .PreferencesPLISTFileWithinPreferencesURL)
            } catch {
                self.log.error("Failed to write preferences to disk with error: \(error)")
            }
        }
    }
    
    func dictionaryFromPreferencesFile() -> NSDictionary? {
        do {
            return try self.manager.dictionaryByReadingPLISTFromDiskLocation(.PreferencesPLISTFileWithinPreferencesURL)
        } catch {
            log.error("Failed to read preferences from disk: \(error)")
            return .None
        }
    }
}

extension GratuitousUserDefaults {
    static func defaultsFromDisk() -> GratuitousUserDefaults {
        let manager = GratuitousUserDefaultsDiskManager()
        return GratuitousUserDefaults(dictionary: manager.dictionaryFromPreferencesFile())
    }
}