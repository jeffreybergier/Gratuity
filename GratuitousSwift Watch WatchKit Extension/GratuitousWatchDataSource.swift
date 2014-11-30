//
//  GratuitousWatchDataSource.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/28/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousWatchDataSource: NSObject {
    
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
    private var tipAmountStorage: Float = 10
    private var billAmountStorage: Float = 15
    private var tipPercentageStorage: Float = 0.1
    var billAmount: Float {
        get {
            return self.billAmountStorage
        }
        set {
            self.billAmountStorage = newValue
            self.tipAmountStorage = self.billAmountStorage * self.tipPercentageStorage
        }
    }
    
    var tipAmount: Float {
        get {
            return self.tipAmountStorage
        }
        set {
            self.tipAmountStorage = newValue
            self.tipPercentageStorage = self.tipAmountStorage / self.billAmountStorage
        }
    }
    
    var tipPercentage: Float {
        get {
            return self.tipPercentageStorage
        }
        set {
            self.tipPercentageStorage = newValue
            self.tipAmountStorage = self.billAmountStorage * self.tipPercentageStorage
        }
    }
    
    func dollarStringFromFloat(floatValue: Float) -> String {
        return NSString(format: "$%.0f", floatValue)
    }
    
    func percentStringFromFloat(floatValue: Float) -> String {
        return NSString(format: "%.0f%%", floatValue)
    }
}