//
//  GratuitousWatchDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class GratuitousWatchDataSource {
    // This class mostly exists to reduce the number of times the app has to read and write NSUserDefaults.
    // Reads are saved into Instance Variables in this class
    // If a value is requested and the isntance variable has never been set, the value is read from NSUserDefaults.
    
    
    private let currencyFormatter = NSNumberFormatter()
    private let defaultsManager = GratuitousUserDefaults()
    
    init() {
        // configure crashlytics in an instance that won't disappear
        Fabric.with([Crashlytics()])
        
        // read nsuserdefaults to configure the currency symbol
        self.updateCurrencySymbolFromDisk()
        
        // configure currency formatter
        self.currencyFormatter.locale = NSLocale.currentLocale()
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyFormatter.minimumFractionDigits = 0
        self.currencyFormatter.alwaysShowsDecimalSeparator = false
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        
        // configure a timer to check if things change on disk
        let userDefaultsTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: "updateCurrencySymbolFromDisk:", userInfo: nil, repeats: true)
        userDefaultsTimer.fire()
    }
    
    //this code allows this object to be a singleton
    class var sharedInstance: GratuitousWatchDataSource {
        struct Static {
            static var instance: GratuitousWatchDataSource?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GratuitousWatchDataSource()
        }
        
        return Static.instance!
    }
    
    var _billAmount: Int?
    
    var billAmount: Int {
        set {
            _billAmount = newValue
            self.tipAmount = 0 //every time the bill amount get set, this gets set to 0 which means that we need to calculate our own tipAmount
            self.defaultsManager.billIndexPathRow = newValue
        }
        get {
            switch _billAmount {
            case .Some:
                return _billAmount!
            case .None:
                let valueOnDisk = self.defaultsManager.billIndexPathRow
                _billAmount = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _tipAmount: Int?
    
    var tipAmount: Int {
        set {
            _tipAmount = newValue
            self.defaultsManager.tipIndexPathRow = newValue
        }
        get {
            switch _tipAmount {
            case .Some:
                return _tipAmount!
            case .None:
                let valueOnDisk = self.defaultsManager.tipIndexPathRow
                _tipAmount = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _tipPercentage: Double?
    
    var tipPercentage: Double {
        set {
            _tipPercentage = newValue
            self.defaultsManager.suggestedTipPercentage = newValue
        }
        get {
            switch _tipPercentage {
            case .Some:
                return _tipPercentage!
            case .None:
                let valueOnDisk = self.defaultsManager.suggestedTipPercentage
                _tipPercentage = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _correctWatchInterface: CorrectWatchInterface?
    
    var correctWatchInterface: CorrectWatchInterface {
        set {
            _correctWatchInterface = newValue
            self.defaultsManager.correctWatchInterface = newValue
        }
        get {
            switch _correctWatchInterface {
            case .Some:
                return _correctWatchInterface!
            case .None:
                let valueOnDisk = self.defaultsManager.correctWatchInterface
                _correctWatchInterface = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _watchAppRunCount: Int?
    
    var watchAppRunCount: Int {
        set {
            _watchAppRunCount = newValue
            self.defaultsManager.watchAppRunCount = newValue
        }
        get {
            switch _watchAppRunCount {
            case .Some:
                return _watchAppRunCount!
            case .None:
                let valueOnDisk = self.defaultsManager.watchAppRunCount
                _watchAppRunCount = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _watchAppRunCountShouldBeIncremented: Bool?
    
    var watchAppRunCountShouldBeIncremented: Bool {
        set {
            _watchAppRunCountShouldBeIncremented = newValue
            self.defaultsManager.watchAppRunCountShouldBeIncremented = newValue
        }
        get {
            switch _watchAppRunCountShouldBeIncremented {
            case .Some:
                return _watchAppRunCountShouldBeIncremented!
            case .None:
                let valueOnDisk = self.defaultsManager.watchAppRunCountShouldBeIncremented
                _watchAppRunCountShouldBeIncremented = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _numberOfRowsInBillTableForWatch: Int?
    
    var numberOfRowsInBillTableForWatch: Int {
        set {
            _numberOfRowsInBillTableForWatch = newValue
            self.defaultsManager.numberOfRowsInBillTableForWatch = newValue
        }
        get {
            switch _numberOfRowsInBillTableForWatch {
            case .Some:
                return _numberOfRowsInBillTableForWatch!
            case .None:
                let valueOnDisk = self.defaultsManager.numberOfRowsInBillTableForWatch
                _numberOfRowsInBillTableForWatch = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    var _overrideCurrencySymbol: CurrencySign?
    
    var overrideCurrencySymbol: CurrencySign {
        set {
            _overrideCurrencySymbol = newValue
            self.defaultsManager.overrideCurrencySymbol = newValue
        }
        get {
            switch _overrideCurrencySymbol {
            case .Some:
                return _overrideCurrencySymbol!
            case .None:
                let valueOnDisk = self.defaultsManager.overrideCurrencySymbol
                _overrideCurrencySymbol = valueOnDisk
                return valueOnDisk
            }
        }
    }
    
    func currencyStringFromInteger(integerValue: Int?) -> String {
        var currencyString = "$–"
        if let integerValue = integerValue {
            //let currencyString: String?
            let currentCurrencyFormat = self.overrideCurrencySymbol
            switch currentCurrencyFormat {
            case .Default:
                if let defaultString = self.currencyFormatter.stringFromNumber(integerValue) {
                    currencyString = defaultString
                } else {
                    fallthrough
                }
            case .None:
                currencyString = "\(integerValue)"
            default:
                currencyString = "\(currentCurrencyFormat.string())\(integerValue)"
            }
        }
        return currencyString
    }
    
    func percentStringFromRawDouble(doubleValue: Double?) -> String {
        if let doubleValue = doubleValue {
            if isnan(doubleValue) == false && isinf(doubleValue) == false {
                return "\(Int(round(doubleValue * 100)))%"
            }
        }
        return "– %"
    }
    
    @objc private func updateCurrencySymbolFromDisk(_ timer: NSTimer? = nil) {
        self.overrideCurrencySymbol = self.defaultsManager.overrideCurrencySymbol
    }
    
    class func optionalDivision(#top: Double, bottom: Double) -> Double? {
        let division = top/bottom
        if isinf(division) == false && isnan(division) == false {
            return division
        }
        return nil
    }
}