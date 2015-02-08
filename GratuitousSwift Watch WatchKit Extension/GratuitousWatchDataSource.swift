//
//  GratuitousWatchDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousWatchDataSource {
    
    private let defaultsManager = GratuitousUserDefaults()
    private var writeDefaultsTimer: NSTimer?
    private var tipAmountSetLast: Bool = false
    
    init() {
        _billAmount = Float(self.defaultsManager.billIndexPathRow) - 1
        _tipPercentage = Float(self.defaultsManager.suggestedTipPercentage)
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
    private var _tipAmount: Float?
    private var _billAmount: Float?
    private var _tipPercentage: Float?
    
    var totalAmount: Float? {
        get {
            if _billAmount != nil && _tipAmount != nil {
                return _billAmount! + _tipAmount!
            } else if _billAmount != nil && _tipPercentage != nil {
                return (_billAmount! * _tipPercentage!) + _billAmount!
            } else if _tipPercentage != nil && _tipAmount != nil {
                return self.optionalDivision(top: _tipAmount!, bottom: _tipPercentage!)
            }
            return nil
        }
    }
    
    var billAmount: Float? {
        set {
            self.tipAmountSetLast = false
            self.configureTimer()
            
            _billAmount = newValue
            if let newValue = newValue {
                if let tipPercentage = _tipPercentage {
                    _tipAmount = newValue * tipPercentage
                }
            }
        }
        get {
            if let billAmount = _billAmount {
                return billAmount
            } else {
                if let tipAmount = _tipAmount {
                    if let tipPercentage = _tipPercentage {
                        _billAmount = self.optionalDivision(top: tipAmount, bottom: tipPercentage)
                        return _billAmount
                    }
                }
            }
            return nil
        }
    }
    
    var tipAmount: Float? {
        set {
            self.tipAmountSetLast = true
            self.configureTimer()
            
            _tipAmount = newValue
            if let newValue = newValue {
                if let billAmount = _billAmount {
                    _tipPercentage = self.optionalDivision(top: newValue, bottom: billAmount)
                }
            }
        }
        get {
            if let tipAmount = _tipAmount {
                return tipAmount
            } else {
                if let billAmount = _billAmount {
                    if let tipPercentage = _tipPercentage {
                        _tipAmount = billAmount * tipPercentage
                        return _tipAmount
                    }
                }
            }
            return nil
        }
    }
    
    var tipPercentage: Float? {
        set {
            _tipPercentage = newValue
            if let newValue = newValue {
                if let billAmount = _billAmount {
                    _tipAmount = newValue * billAmount
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
    
    func dollarStringFromFloat(floatValue: Float?) -> String {
        if let floatValue = floatValue {
            return NSString(format: "$%.0f", floatValue)
        }
        return "nil"
    }
    
    func percentStringFromFloat(floatValue: Float?) -> String {
        if let floatValue = floatValue {
            return NSString(format: "%.0f%%", floatValue)
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
    
    @objc private func writeDefaultsToDiskTimerFired(timer: NSTimer) {
        timer.invalidate()
        self.writeDefaultsTimer = nil
        
        if self.tipAmountSetLast == true {
            let tipAmount = _tipAmount !! 25
            self.defaultsManager.tipIndexPathRow = Int(round(tipAmount)) + 1
        } else {
            let billAmount = _billAmount !! 25
            self.defaultsManager.billIndexPathRow = Int(round(billAmount)) + 1
            self.defaultsManager.tipIndexPathRow = 0 //every time the bill amount get set, this gets set to 0 which means that we need to calculate our own tipAmount
        }
    }
    
    private func optionalDivision(#top: Float, bottom: Float) -> Float? {
        let division = top/bottom
        if division != 1/0 {
            return division
        }
        return nil
    }
    
}