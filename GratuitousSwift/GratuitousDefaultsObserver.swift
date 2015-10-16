//
//  GratuitousDefaultsObserver.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

class GratuitousDefaultsObserver {
    enum DefaultsChange {
        case CurrencySignChanged
    }
    
    func postNotificationsForChangedDefaults(old old: GratuitousUserDefaults, new: GratuitousUserDefaults) {
        if old.currencySymbolsNeeded != new.currencySymbolsNeeded {
            
        }
        if old.appVersionString != new.appVersionString {

        }
        if old.billIndexPathRow != new.billIndexPathRow {

        }
        if old.tipIndexPathRow != new.tipIndexPathRow {

        }
        if old.overrideCurrencySymbol != new.overrideCurrencySymbol {
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.CurrencySymbolChanged, object: self, userInfo: new.dictionaryCopyForKeys(.All))
        }
        if old.suggestedTipPercentage != new.suggestedTipPercentage {

        }
        if old.freshWatchAppInstall != new.freshWatchAppInstall {

        }
        if old.splitBillPurchased != new.splitBillPurchased {

        }
    }
    
    struct NotificationKeys {
        static let CurrencySymbolChanged = "CurrencySymbolChanged"
    }
}