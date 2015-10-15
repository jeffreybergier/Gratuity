//
//  GratuitousUserDefaultsDiskManager.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousUserDefaultsDiskManager {
    
    private let fileManager = NSFileManager.defaultManager()
    
    func PLISTDataFromDictionary(dictionary: [String : AnyObject]?) -> NSData? {
        if let dictionary = dictionary {
            return try? NSPropertyListSerialization.dataWithPropertyList(dictionary, format: .XMLFormat_v1_0, options: 0)
        }
        return .None
    }
    
    func writeDictionaryToPreferencesPLISTOnDisk(dictionary: [String : AnyObject]) -> Bool {
        let preferencesURL = GratuitousUserDefaultsDiskManager.preferencesURL
        let plistURL = GratuitousUserDefaultsDiskManager.locationOnDisk
        
        do {
            if let plistData = self.PLISTDataFromDictionary(dictionary) {
                if fileManager.fileExistsAtPath(preferencesURL.path!) == false {
                    try fileManager.createDirectoryAtPath(preferencesURL.path!, withIntermediateDirectories: true, attributes: .None)
                }
                try plistData.writeToURL(plistURL, options: .AtomicWrite)
                print("GratuitousPropertyListPreferences: Successfully Wrote to disk: \(plistURL.path!)")
                return true
            } else {
                return false
            }
        } catch {
            print("GratuitousPropertyListPreferences: Failed to write PLIST to disk with error: \(error)")
            return false
        }
    }
    
    func dictionaryFromPreferencesPLISTOnDisk() -> NSDictionary? {
        let PLISTURL = GratuitousUserDefaultsDiskManager.locationOnDisk
        
        let PLISTDictionary: NSDictionary?
        do {
            let PLISTData = try NSData(contentsOfURL: PLISTURL, options: .DataReadingMappedIfSafe)
            try PLISTDictionary = NSPropertyListSerialization.propertyListWithData(PLISTData, options: .Immutable, format: nil) as? NSDictionary
        } catch {
            NSLog("GratuitousPropertyListPreferences: Failed to read existing preferences from disk: \(error)")
            PLISTDictionary = .None
        }
        return PLISTDictionary
    }
    
    class var preferencesURL: NSURL {
        let fileManager = NSFileManager.defaultManager()
        let libraryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
        let preferencesURL = libraryURL.URLByAppendingPathComponent("Preferences")
        return preferencesURL
    }
    
    class var locationOnDisk: NSURL {
        return self.preferencesURL.URLByAppendingPathComponent(Keys.propertyListFileName)
    }
    
    struct Keys {
        static let propertyListFileName = "com.saturdayapps.gratuity.plist"
    }
}