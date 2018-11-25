//
//  GratuitousDefaultsObserver.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

protocol Log {
    func error(_ log: String)
    func info(_ log: String)
    func warning(_ log: String)
}

class GratuitousDefaultsObserver {
    
    func postNotificationsForLocallyChangedDefaults(old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.CurrencySymbolChanged), object: self, userInfo: new.dictionaryCopyForKeys(.forCurrencySymbolsNeeded))
        }
        if old.billIndexPathRow != new.billIndexPathRow
            || old.tipIndexPathRow != new.tipIndexPathRow
            || old.overrideCurrencySymbol != new.overrideCurrencySymbol
            || old.suggestedTipPercentage != new.suggestedTipPercentage
            || old.splitBillPurchased != new.splitBillPurchased
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.RemoteContextUpdateNeeded), object: self, userInfo: new.dictionaryCopyForKeys(.forWatch))
        }
        #if os(watchOS)
        if new.currencySymbolsNeeded == true {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.CurrencySymbolsNeededFromRemote), object: self, userInfo: new.dictionaryCopyForKeys(.forWatch))
        }
        #endif
    }
    
    func postNotificationsForRemoteChangedDefaults(old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.CurrencySymbolChanged), object: self, userInfo: new.dictionaryCopyForKeys(.forCurrencySymbolsNeeded))
        }
        if old.billIndexPathRow != new.billIndexPathRow
            || old.tipIndexPathRow != new.tipIndexPathRow
            || old.suggestedTipPercentage != new.suggestedTipPercentage
            || old.overrideCurrencySymbol != new.overrideCurrencySymbol
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.BillTipValueChangedByRemote), object: self, userInfo: new.dictionaryCopyForKeys(.forCurrencySymbolsNeeded))
        }
    }
    
    struct NotificationKeys {
        static let CurrencySymbolChanged = "CurrencySymbolChanged"
        static let BillTipValueChangedByRemote = "BillTipValueChanged"
        static let RemoteContextUpdateNeeded = "RemoteConextUpdateNeeded"
        static let CurrencySymbolsNeededFromRemote = "CurrencySymbolsNeededFromRemote"
    }
}
