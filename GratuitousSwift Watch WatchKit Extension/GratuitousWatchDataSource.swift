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
    
    private var writeDefaultsTimer: NSTimer?
    private var tipAmountSetLast: Bool = false
    private var currentCurrencyFormat: CurrencySign?
    
    init() {
        // configure crashlytics in an instance that won't disappear
        Fabric.with([Crashlytics()])
        
        // configure instance variables from disk
        _billAmount = self.defaultsManager.billIndexPathRow
        _tipPercentage = self.defaultsManager.suggestedTipPercentage
        
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
    
    //properties
    private var _tipAmount: Int?
    private var _billAmount: Int?
    private var _tipPercentage: Double?
    
    var totalAmount: Int? {
        get {
            if _billAmount != nil && _tipAmount != nil {
                return _billAmount! + _tipAmount!
            } else if _billAmount != nil && _tipPercentage != nil {
                return Int(round((Double(_billAmount!) * _tipPercentage!) + Double(_billAmount!)))
            } else if _tipPercentage != nil && _tipAmount != nil {
                if let division = self.optionalDivision(top: Double(_tipAmount!), bottom: Double(_tipPercentage!)) {
                    return Int(round(division))
                }
            }
            return nil
        }
    }
    
    var billAmount: Int? {
        set {
            self.tipAmountSetLast = false
            self.configureTimer()
            
            _billAmount = newValue
            if let newValue = newValue {
                if let tipPercentage = _tipPercentage {
                    _tipAmount = Int(round(Double(newValue) * tipPercentage))
                }
            }
        }
        get {
            if let billAmount = _billAmount {
                return billAmount
            } else {
                if let tipAmount = _tipAmount {
                    if let tipPercentage = _tipPercentage {
                        if let division = self.optionalDivision(top: Double(tipAmount), bottom: Double(tipPercentage)) {
                            _billAmount = Int(round(division))
                            return _billAmount
                        }
                    }
                }
            }
            return nil
        }
    }
    
    var tipAmount: Int? {
        set {
            self.tipAmountSetLast = true
            self.configureTimer()
            
            _tipAmount = newValue
            if let newValue = newValue {
                if let billAmount = _billAmount {
                    if let division = self.optionalDivision(top: Double(newValue), bottom: Double(billAmount)) {
                        _tipPercentage = division
                    }
                }
            }
        }
        get {
            if let tipAmount = _tipAmount {
                return tipAmount
            } else {
                if let billAmount = _billAmount {
                    if let tipPercentage = _tipPercentage {
                        _tipAmount = Int(round(Double(billAmount) * tipPercentage))
                        return _tipAmount
                    }
                }
            }
            return nil
        }
    }
    
    var tipPercentage: Double? {
        set {
            _tipPercentage = newValue
            if let newValue = newValue {
                if let billAmount = _billAmount {
                    _tipAmount = Int(round(newValue * Double(billAmount)))
                }
            }
            
        }
        get {
            if let tipPercentage = _tipPercentage {
                return tipPercentage
            }
            return nil
        }
    }
    
    var correctInterface: CorrectInterface {
        get {
            return self.defaultsManager.correctInterface
        }
    }
    
    func currencyStringFromInteger(integerValue: Int?) -> String {
        if let integerValue = integerValue {
            let currencyString: String?
            if let currentCurrencyFormat = self.currentCurrencyFormat {
                switch currentCurrencyFormat {
                case .Default:
                    currencyString = self.currencyFormatter.stringFromNumber(integerValue)
                case .None:
                    currencyString = "\(integerValue)"//String(format: "%.0f", integerValue)
                default:
                    currencyString = "\(currentCurrencyFormat.string())\(integerValue)" //String(format: "%@%.0f", currentCurrencyFormat.string(), integerValue)
                }
            } else {
                currencyString = self.currencyFormatter.stringFromNumber(integerValue)
            }
            return currencyString !! "nil"
        }
        return "nil"
    }
    
    func percentStringFromRawDouble(doubleValue: Double?) -> String {
        if let doubleValue = doubleValue {
            return "\(Int(round(doubleValue * 100)))%"
        }
        return "nil"
    }
    
    private func configureTimer() {
        if self.writeDefaultsTimer != nil {
            self.writeDefaultsTimer!.invalidate()
            self.writeDefaultsTimer = nil
        } else {
            self.writeDefaultsTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "writeDefaultsToDiskTimerFired:", userInfo: nil, repeats: false)
        }
    }
    
    @objc private func updateCurrencySymbolFromDisk(_ timer: NSTimer? = nil) {
        self.currentCurrencyFormat = self.defaultsManager.overrideCurrencySymbol
    }
    
    @objc private func writeDefaultsToDiskTimerFired(timer: NSTimer) {
        timer.invalidate()
        self.writeDefaultsTimer = nil
        
        if self.tipAmountSetLast == true {
            let tipAmount = _tipAmount !! 25
            self.defaultsManager.tipIndexPathRow = tipAmount
        } else {
            let billAmount = _billAmount !! 25
            self.defaultsManager.billIndexPathRow = billAmount
            self.defaultsManager.tipIndexPathRow = 0 //every time the bill amount get set, this gets set to 0 which means that we need to calculate our own tipAmount
        }
    }
    
    private func optionalDivision(#top: Double, bottom: Double) -> Double? {
        let division = top/bottom
        if division != 1/0 {
            return division
        }
        return nil
    }
    
}