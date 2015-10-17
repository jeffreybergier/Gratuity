//
//  GratuitousDefaultsObserver.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousDefaultsObserver {
    
    func postNotificationsForLocallyChangedDefaults(old old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolChanged, object: self, userInfo: new.dictionaryCopyForKeys(.All))
        }
        if old.billIndexPathRow != new.billIndexPathRow
            || old.tipIndexPathRow != new.tipIndexPathRow
            || old.overrideCurrencySymbol != new.overrideCurrencySymbol
            || old.suggestedTipPercentage != new.suggestedTipPercentage
            || old.splitBillPurchased != new.splitBillPurchased
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.RemoteContextUpdateNeeded, object: self, userInfo: new.dictionaryCopyForKeys(.WatchOnly))
        }
        #if os(watchOS)
        if new.currencySymbolsNeeded == true {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolsNeededFromRemote, object: self, userInfo: new.dictionaryCopyForKeys(.WatchOnly))
        }
        #endif
    }
    
    func postNotificationsForRemoteChangedDefaults(old old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolChanged, object: self, userInfo: new.dictionaryCopyForKeys(.All))
        }
        if old.billIndexPathRow != new.billIndexPathRow
            || old.tipIndexPathRow != new.tipIndexPathRow
            || old.suggestedTipPercentage != new.suggestedTipPercentage
            || old.overrideCurrencySymbol != new.overrideCurrencySymbol
        {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.BillTipValueChangedByRemote, object: self, userInfo: new.dictionaryCopyForKeys(.All))
        }
    }
    
    struct NotificationKeys {
        static let CurrencySymbolChanged = "CurrencySymbolChanged"
        static let BillTipValueChangedByRemote = "BillTipValueChanged"
        static let RemoteContextUpdateNeeded = "RemoteConextUpdateNeeded"
        static let CurrencySymbolsNeededFromRemote = "CurrencySymbolsNeededFromRemote"
    }
}

//    if old.currencySymbolsNeeded != new.currencySymbolsNeeded {
//
//    }
//    if old.appVersionString != new.appVersionString {
//
//    }
//    if old.billIndexPathRow != new.billIndexPathRow {
//
//    }
//    if old.tipIndexPathRow != new.tipIndexPathRow {
//
//    }
//    if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
//
//    }
//    if old.suggestedTipPercentage != new.suggestedTipPercentage {
//
//    }
//    if old.freshWatchAppInstall != new.freshWatchAppInstall {
//
//    }
//    if old.splitBillPurchased != new.splitBillPurchased {
//
//    }