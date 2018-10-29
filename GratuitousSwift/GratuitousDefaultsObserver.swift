//
//  GratuitousDefaultsObserver.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

protocol Log {
    func error(log: String)
    func info(log: String)
    func warning(log: String)
}

let log: Log? = nil

class GratuitousDefaultsObserver {
    
    func postNotificationsForLocallyChangedDefaults(old old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolChanged, object: self, userInfo: new.dictionaryCopyForKeys(.ForCurrencySymbolsNeeded))
        }
        if old.billIndexPathRow != new.billIndexPathRow
            || old.tipIndexPathRow != new.tipIndexPathRow
            || old.overrideCurrencySymbol != new.overrideCurrencySymbol
            || old.suggestedTipPercentage != new.suggestedTipPercentage
            || old.splitBillPurchased != new.splitBillPurchased
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.RemoteContextUpdateNeeded, object: self, userInfo: new.dictionaryCopyForKeys(.ForWatch))
        }
        #if os(watchOS)
        if new.currencySymbolsNeeded == true {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolsNeededFromRemote, object: self, userInfo: new.dictionaryCopyForKeys(.ForWatch))
        }
        #endif
    }
    
    func postNotificationsForRemoteChangedDefaults(old old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolChanged, object: self, userInfo: new.dictionaryCopyForKeys(.ForCurrencySymbolsNeeded))
        }
        if old.billIndexPathRow != new.billIndexPathRow
            || old.tipIndexPathRow != new.tipIndexPathRow
            || old.suggestedTipPercentage != new.suggestedTipPercentage
            || old.overrideCurrencySymbol != new.overrideCurrencySymbol
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.BillTipValueChangedByRemote, object: self, userInfo: new.dictionaryCopyForKeys(.ForCurrencySymbolsNeeded))
        }
    }
    
    struct NotificationKeys {
        static let CurrencySymbolChanged = "CurrencySymbolChanged"
        static let BillTipValueChangedByRemote = "BillTipValueChanged"
        static let RemoteContextUpdateNeeded = "RemoteConextUpdateNeeded"
        static let CurrencySymbolsNeededFromRemote = "CurrencySymbolsNeededFromRemote"
    }
}