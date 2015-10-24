//
//  GratuitousCrashlyticsAnswersStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

extension GratuitousAppDelegate {
    struct AnswersString {
        static let Launched = "iOS-ApplicationDidFinishLaunchingWithOptions"
        static let Backgrounded = "iOS-ApplicationWillResignActive"
    }
}

extension TipViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-TipViewController"
    }
}

extension SettingsTableViewController {
    struct AnswersString {
        static let ViewDidAppear = "iOS-SettingsTableViewController"
        static let DidChangeTipPercentage = "iOS-DidChangeTipPercentage"
        static let DidChangeCurrencySymbol = "iOS-DidChangeCurrencySymbol"
        static let DidOpenInternalEmail = "iOS-DidOpenInternalEmail"
        static let DidOpenExternalEmail = "iOS-DidOpenExternalEmail"
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
        static let DidStartRestore = "iOS-DidStartRestore"
        static let DidStartPurchase = "iOS-DidStartPurchase"
        static let RestoreSucceeded = "iOS-RestoreSucceeded"
        static let RestoreFailed = "iOS-RestoreFailed"
        static let PurchaseSucceeded = "iOS-PurchaseSucceeded"
        static let PurchaseFailed = "iOS-PurchaseFailed"
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