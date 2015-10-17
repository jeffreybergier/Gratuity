//
//  GratuitousUserDefaultsDiskManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation
import XCGLogger

class GratuitousUserDefaultsDiskManager {
    
    private var applicationPreferences: GratuitousUserDefaults {
        get {
            #if os(watchOS)
                return GratuitousWatchApplicationPreferences.sharedInstance.localPreferences
            #elseif os(iOS)
                return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).localPreferences
            #endif
        }
    }
    
    private let manager = JSBDictionaryPLISTPreferenceManager()
    private let log = XCGLogger.defaultInstance()
    
    private var writeTimerAlreadySet = false
    
    func writeUserDefaultsToPreferencesFileWithRateLimit(defaults: GratuitousUserDefaults) {
        if self.writeTimerAlreadySet == false {
            self.writeTimerAlreadySet = true
            NSTimer.scheduleWithDelay(3.0) { timer in
                self.writeTimerAlreadySet = false
                self.writeUserDefaultsToPreferencesFile(self.applicationPreferences)
            }
        }
    }
    
    func writeUserDefaultsToPreferencesFile(defaults: GratuitousUserDefaults) {
        do {
            try self.manager.writePreferencesDictionary(defaults.dictionaryCopyForKeys(.AllForDisk), toLocation: .PreferencesPLISTFileWithinPreferencesURL)
        } catch {
            log.error("Failed to write preferences to disk with error: \(error)")
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