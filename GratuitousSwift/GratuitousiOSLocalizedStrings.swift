//
//  GratuitousiOSLocalizedStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import Foundation

extension WatchInfoViewController {
    struct LocalizedString {
        static let ExtraLargeTextLabel =
        NSLocalizedString("i001 - Gratuity",
            comment: "WatchInfoViewController: ExtraLargeTextLabel: The name of the app, Gratuity."
        )
        static let LargeTextLabel =
        NSLocalizedString("i002 - Apple Watch",
            comment: "WatchInfoViewController: LargeTextLabel: Whatever apple calls the Apple Watch, locally"
        )
        static let NavBarTitleLabel =
        NSLocalizedString("i003 - Gratuity",
            comment: "WatchInfoViewController: NavBarTitle: Title for view that shows how the Gratuity Apple Watch app works."
        )
        static let AboutGratuityForAppleWatch =
        NSLocalizedString("i004 - Did you just open a shiny new Apple Watch? Don't forget to install Gratuity. You can do so in the Apple Watch App on the home screen of your iOS Device.",
            comment: "WatchInfoViewController: AboutGratuityForAppleWatch: Small Paragraph of text that explains Gratuity for Apple Watch."
        )
    }
}

extension TipViewController {
    struct LocalizedString {
        static let BillAmountHeader =
        NSLocalizedString("i005 - Bill",
            comment: "TipViewController: BillAmountHeader: The header above the bill amount selector."
        )
        static let SuggestTipHeader =
        NSLocalizedString("i006 - Tip",
            comment: "TipViewController: SuggestTipHeader: The header above the tip amount selector"
        )
        static let SpltBillButton =
        NSLocalizedString("i007 - Split Bill",
            comment: "TipViewController: SpltBillButton: The button that opens the split bill feature."
        )
        static let SettingsButton =
        NSLocalizedString("i008 - Settings",
            comment: "TipViewController: SettingsButton: Settings Button. Only shows if Settings Icon does not load from Bundle."
        )
    }
}

extension SettingsTableViewController {
    struct LocalizedString {
        static let SuggestedTipPercentageHeader =
        NSLocalizedString("i009 - Suggested Tip Percentage",
            comment: "SettingsTableViewController: SuggestedTipPercentageHeader: Header Text for a group of cells that allow choosing the default tip percentage."
        )
        static let SplitBillInAppPurchaseCellLabel =
        NSLocalizedString("i010 - Split Bill Feature",
            comment: "SettingsTableViewController: SplitBillInAppPurchaseCellLabel: Label Text for the In-App Purchase Cell. This cell tells the user whether the feature is purchased or not."
        )
        static let CurrencySymbolHeader =
        NSLocalizedString("i011 - Currency Symbol",
            comment: "SettingsTableViewController: CurrencySymbolHeader: Header Text for a group of cells that allow choosing the currency symbol."
        )
        static let AboutHeader =
        NSLocalizedString("i012 - About SaturdayApps",
            comment: "SettingsTableViewController: AboutHeader: Header Text for a group of cells that explains my company SaturdayApps."
        )
        static let InAppPurchaseHeader =
        NSLocalizedString("i013 - In-App Purchases",
            comment: "SettingsTableViewController: InAppPurchaseHeader: Header Text for a group of cells where possible In-App Purchases are listed."
        )
        static let LocalCurrencyCellLabel =
        NSLocalizedString("i014 - Local Currency",
            comment: "SettingsTableViewController: LocalCurrencyCellLabel: Cell that tells the system to use the regional currency symbol."
        )
        static let NoneCurrencyCellLabel =
        NSLocalizedString("i015 - No Symbol",
            comment: "SettingsTableViewController: LocalCurrencyCellLabel: Cell that tells the system to use no currency symbol."
        )
        static let AboutSADescriptionLabel =
        NSLocalizedString("i016 - I'm Jeff, a professional UX designer and iOS developer. I like making small and polished apps in my spare time. The many examples of tip calculators on the App Store didn't match the tipping paradigm I used in restaurants. So I made Gratuity. If you like it, please leave a positive review on the app store.",
            comment: "SettingsTableViewController: AboutSADescriptionLabel: Short description of SaturdayApps and why I made Gratuity."
        )
        static let ReviewThisAppButton =
        NSLocalizedString("i017 - Review this App",
            comment: "SettingsTableViewController: ReviewThisAppButton: Review app button"
        )
        static let GratuityForAppleWatchButton =
        NSLocalizedString("i018 - Apple Watch App",
            comment: "SettingsTableViewController: GratuityForAppleWatchButton: Button to preview Gratuity for Apple Watch"
        )
        static let SettingsTitle =
        NSLocalizedString("i051 - Settings",
            comment: "SettingsTableViewController: TitleForNavBar: Title of settings view controller that appears in its navigation controller navbar."
        )
    }
}

