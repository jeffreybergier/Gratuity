//
//  JSBDictionaryPLISTPreferenceManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class JSBDictionaryPLISTPreferenceManager {
    
    private let fileManager = NSFileManager.defaultManager()
    
    func writePreferencesDictionary(dictionary: NSDictionary, toLocation location: Location) throws {
        let fullURL: NSURL
        switch location {
        case .PreferencesPLISTFileWithinPreferencesURL:
            fullURL = self.preferencesPLISTFileURLWithinPreferencesURL
        case .AppDirectoryWithinAppSupportDirectory(let lastPathComponent):
            fullURL = self.appDirectoryWithinAppSupportURL.URLByAppendingPathComponent(lastPathComponent + ".plist")
        case .CachesDirectory(let lastPathComponent):
            fullURL = self.cachesURL.URLByAppendingPathComponent(lastPathComponent + ".plist")
        case .DocumentsDirectory(let lastPathComponent):
            fullURL = self.documentsURL.URLByAppendingPathComponent(lastPathComponent + ".plist")
        }
        
        do {
            let data = try NSPropertyListSerialization.dataWithPropertyList(dictionary, format: .XMLFormat_v1_0, options: 0)
            if self.fileManager.fileExistsAtPath(fullURL.URLByDeletingLastPathComponent!.path!) == false {
                try self.fileManager.createDirectoryAtPath(fullURL.URLByDeletingLastPathComponent!.path!, withIntermediateDirectories: true, attributes: .None)
            }
            try data.writeToURL(fullURL, options: .AtomicWrite)
        } catch {
            throw error
        }
    }
    
    func dictionaryByReadingPLISTFromDiskLocation(location: Location) throws -> NSDictionary? {
        let url: NSURL
        switch location {
        case .PreferencesPLISTFileWithinPreferencesURL:
            url = self.preferencesPLISTFileURLWithinPreferencesURL
        case .AppDirectoryWithinAppSupportDirectory(let appendComponent):
            url = self.appDirectoryWithinAppSupportURL.URLByAppendingPathComponent(appendComponent)
        case .CachesDirectory(let appendComponent):
            url = self.cachesURL.URLByAppendingPathComponent(appendComponent)
        case .DocumentsDirectory(let appendComponent):
            url = self.documentsURL.URLByAppendingPathComponent(appendComponent)
        }
        
        do {
            let data = try NSData(contentsOfURL: url, options: .DataReadingMappedIfSafe)
            let dictionary = try NSPropertyListSerialization.propertyListWithData(data, options: .Immutable, format: nil) as? NSDictionary
            return dictionary
        } catch {
            throw error
        }
    }
    
    enum Location {
        case PreferencesPLISTFileWithinPreferencesURL
        case AppDirectoryWithinAppSupportDirectory(lastPathComponent: String)
        case CachesDirectory(lastPathComponent: String)
        case DocumentsDirectory(lastPathComponent: String)
    }
    
    var preferencesPLISTFileURLWithinPreferencesURL: NSURL {
        return self.fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
            .URLByAppendingPathComponent("Preferences", isDirectory: true)
            .URLByAppendingPathComponent(self.bundleID + ".plist")
    }
    
    var appDirectoryWithinAppSupportURL: NSURL {
        return self.fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first!
            .URLByAppendingPathComponent(self.bundleIDLastComponent, isDirectory: true)
    }
    
    var cachesURL: NSURL {
        return self.fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
    }
    
    var documentsURL: NSURL {
        return self.fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    }
    
    var bundleID: String {
        return NSBundle.mainBundle().bundleIdentifier!
    }
    
    var bundleIDLastComponent: String {
        return self.bundleID.componentsSeparatedByString(".").last!
    }
    
}