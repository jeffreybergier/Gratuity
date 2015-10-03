//
//  GratuitousPropertyListPreferences.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 8/29/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

protocol GratuitousPropertyListPreferencesDelegate: class {
    func setDataChanged()
    func setInterfaceDataChanged()
    func dataNeeded(dataNeeded: GratuitousPropertyListPreferences.DataNeeded)
}

class GratuitousPropertyListPreferences {
    
    weak var delegate: GratuitousPropertyListPreferencesDelegate?
    
    init() {
        let plistURL = GratuitousPropertyListPreferences.locationOnDisk
        
        let plistDictionary: NSDictionary?
        do {
            let plistData = try NSData(contentsOfURL: plistURL, options: .DataReadingMappedIfSafe)
            try plistDictionary = NSPropertyListSerialization.propertyListWithData(plistData, options: .Immutable, format: nil) as? NSDictionary
        } catch {
            NSLog("GratuitousPropertyListPreferences: Failed to read existing preferences from disk: \(error)")
            plistDictionary = .None
        }
        self.model = Properties(dictionary: plistDictionary)
                
        #if os(iOS)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: .None)
        #endif
    }
    
    @available(iOS 8, *)
    @objc private func applicationWillResignActive(notification: NSNotification?) {
        self.writeToDisk()
    }
    
    private var writeTimer: NSTimer?
    