extension SplitBillViewController {
    struct LocalizedString {
        static let TitleLabel =
        NSLocalizedString("i019 - Split Bill",
            comment: "SplitBillViewController: TitleLabel: Title of the view controller that shows in the navigation bar."
        )
    }
}

extension PurchaseSplitBillViewController {
    struct LocalizedString {
        static let ExtraLargeTextLabel =
        NSLocalizedString("i020 - Split Bill",
            comment: "PurchaseSplitBillViewController: ExtraLargeTextLabel: The name of the in-app purchase feature"
        )
        static let LargeTextLabel =
        NSLocalizedString("i021 - In-App Purchase",
            comment: "PurchaseSplitBillViewController: LargeTextLabel: Whatever Apple calls In-App Purchase locally"
        )
        static let NavBarTitleLabel =
        NSLocalizedString("i022 - Split Bill",
            comment: "PurchaseSplitBillViewController: NavBarTitleLabel: The name of the in-app purchase feature"
        )
        static let RestorePurchasesButton =
        NSLocalizedString("i023 - Restore Purchases",
            comment: "PurchaseSplitBillViewController: RestorePurchasesButton: Button that restores all In-App Purchases"
        )
        static let PurchaseButtonText =
        NSLocalizedString("i024 - Purchase",
            comment: "PurchaseSplitBillViewController: PurchaseButtonText: Button to start in-app purchase buy."
        )
        static let DownloadingAppStoreInfoButtonText =
        NSLocalizedString("i025 - Downloading...",
            comment: "PurchaseSplitBillViewController: DownloadingAppStoreInfoButtonText: Downloading text that shows while the price of the in-app purchase is downloading from the app store."
        )
    }
}

extension UIAlertAction {
    struct Gratuity {
        struct LocalizedString {
            static let Dismiss =
            NSLocalizedString("i026 - Dismiss",
                comment: "Alert: Action Button: Dismiss Button"
            )
            static let EmailSupport =
            NSLocalizedString("i027 - Email Support",
                comment: "Alert: Action Button: Button to open email view to email support"
            )
            static let Buy =
            NSLocalizedString("i028 - Buy",
                comment: "Alert: Action Button: Buy Button"
            )
        }
    }
}

extension UIAlertController {
    struct Gratuity {
        struct LocalizedString {
            static let UnknownErrorDescription =
            NSLocalizedString("i029 - Unknown Error",
                comment: "Abstract: Alert Title: Unknown Error presented when there was no text in the NSError"
            )
            static let UnknownErrorRecovery =
            NSLocalizedString("i030 - An unknown error ocurred. Check your data connection and try again later.",
                comment: "Abstract: Alert Title: Unknown Error presented when there was no text in the NSError"
            )
        }
    }
}

