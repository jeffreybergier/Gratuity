//
//  JSBDictionaryPLISTPreferenceManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class JSBDictionaryPLISTPreferenceManager {
    
    fileprivate let fileManager = FileManager.default
    
    func writePreferencesDictionary(_ dictionary: NSDictionary, toLocation location: UserFileLocation, protection: NSData.WritingOptions = .noFileProtection) throws {
        let fullURL: URL
        switch location {
        case .preferencesPLISTFileWithinPreferencesURL:
            fullURL = self.preferencesPLISTFileURLWithinPreferencesURL
        case .appDirectoryWithinAppSupportDirectory(let lastPathComponent):
            fullURL = self.appDirectoryWithinAppSupportURL.appendingPathComponent(lastPathComponent + ".plist")
        case .cachesDirectory(let lastPathComponent):
            fullURL = self.cachesURL.appendingPathComponent(lastPathComponent + ".plist")
        case .documentsDirectory(let lastPathComponent):
            fullURL = self.documentsURL.appendingPathComponent(lastPathComponent + ".plist")
        }
        
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
            if self.fileManager.fileExists(atPath: fullURL.deletingLastPathComponent().path) == false {
                try self.fileManager.createDirectory(atPath: fullURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: .none)
            }
            try data.write(to: fullURL, options: [.atomicWrite, protection])
        } catch {
            throw error
        }
    }
    
    func dictionaryByReadingPLISTFromDiskLocation(_ location: UserFileLocation) throws -> NSDictionary? {
        let url: URL
        switch location {
        case .preferencesPLISTFileWithinPreferencesURL:
            url = self.preferencesPLISTFileURLWithinPreferencesURL
        case .appDirectoryWithinAppSupportDirectory(let appendComponent):
            url = self.appDirectoryWithinAppSupportURL.appendingPathComponent(appendComponent)
        case .cachesDirectory(let appendComponent):
            url = self.cachesURL.appendingPathComponent(appendComponent)
        case .documentsDirectory(let appendComponent):
            url = self.documentsURL.appendingPathComponent(appendComponent)
        }
        
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            let dictionary = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? NSDictionary
            return dictionary
        } catch {
            throw error
        }
    }
    
    enum UserFileLocation {
        case preferencesPLISTFileWithinPreferencesURL
        case appDirectoryWithinAppSupportDirectory(lastPathComponent: String)
        case cachesDirectory(lastPathComponent: String)
        case documentsDirectory(lastPathComponent: String)
    }
    
    var preferencesPLISTFileURLWithinPreferencesURL: URL {
        return self.fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Preferences", isDirectory: true)
            .appendingPathComponent(self.bundleID + ".plist")
    }
    
    var appDirectoryWithinAppSupportURL: URL {
        return self.fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(self.bundleIDLastComponent, isDirectory: true)
    }
    
    var cachesURL: URL {
        return self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    var documentsURL: URL {
        return self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var bundleID: String {
        return Bundle.main.bundleIdentifier!
    }
    
    var bundleIDLastComponent: String {
        return self.bundleID.components(separatedBy: ".").last!
    }
    
}