    private func resetWriteTimer() {
        self.writeTimer?.invalidate()
        self.writeTimer = .None
        self.writeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "writeTimerFired:", userInfo: nil, repeats: false)
    }
    
    @objc private func writeTimerFired(timer: NSTimer?) {
        timer?.invalidate()
        self.writeTimer?.invalidate()
        self.writeTimer = nil
        self.writeToDisk()
        
        // notify delegate of changes
        if self.dataChanged == true {
            self.delegate?.setDataChanged()
        }
        self.dataChanged = false
    }
    
    private func writeToDisk() -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let preferencesURL = GratuitousPropertyListPreferences.preferencesURL
        let plistURL = GratuitousPropertyListPreferences.locationOnDisk
        
        do {
            if let plistData = self.model.saveToDiskDataCopy {
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
    
    private var dataChanged: Bool = false
    
    private func notifyDelegateDataNeeded(dataNeeded: DataNeeded) {
        self.delegate?.dataNeeded(dataNeeded)
    }
    
    var model: Properties {
        didSet {
            self.dataChanged = false // set this to false so we don't notify iOS of changes because they likely came from iOS
            self.resetWriteTimer()
        }
    }
    
    var currencySymbolsNeeded: Bool {
        set {
            self.model.currencySymbolsNeeded = newValue
            if newValue == true {
                self.notifyDelegateDataNeeded(.CurrencySymbols(specificSymbol: self.model.overrideCurrencySymbol))
            }
            self.dataChanged = true
        }
        get {
            return self.model.currencySymbolsNeeded
        }
    }
    
    private var appVersionString: String {
        set {
            self.model.appVersionString = newValue
            self.dataChanged = true
        }
        get {
            return self.model.appVersionString
        }
    }
    
    var billIndexPathRow: Int {
        set {
            // first set the tip to 0 so it performs default behaviors
            self.model.tipIndexPathRow = 0
            
            // then update instance variables and user defaults
            self.model.billIndexPathRow = newValue
            self.dataChanged = true
        }
        get {
            return self.model.billIndexPathRow
        }
    }
    
    var tipIndexPathRow: Int {
        set {
            self.model.tipIndexPathRow = newValue
            self.dataChanged = true
        }
        get {
            return self.model.tipIndexPathRow
        }
    }
    
    var overrideCurrencySymbol: CurrencySign {
        set {
            self.model.overrideCurrencySymbol = newValue
            self.dataChanged = true
            self.delegate?.setInterfaceDataChanged()
        }
        get {
            return self.model.overrideCurrencySymbol
        }
    }
    
    var suggestedTipPercentage: Double {
        set {
            self.model.suggestedTipPercentage = newValue
            self.dataChanged = true
        }
        get {
            return self.model.suggestedTipPercentage
        }
    }
    
    var freshWatchAppInstall: Bool {
        set {
            self.model.freshWatchAppInstall = newValue
            self.dataChanged = true
        }
        get {
            return self.model.freshWatchAppInstall
        }
    }
    
    var splitBillPurchased: Bool {
        set {
            self.model.splitBillPurchased = newValue
            self.dataChanged = true
        }
        get {
            return self.model.splitBillPurchased
        }
    }

    class var locationOnDisk: NSURL {
        let plistURL = GratuitousPropertyListPreferences.preferencesURL.URLByAppendingPathComponent(Keys.propertyListFileName)
        return plistURL
    }
    
    class var preferencesURL: NSURL {
        let fileManager = NSFileManager.defaultManager()
        let libraryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first!
        let preferencesURL = libraryURL.URLByAppendingPathComponent("Preferences")
        return preferencesURL
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    enum DataNeeded {
        case CurrencySymbols(specificSymbol: CurrencySign)
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
        static let freshWatchAppInstall = "freshWatchAppInstall"
        static let splitBillPurchased = "splitBillPurchased"
    }

    
    struct Properties {
        var currencySymbolsNeeded: Bool
        var appVersionString: String
        var billIndexPathRow: Int
        var tipIndexPathRow: Int
        var overrideCurrencySymbol: CurrencySign
        var suggestedTipPercentage: Double
        var freshWatchAppInstall: Bool
        var splitBillPurchased: Bool
        
        var contextDictionaryCopy: [String : AnyObject] {
            return [
                Keys.billIndexPathRow : NSNumber(integer: self.billIndexPathRow),
                Keys.tipIndexPathRow : NSNumber(integer: self.tipIndexPathRow),
                Keys.overrideCurrencySymbol : NSNumber(integer: self.overrideCurrencySymbol.rawValue),
                Keys.suggestedTipPercentage : NSNumber(double: self.suggestedTipPercentage),
                Keys.splitBillPurchased : NSNumber(bool: self.splitBillPurchased)
            ]
        }
        
        var saveToDiskDictionaryCopy: [String : AnyObject] {
            return [
                Keys.billIndexPathRow : NSNumber(integer: self.billIndexPathRow),
                Keys.tipIndexPathRow : NSNumber(integer: self.tipIndexPathRow),
                Keys.overrideCurrencySymbol : NSNumber(integer: self.overrideCurrencySymbol.rawValue),
                Keys.suggestedTipPercentage : NSNumber(double: self.suggestedTipPercentage),
                Keys.appVersionString : self.appVersionString,
                Keys.freshWatchAppInstall : NSNumber(bool: self.freshWatchAppInstall),
                Keys.splitBillPurchased : NSNumber(bool: self.splitBillPurchased)
            ]
        }
        
        var saveToDiskDataCopy: NSData? {
            return try? NSPropertyListSerialization.dataWithPropertyList(self.saveToDiskDictionaryCopy, format: .XMLFormat_v1_0, options: 0)
        }
        
        init(dictionary: NSDictionary?, fallback: Properties) {
            // version 1.0 and 1.0.1 keys
            if let billIndexPathRow = dictionary?[Keys.billIndexPathRow] as? NSNumber {
                self.billIndexPathRow = billIndexPathRow.integerValue
            } else {
                self.billIndexPathRow = fallback.billIndexPathRow
            }
            if let tipIndexPathRow = dictionary?[Keys.tipIndexPathRow] as? NSNumber {
                self.tipIndexPathRow = tipIndexPathRow.integerValue
            } else {
                self.tipIndexPathRow = fallback.tipIndexPathRow
            }
            if let overrideCurrencySymbol = dictionary?[Keys.overrideCurrencySymbol] as? NSNumber,
                symbolEnum = CurrencySign(rawValue: overrideCurrencySymbol.integerValue) {
                    self.overrideCurrencySymbol = symbolEnum
            } else {
                self.overrideCurrencySymbol = fallback.overrideCurrencySymbol
            }
            if let suggestedTipPercentage = dictionary?[Keys.suggestedTipPercentage] as? NSNumber {
                self.suggestedTipPercentage = suggestedTipPercentage.doubleValue
            } else {
                self.suggestedTipPercentage = fallback.suggestedTipPercentage
            }
            // version 1.1 keys
            if let appVersionString = dictionary?[Keys.appVersionString] as? String {
                self.appVersionString = appVersionString
            } else {
                self.appVersionString = fallback.appVersionString
            }
            // version 1.2 keys
            if let freshWatchAppInstall = dictionary?[Keys.freshWatchAppInstall] as? NSNumber {
                let value = freshWatchAppInstall.boolValue
                self.freshWatchAppInstall = value
            } else {
                self.freshWatchAppInstall = true
            }
            if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
                let value = splitBillPurchased.boolValue
                self.splitBillPurchased = value
            } else {
                splitBillPurchased = false
            }
            // ignored from disk version. Always set to false on load
            self.currencySymbolsNeeded = fallback.currencySymbolsNeeded
        }
        
        init(dictionary: NSDictionary?) {
            // version 1.0 and 1.0.1 keys
            if let billIndexPathRow = dictionary?[Keys.billIndexPathRow] as? NSNumber {
                self.billIndexPathRow = billIndexPathRow.integerValue
            } else {
                self.billIndexPathRow = 25
            }
            if let tipIndexPathRow = dictionary?[Keys.tipIndexPathRow] as? NSNumber {
                self.tipIndexPathRow = tipIndexPathRow.integerValue
            } else {
                self.tipIndexPathRow = 0
            }
            if let overrideCurrencySymbol = dictionary?[Keys.overrideCurrencySymbol] as? NSNumber,
                symbolEnum = CurrencySign(rawValue: overrideCurrencySymbol.integerValue) {
                    self.overrideCurrencySymbol = symbolEnum
            } else {
                self.overrideCurrencySymbol = .Default
            }
            if let suggestedTipPercentage = dictionary?[Keys.suggestedTipPercentage] as? NSNumber {
                self.suggestedTipPercentage = suggestedTipPercentage.doubleValue
            } else {
                self.suggestedTipPercentage = 0.2
            }
            // version 1.1 keys
            if let appVersionString = dictionary?[Keys.appVersionString] as? String {
                self.appVersionString = appVersionString
            } else {
                self.appVersionString = "1.1.0"
            }
            // version 1.2 keys
            if let freshWatchAppInstall = dictionary?[Keys.freshWatchAppInstall] as? NSNumber {
                let value = freshWatchAppInstall.boolValue
                self.freshWatchAppInstall = value
            } else {
                self.freshWatchAppInstall = true
            }
            if let splitBillPurchased = dictionary?[Keys.splitBillPurchased] as? NSNumber {
                let value = splitBillPurchased.boolValue
                self.splitBillPurchased = value
            } else {
                splitBillPurchased = false
            }
            // ignored from disk version. Always set to false on load
            self.currencySymbolsNeeded = false
        }
    }

}