extension NSError {
    struct Gratuity {
        static let DomainKey = "GratuitousPurchaseError"
        struct LocalizedString {
            static let RestorePurchasesAlreadyInProgressDescription =
            NSLocalizedString( "i031 - Restore in Progress",
                comment: "Error Dialog: Title Text: If a restore is in progress already. The warning instructs the user to wait for the first restore to finish."
            )
            static let RestorePurchasesAlreadyInProgressRecovery =
            NSLocalizedString("i032 - Purchases are in the process of being restored. Please wait for the first restore to finish before trying again.",
                comment: "Error Dialog: Description Text: If a restore is in progress already. The warning instructs the user to wait for the first restore to finish."
            )
            static let PurchaseAlreadyInProgressDescription =
            NSLocalizedString("i033 - Purchase in Progress",
                comment: "Error Dialog: Title Text: If a purchase is in progress already. The warning instructs the user to wait for the first purchase to finish."
            )
            static let PurchaseAlreadyInProgressRecovery =
            NSLocalizedString("i034 - This purchase is already in progress. Please wait for the first restore to finish before trying again.",
                comment: "Error Dialog: Title Description: If a purchase is in progress already. The warning instructs the user to wait for the first purchase to finish."
            )
            static let ProductRequestFailedDescription =
            NSLocalizedString("i035 - App Store Error",
                comment: "Error Dialog: Title Text: This is a generic App Store Connection error. It instructs the user to check their connection and try again later."
            )
            static let ProductRequestFailedRecovery =
            NSLocalizedString("i036 - There was an error while communicating with the App Store. Please check your data connection and try again later.",
                comment: "Error Dialog: Description Text: This is a generic App Store Connection error. It instructs the user to check their connection and try again later."
            )
            static let PurchaseDeferredDescription =
            NSLocalizedString("i037 - Permission Requested",
                comment: "Error Dialog: Title Text: This is when a purchase is deferred because a child asked their parent to approve the in-app purchase. This temporarily grants access to the feature."
            )
            static let PurchaseDeferredRecovery =
            NSLocalizedString("i038 - While waiting for approval, the feature has been enabled. Note, without approval the feature may disable itself.",
                comment: "Error Dialog: Description Text: This is when a purchase is deferred because a child asked their parent to approve the in-app purchase. This temporarily grants access to the feature."
            )
            static let RestoreSucceededSplitBillNotPurchasedDescription =
            NSLocalizedString("i039 - Purchase Not Found",
                comment: "Error Dialog: Title Text: This is when the purchases were restored successfully, but the split bill feature has never been purchased."
            )
            static let RestoreSucceededSplitBillNotPurchasedRecovery =
            NSLocalizedString("i040 - Purchases were successfully restored but this feature has not been purchased. Tap Buy below to purchase this feature.",
                comment: "Error Dialog: Description Text: This is when the purchases were restored successfully, but the split bill feature has never been purchased."
            )
            static let RestoreFailedUnknownDescription =
            NSLocalizedString("i041 - Restore Failed",
                comment: "Error Dialog: Title Text: When there is an unknown error connecting to the app store during a purchase restore."
            )
            static let RestoreFailedUnknownRecovery =
            NSLocalizedString("i042 - There was an error while communicating with the App Store. Please check your data connection and try again later.",
                comment: "Error Dialog: Description Text: When there is an unknown error connecting to the app store during a purchase restore."
            )
            static let PurchaseFailedUnknownDescription =
            NSLocalizedString("i043 - Purchase Failed",
                comment: "Error Dialog: Title Text: When there is an unknown error connecting to the app store during a purchase"
            )
            static let PurchaseFailedUnknownRecovery =
            NSLocalizedString("i044 - There was an error while communicating with the App Store. Please check your data connection and try again later.",
                comment: "Error Dialog: Description Text: When there is an unknown error connecting to the app store during a purchase."
            )
            static let RestoreFailedPaymentNotAllowedDescription =
            NSLocalizedString("i045 - Restore Failed",
                comment: "Error Dialog: Title Text: Purchases Restricted on this device"
            )
            static let RestoreFailedPaymentNotAllowedRecovery =
            NSLocalizedString("i046 - In-App purchases are restricted on this device. Please remove the restriction and try again.",
                comment: "Error Dialog: Description Text: Purchases Restricted on this device"
            )
            static let PurchaseFailedPaymentNotAllowedDescription =
            NSLocalizedString("i047 - Purchase Failed",
                comment: "Error Dialog: Title Text: Purchases Restricted on this device"
            )
            static let PurchaseFailedPaymentNotAllowedRecovery =
            NSLocalizedString("i048 - In-App purchases are restricted on this device. Please remove the restriction and try again.",
                comment: "Error Dialog: Description Text: Purchases Restricted on this device"
            )
        }
    }
}

extension AutoMailViewController {
    static let Recipient = "support@saturdayapps.com"
    struct LocalizedString {
        static let EmailSubject =
            NSLocalizedString("i050 - Gratuity Support",
                              comment: "Support Email: Subject"
        )
        static let EmailBody =
            NSLocalizedString("i049 - BLANKSTRING",
                              comment: "Support Email: Body"
        )
        static let CopyEmail =
            NSLocalizedString("i052 - Copy my email address into your clipboard, then paste it in your favorite email app.",
                              comment: "Alert: Email Copy: Message: Alert message that tells the user that they can copy my email address into their clipboard and paste it in their favorite email app."
        )
        static let CopyEmailButton =
            NSLocalizedString("i053 - Copy Email Address",
                              comment: "Alert: Email Copy: Button Title and Alert Title: When the user taps this button, the developers email address is copied into the users clipboard so the user can paste it into their favorite email app."
        )
    }
}




