//
//  GratuitousDefaultsObserver.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

protocol GratuitousDefaultsObserverRemoteDelegate {
    func receivedRemotePreferences(preferences: GratuitousUserDefaults)
}

class GratuitousDefaultsObserver {
    
    var remoteDelegate: GratuitousDefaultsObserverRemoteDelegate?
    
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
            self.remoteDelegate?.receivedRemotePreferences(new)
        }
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
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.InterfaceUpdateNeeded, object: self, userInfo: new.dictionaryCopyForKeys(.All))
        }
    }
    
    struct NotificationKeys {
        static let CurrencySymbolChanged = "CurrencySymbolChanged"
        static let InterfaceUpdateNeeded = "InterfaceUpdateNeeded"
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