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
    
    private let currencyFormatter = NSNumberFormatter()
    private let defaultsManager = GratuitousUserDefaults()
    
    private var currentCurrencyFormat: CurrencySign?
    
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
    
    var billAmount: Int {
        set {
            self.defaultsManager.billIndexPathRow = newValue
            self.defaultsManager.tipIndexPathRow = 0 //every time the bill amount get set, this gets set to 0 which means that we need to calculate our own tipAmount
        }
        get {
            return self.defaultsManager.billIndexPathRow
        }
    }
    
    var tipAmount: Int {
        set {
            self.defaultsManager.tipIndexPathRow = newValue
        }
        get {
            return self.defaultsManager.tipIndexPathRow
        }
    }
    
    var tipPercentage: Double {
        set {
            self.defaultsManager.suggestedTipPercentage = newValue
        }
        get {
            return self.defaultsManager.suggestedTipPercentage
        }
    }
    
    var correctWatchInterface: CorrectWatchInterface {
        get {
            //return CorrectWatchInterface.ThreeButtonStepper
            return self.defaultsManager.correctWatchInterface
        }
        set {
            self.defaultsManager.correctWatchInterface = newValue
        }
    }
    
    var watchAppRunCount: Int {
        set {
            self.defaultsManager.watchAppRunCount = newValue
        }
        get {
            return self.defaultsManager.watchAppRunCount
        }
    }
    
    var watchAppRunCountShouldBeIncremented: Bool {
        set {
            self.defaultsManager.watchAppRunCountShouldBeIncremented = newValue
        }
        get {
            return self.defaultsManager.watchAppRunCountShouldBeIncremented
        }
    }
    
    var numberOfRowsInBillTableForWatch: Int {
        set {
            self.defaultsManager.numberOfRowsInBillTableForWatch = newValue
        }
        get {
            return self.defaultsManager.numberOfRowsInBillTableForWatch
        }
    }
    
    func currencyStringFromInteger(integerValue: Int?) -> String {
        if let integerValue = integerValue {
            var currencyString: String?
            //let currencyString: String?
            if let currentCurrencyFormat = self.currentCurrencyFormat {
                switch currentCurrencyFormat {
                case .Default:
                    currencyString = self.currencyFormatter.stringFromNumber(integerValue)
                case .None:
                    currencyString = "\(integerValue)"
                default:
                    currencyString = "\(currentCurrencyFormat.string())\(integerValue)"
                }
            } else {
                currencyString = self.currencyFormatter.stringFromNumber(integerValue)
            }
            return currencyString !! "$–"
        }
        return "$–"
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
        self.currentCurrencyFormat = self.defaultsManager.overrideCurrencySymbol
    }
    
    class func optionalDivision(#top: Double, bottom: Double) -> Double? {
        let division = top/bottom
        if isinf(division) == false && isnan(division) == false {
            return division
        }
        return nil
    }
}