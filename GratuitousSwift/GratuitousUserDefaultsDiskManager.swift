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
    
    private let manager = JSBDictionaryPLISTPreferenceManager()
    private let log = XCGLogger.defaultInstance()
    
    func writeUserDefaultsToPreferencesFile(defaults: GratuitousUserDefaults) {
        do {
            try self.manager.writePreferencesDictionary(defaults.dictionaryCopyForKeys(.All), toLocation: .PreferencesPLISTFileWithinPreferencesURL)
        } catch {
            log.error("Failed to write to disk with error: \(error)")
        }
    }
    
    func dictionaryFromPreferencesFile() -> NSDictionary? {
        do {
            return try self.manager.dictionaryByReadingPLISTFromDiskLocation(.PreferencesPLISTFileWithinPreferencesURL)
        } catch {
            log.error("Failed to read dictionary from disk: \(error)")
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