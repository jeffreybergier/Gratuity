//
//  GratuitousCrashlyticsAnswersStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

extension GratuitousAppDelegate {
    struct AnswersString {
        static let Launched = "iOS-ApplicationDidFinishLaunchingWithOptions"
        static let Backgrounded = "iOS-ApplicationWillResignActive"
        static let NewWatchTipCalculated = "wOS-TipVCNewTipCalculated"
        static let OpenURL = "iOS-OpenURLScheme"
    }
}

extension TipViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-TipViewController"
        static let NewTipCalculated = "iOS-TipVCNewTipCalculated"
    }
}

extension SettingsTableViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-SettingsTableViewController"
        static let DidChangeTipPercentage = "iOS-DidChangeTipPercentage"
        static let DidChangeCurrencySymbol = "iOS-DidChangeCurrencySymbol"
        static let DidOpenInternalEmail = "iOS-SettingsDidOpenInternalEmail"
        static let DidOpenExternalEmail = "iOS-SettingsDidOpenExternalEmail"
        static let DidTapReview = "iOS-DidTapReview"
        static let DidSendEmail = "iOS-SettingsEmailDidSend"
        static let DidCancelEmail = "iOS-SettingsEmailDidCancel"
        static let DidSaveEmail = "iOS-SettingsEmailDidSave"
        static let DidFailEmail = "iOS-SettingEmailDidFail"
    }
}

extension SplitBillViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-SplitBillViewController"
    }
}

extension PurchaseSplitBillViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-PurchaseSplitBillViewController"
        static let DidStartPurchase = "iOS-DidStartPurchase"
        static let PurchaseSucceededAlreadyBought = "iOS-PurchaseSucceededAlreadyBought"
        static let PurchaseSucceededNotBoughtBefore = "iOS-PurchaseSucceededNotBoughtBefore"
        static let PurchaseFailed = "iOS-PurchaseFailed"
        static let DidStartRestore = "iOS-DidStartRestore"
        static let RestoreSucceededAlreadyBought = "iOS-RestoreSucceededAlreadyBought"
        static let RestoreSucceededNotBought = "iOS-RestoreSucceededNotBought"
        static let RestoreFailed = "iOS-RestoreFailed"
        static let DidOpenInternalEmail = "iOS-PurchaseVCDidOpenInternalEmail"
        static let DidOpenExternalEmail = "iOS-PurchaseVCDidOpenExternalEmail"
        static let DidSendEmail = "iOS-PurchaseVCEmailDidSend"
        static let DidCancelEmail = "iOS-PurchaseVCEmailDidCancel"
        static let DidSaveEmail = "iOS-PurchaseVCEmailDidSave"
        static let DidFailEmail = "iOS-PurchaseEmailDidFail"
    }
}

extension WatchInfoViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-WatchInfoViewController"
    }
}

extension CurrencySign {
    var descriptionForAnswers: String {
        switch self {
        case .Default:
            return "LocalCurrency"
        case .Dollar:
            return "Dollar"
        case .Pound:
            return "Pound"
        case .Euro:
            return "Euro"
        case .Yen:
            return "Yen"
        case .NoSign:
            return "None"
        }
    }
}

extension NSError {
    var dictionaryForAnswers: [String : AnyObject]? {
        var attributes = [String : AnyObject]()
        attributes["ErrorLocalizedDescription"] = self.localizedDescription
        attributes["ErrorLocalizedFailureReason"] = self.localizedFailureReason
        attributes["ErrorLocalizedRecoveryOptions"] = self.localizedRecoveryOptions
        attributes["ErrorLocalizedRecoverySuggestion"] = self.localizedRecoverySuggestion
        attributes["ErrorDomain"] = self.domain
        attributes["ErrorCode"] = NSNumber(integer: self.code)
        if (attributes as NSDictionary).count > 0 {
            return attributes
        } else {
            return .None
        }
    }
}