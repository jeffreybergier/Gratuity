//
//  GratuitousPropertyListPreferences.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/29/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousPropertyListPreferences {
    
    init() {
        let fileManager = NSFileManager.defaultManager()
        let libraryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
        let plistURL = libraryURL.URLByAppendingPathComponent("Preferences").URLByAppendingPathComponent(Keys.propertyListFileName)
        
        if let plistURLPath = plistURL.path where fileManager.fileExistsAtPath(plistURLPath) {
            if let plistData = NSData(contentsOfURL: plistURL),
                let plist = NSPropertyListSerialization.propertyListFromData(plistData, mutabilityOption: .Immutable, format: nil, errorDescription: nil) as? NSDictionary {
                    self.replaceStateWithDictionary(plist)
            }
        }
    }
    
    class var locationOnDisk: NSURL {
        let fileManager = NSFileManager.defaultManager()
        let libraryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
        let plistURL = libraryURL.URLByAppendingPathComponent("Preferences").URLByAppendingPathComponent(Keys.propertyListFileName)
        return plistURL
    }
    
    func replaceStateWithDictionary(newState: NSDictionary) -> Bool {
        var numberOfPropertiesReplaced = 0
        if self.writeToDisk() == true {
            // version 1.0 and 1.0.1 keys
            if let billIndexPathRow = newState[Keys.billIndexPathRow] as? NSNumber {
                _billIndexPathRow = billIndexPathRow.integerValue
                numberOfPropertiesReplaced++
            }
            if let tipIndexPathRow = newState[Keys.tipIndexPathRow] as? NSNumber {
                _tipIndexPathRow = tipIndexPathRow.integerValue
                numberOfPropertiesReplaced++
            }
            if let overrideCurrencySymbol = newState[Keys.overrideCurrencySymbol] as? NSNumber,
                symbolEnum = CurrencySign(rawValue: overrideCurrencySymbol.integerValue) {
                    print(overrideCurrencySymbol.integerValue)
                    print(symbolEnum)
                    _overrideCurrencySymbol = symbolEnum
                    numberOfPropertiesReplaced++
            }
            if let suggestedTipPercentage = newState[Keys.suggestedTipPercentage] as? NSNumber {
                _suggestedTipPercentage = suggestedTipPercentage.doubleValue
                numberOfPropertiesReplaced++
            }
            // version 1.1 keys
            if let appVersionString = newState[Keys.appVersionString] as? String {
                _appVersionString = appVersionString
                numberOfPropertiesReplaced++
            }
            // version 1.2 keys
            if let currencySymbolsNeeded = newState[Keys.currencySymbolsNeeded] as? NSNumber {
                _currencySymbolsNeeded = currencySymbolsNeeded.boolValue
                numberOfPropertiesReplaced++
            }
        }
        if numberOfPropertiesReplaced >= 6 {
            return true
        } else {
            return false
        }
    }
    
    @objc private func writeTimerFired(timer: NSTimer?) {
        timer?.invalidate()
        self.writeTimer = .None
        self.writeToDisk()
        NSNotificationCenter.defaultCenter().postNotificationName("GratuitousPropertyListPreferencesWasDirtied", object: self)
    }
    
    private var writeTimer: NSTimer?
    
    func writeToDisk() -> Bool {
        if self.dirtied == true {
            let fileManager = NSFileManager.defaultManager()
            let libraryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
            let preferencesURL = libraryURL.URLByAppendingPathComponent("Preferences")
            let plistURL = preferencesURL.URLByAppendingPathComponent(Keys.propertyListFileName)
            let plistData: NSData?
            do {
                try plistData = NSPropertyListSerialization.dataWithPropertyList(self.dictionaryVersion, format: .XMLFormat_v1_0, options: 0)
            } catch {
                print("error while converting dictionary into plist data: \(error)")
                plistData = .None
            }
            if let data = plistData {
                if fileManager.fileExistsAtPath(preferencesURL.path!) == false {
                    try? fileManager.createDirectoryAtPath(preferencesURL.path!, withIntermediateDirectories: true, attributes: .None)
                }
                let success: Bool
                do {
                    try data.writeToURL(plistURL, options: .AtomicWrite)
                    print("GratuitousPropertyListPreferences: Successfully Wrote to disk: \(plistURL.path!)")
                    success = true
                } catch {
                    print("GratuitousPropertyListPreferences: writing plist to disk failed: \(error)")
                    success = false
                }
                return success
            }
        } else {
            return true
        }
        return false
    }

    var dirtied: Bool = false {
        didSet {
            print("GratuitousPropertyListPreferences: Dirtied = \(self.dirtied)")
            if self.dirtied == true {
                if let writeTimer = self.writeTimer {
                    writeTimer.invalidate()
                }
                self.writeTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "writeTimerFired:", userInfo: .None, repeats: false)
            }
        }
    }
    
    private var _dictionaryVersion: [String : AnyObject]?
    var dictionaryVersion: [String : AnyObject] {
        if let existingDictinary = _dictionaryVersion where self.dirtied == false {
            return existingDictinary
        } else {
            let dictionary = [
                Keys.billIndexPathRow : NSNumber(integer: self.billIndexPathRow),
                Keys.tipIndexPathRow : NSNumber(integer: self.tipIndexPathRow),
                Keys.overrideCurrencySymbol : NSNumber(integer: self.overrideCurrencySymbol.rawValue),
                Keys.suggestedTipPercentage : NSNumber(double: self.suggestedTipPercentage),
                Keys.appVersionString : self.appVersionString,
                Keys.currencySymbolsNeeded : NSNumber(bool: self.currencySymbolsNeeded)
            ]
            _dictionaryVersion = dictionary
            return dictionary
        }
    }
    
    private var _currencySymbolsNeeded: Bool?
    var currencySymbolsNeeded: Bool {
        set {
            _currencySymbolsNeeded = newValue
            self.dirtied = true
            self.writeTimerFired(.None) // Sends out a notification immediately
        }
        get {
            if let existingValue = _currencySymbolsNeeded {
                return existingValue
            } else {
                return false
            }
        }
    }
    
    private var _appVersionString: String?
    private var appVersionString: String {
        set {
            _appVersionString = newValue
            self.dirtied = true
        }
        get {
            if let existingValue = _appVersionString {
                return existingValue
            } else {
                return "1.0.0"
            }
        }
    }
    
    private var _billIndexPathRow: Int?
    var billIndexPathRow: Int {
        set {
            // first set the tip to 0 so it performs default behaviors
            self.tipIndexPathRow = 0
            
            // then update instance variables and user defaults
            _billIndexPathRow = newValue
            self.dirtied = true
        }
        get {
            if let existingValue = _billIndexPathRow {
                return existingValue
            } else {
                return 25
            }
        }
    }
    
    private var _tipIndexPathRow: Int?
    var tipIndexPathRow: Int {
        set {
            _tipIndexPathRow = newValue
            self.dirtied = true
        }
        get {
            if let existingValue = _tipIndexPathRow {
                return existingValue
            } else {
                return 0
            }
        }
    }
    
    private var _overrideCurrencySymbol: CurrencySign? {
        didSet {
            print("Something set currencyOverride to: \(_overrideCurrencySymbol)")
        }
    }
    var overrideCurrencySymbol: CurrencySign {
        set {
            _overrideCurrencySymbol = newValue
            self.dirtied = true
        }
        get {
            if let existingValue = _overrideCurrencySymbol {
                return existingValue
            } else {
                return CurrencySign.Default
            }
        }
    }
    
    private var _suggestedTipPercentage: Double?
    var suggestedTipPercentage: Double {
        set {
            _suggestedTipPercentage = newValue
            self.dirtied = true
        }
        get {
            if let existingValue = _suggestedTipPercentage {
                return existingValue
            } else {
                return 0.2
            }
        }
    }
    
    struct Keys {
        #if LOCAL // Local = Not an App Store Bundle Identifier
        static let localSuiteName = "group.com.saturdayapps.Gratuity.local.storageGroup"
        #else
        static let localSuiteName = "group.com.saturdayapps.Gratuity.storageGroup"
        #endif
        
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        static let propertyListFileName = "com.saturdayapps.gratuity.plist"
        
        // version 1.0 and 1.0.1 keys
        static let billIndexPathRow = "billIndexPathRow"
        static let tipIndexPathRow = "tipIndexPathRow"
        static let overrideCurrencySymbol = "overrideCurrencySymbol"
        static let suggestedTipPercentage = "suggestedTipPercentage"
        
        // version 1.1 keys
        static let appVersionString = "appVersionString"
        static let showTutorialAtLaunch = "showTutorialAtLaunch"
        static let watchInfoViewControllerShouldAppear = "watchInfoViewControllerShouldAppear"
        static let watchInfoViewControllerWasDismissed = "watchInfoViewControllerWasDismissed"
        
        // version 1.2 keys
        static let currencySymbolsNeeded = "currencySymbolsNeeded"
    }
    
    deinit {
        self.writeToDisk()
    }
}