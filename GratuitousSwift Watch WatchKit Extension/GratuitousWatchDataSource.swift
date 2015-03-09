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
    
//    private var writeDefaultsTimer: NSTimer?
//    private var tipAmountSetLast: Bool = false
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
                if let division = GratuitousWatchDataSource.optionalDivision(top: Double(_tipAmount!), bottom: Double(_tipPercentage!)) {
                    return Int(round(division))
                }
            }
            return nil
        }
    }
    
    var billAmount: Int? {
        set {
            _billAmount = newValue
                if let tipPercentage = _tipPercentage {
                    _tipAmount = Int(round(Double(newValue !! 0) * tipPercentage))
            }
            let billAmount = newValue !! 25
            self.defaultsManager.billIndexPathRow = billAmount
            self.defaultsManager.tipIndexPathRow = 0 //every time the bill amount get set, this gets set to 0 which means that we need to calculate our own tipAmount
        }
        get {
            if let billAmount = _billAmount {
                if billAmount > 0 {
                    return billAmount //- 1 //Adjust for the fact that this is an indexpathrow from the ios app
                } else {
                    return billAmount
                }
            } else {
                if let tipAmount = _tipAmount {
                    if let tipPercentage = _tipPercentage {
                        if let division = GratuitousWatchDataSource.optionalDivision(top: Double(tipAmount), bottom: Double(tipPercentage)) {
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
            _tipAmount = newValue
            if let newValue = newValue {
                if let billAmount = _billAmount {
                    if let division = GratuitousWatchDataSource.optionalDivision(top: Double(newValue), bottom: Double(billAmount)) {
                        _tipPercentage = division
                    }
                }
            }
            let tipAmount = newValue !! 25
            self.defaultsManager.tipIndexPathRow = tipAmount
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
//        set {
//            _tipPercentage = newValue
//            if let newValue = newValue {
//                if let billAmount = _billAmount {
//                    _tipAmount = Int(round(newValue * Double(billAmount)))
//                }
//            }
//            
//        }
        get {
            return _tipPercentage !! 0.20
        }
    }
    
    var correctWatchInterface: CorrectWatchInterface {
        get {
            //return InterfaceState.ThreeButtonStepper
            return self.defaultsManager.correctWatchInterface
        }
        set {
            self.defaultsManager.correctWatchInterface = newValue
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
            return currencyString !! "nil"
        }
        return "–%"
    }
    
    func percentStringFromRawDouble(doubleValue: Double?) -> String {
        if let doubleValue = doubleValue {
            if doubleValue != Double.NaN && doubleValue != Double.infinity {
                return "\(Int(round(doubleValue * 100)))%"
            }
        }
        return "nil"
    }
    
//    private func configureTimer() {
//        if self.writeDefaultsTimer != nil {
//            self.writeDefaultsTimer!.invalidate()
//            self.writeDefaultsTimer = nil
//        } else {
//            self.writeDefaultsTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "writeDefaultsToDiskTimerFired:", userInfo: nil, repeats: false)
//        }
//    }
    
    @objc private func updateCurrencySymbolFromDisk(_ timer: NSTimer? = nil) {
        self.currentCurrencyFormat = self.defaultsManager.overrideCurrencySymbol
    }
    
//    @objc private func writeDefaultsToDiskTimerFired(timer: NSTimer) {
//        timer.invalidate()
//        self.writeDefaultsTimer = nil
//        
//        if self.tipAmountSetLast == true {
//            let tipAmount = _tipAmount !! 25
//            self.defaultsManager.tipIndexPathRow = tipAmount
//        } else {
//            let billAmount = _billAmount !! 25
//            self.defaultsManager.billIndexPathRow = billAmount
//            self.defaultsManager.tipIndexPathRow = 0 //every time the bill amount get set, this gets set to 0 which means that we need to calculate our own tipAmount
//        }
//    }
    
    class func optionalDivision(#top: Double, bottom: Double) -> Double? {
        let division = top/bottom
        if division != 1/0 {
            return division
        }
        return nil
    }
}