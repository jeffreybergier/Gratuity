//
//  GratuitousiOSLocalizedStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

extension WatchInfoViewController {
    struct LocalizedString {
        static let ExtraLargeTextLabel =
        NSLocalizedString("Gratuity",
            comment: "WatchInfoViewController: ExtraLargeTextLabel: The name of the app, Gratuity."
        )
        static let LargeTextLabel =
        NSLocalizedString("Apple Watch",
            comment: "WatchInfoViewController: LargeTextLabel: Whatever apple calls the Apple Watch, locally"
        )
        static let NavBarTitleLabel =
        NSLocalizedString("Apple Watch",
            comment: "WatchInfoViewController: NavBarTitle: Title for view that shows how the Gratuity Apple Watch app works."
        )
        static let AboutGratuityForAppleWatch =
        NSLocalizedString("Did you just open a shiny new Apple Watch? Don't forget to install Gratuity. You can do so in the Apple Watch App on the home screen of your iOS Device.",
            comment: "WatchInfoViewController: AboutGratuityForAppleWatch: Small Paragraph of text that explains Gratuity for Apple Watch."
        )
    }
}

extension TipViewController {
    struct LocalizedString {
        static let BillAmountHeader =
        NSLocalizedString("Amount on Bill",
            comment: "TipViewController: BillAmountHeader: The header above the bill amount selector."
        )
        static let SuggestTipHeader =
        NSLocalizedString("Suggested Tip",
            comment: "TipViewController: SuggestTipHeader: The header above the tip amount selector"
        )
        static let SpltBillButton =
        NSLocalizedString("Split Bill",
            comment: "TipViewController: SpltBillButton: The button that opens the split bill feature."
        )
        static let SettingsButton =
        NSLocalizedString("Settings",
            comment: "TipViewController: SettingsButton: Settings Button. Only shows if Settings Icon does not load from Bundle."
        )
    }
}

extension SettingsTableViewController {
    struct LocalizedString {
        static let SuggestedTipPercentageHeader =
        NSLocalizedString("Suggested Tip Percentage",
            comment: "SettingsTableViewController: SuggestedTipPercentageHeader: Header Text for a group of cells that allow choosing the default tip percentage."
        )
        static let CurrencySymbolHeader =
        NSLocalizedString("Currency Symbol",
            comment: "SettingsTableViewController: CurrencySymbolHeader: Header Text for a group of cells that allow choosing the currency symbol."
        )
        static let AboutHeader =
        NSLocalizedString("About SaturdayApps",
            comment: "SettingsTableViewController: AboutHeader: Header Text for a group of cells explains my company SaturdayApps."
        )
        static let LocalCurrencyCellLabel =
        NSLocalizedString("Local Currency",
            comment: "SettingsTableViewController: LocalCurrencyCellLabel: Cell that tells the system to use the regional currency symbol."
        )
        static let NoneCurrencyCellLabel =
        NSLocalizedString("No Symbol",
            comment: "SettingsTableViewController: LocalCurrencyCellLabel: Cell that tells the system to use no currency symbol."
        )
        static let AboutSADescriptionLabel =
        NSLocalizedString("My name is Jeff. I'm a professional designer. I like making Apps in my spare time. The many examples of tip calculators on the App Store didn't match the tipping paradigm I used in restaurants. So I made Gratuity. If you like it, please leave a positive review on the app store.",
            comment: "SettingsTableViewController: AboutSADescriptionLabel: Short description of SaturdayApps and why I made Gratuity."
        )
        static let ReviewThisAppButton =
        NSLocalizedString("Review this App",
            comment: "SettingsTableViewController: ReviewThisAppButton: Review app button"
        )
        static let GratuityForAppleWatchButton =
        NSLocalizedString("Apple Watch App",
            comment: "SettingsTableViewController: GratuityForAppleWatchButton: Button to preview Gratuity for Apple Watch"
        )
    }
}

extension PurchaseSplitBillViewController {
    struct LocalizedString {
        static let ExtraLargeTextLabel =
        NSLocalizedString("Split Bill",
            comment: "PurchaseSplitBillViewController: ExtraLargeTextLabel: The name of the in-app purchase feature"
        )
        static let LargeTextLabel =
        NSLocalizedString("In-App Purchase",
            comment: "PurchaseSplitBillViewController: LargeTextLabel: Whatever Apple calls In-App Purchase locally"
        )
        static let NavBarTitleLabel =
        NSLocalizedString("Split Bill",
            comment: "PurchaseSplitBillViewController: NavBarTitleLabel: The name of the in-app purchase feature"
        )
        static let RestorePurchasesButton =
        NSLocalizedString("Restore Purchases",
            comment: "PurchaseSplitBillViewController: RestorePurchasesButton: Button that restores all In-App Purchases"
        )
        static let PurchaseButtonText =
        NSLocalizedString("Purchase",
            comment: "PurchaseSplitBillViewController: PurchaseButtonText: Button to start in-app purchase buy."
        )
        static let DownloadingAppStoreInfoButtonText =
        NSLocalizedString("Downloading...",
            comment: "PurchaseSplitBillViewController: DownloadingAppStoreInfoButtonText: Downloading text that shows while the price of the in-app purchase is downloading from the app store."
        )
    }
}

extension UIAlertAction {
    struct Gratuity {
        struct LocalizedString {
            static let Dismiss =
            NSLocalizedString("Dismiss",
                comment: "Alert: Action Button: Dismiss Button"
            )
            static let EmailSupport =
            NSLocalizedString("Email Me",
                comment: "Alert: Action Button: Button to open email view to email support"
            )
            static let Buy =
            NSLocalizedString("Buy",
                comment: "Alert: Action Button: Buy Button"
            )
        }
    }
}

extension UIAlertController {
    struct Gratuity {
        struct LocalizedString {
            static let UnknownErrorDescription =
            NSLocalizedString("Unknown Error",
                comment: "Abstract: Alert   Title: Unknown Error presented when there was no text in the NSError"
            )
            static let UnknownErrorRecovery =
            NSLocalizedString("An unknown error ocurred. Check your data connection and try again later.",
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
            NSLocalizedString( "Restore in Progress",
                comment: "Error Dialog: Title Text: If a restore is in progress already. The warning instructs the user to wait for the first restore to finish."
            )
            static let RestorePurchasesAlreadyInProgressRecovery =
            NSLocalizedString("A purchase restore is already in progress. Please wait for the first restore to finish before trying again.",
                comment: "Error Dialog: Description Text: If a restore is in progress already. The warning instructs the user to wait for the first restore to finish."
            )
            static let PurchaseAlreadyInProgressDescription =
            NSLocalizedString("Purchase in Progress",
                comment: "Error Dialog: Title Text: If a purchase is in progress already. The warning instructs the user to wait for the first purchase to finish."
            )
            static let PurchaseAlreadyInProgressRecovery =
            NSLocalizedString("This purchase is already in progress. Please wait for the first restore to finish before trying again.",
                comment: "Error Dialog: Title Description: If a purchase is in progress already. The warning instructs the user to wait for the first purchase to finish."
            )
            static let ProductRequestFailedDescription =
            NSLocalizedString("App Store Error",
                comment: "Error Dialog: Title Text: This is a generic App Store Connection error. It instructs the user to check their connection and try again later."
            )
            static let ProductRequestFailedRecovery =
            NSLocalizedString("Unable to connect to the App Store. Please check your data connection and try again later.",
                comment: "Error Dialog: Description Text: This is a generic App Store Connection error. It instructs the user to check their connection and try again later."
            )
            static let PurchaseDeferredDescription =
            NSLocalizedString("Permission Requested",
                comment: "Error Dialog: Title Text: This is when a purchase is deferred because a child asked their parent to approve the in-app purchase. This temporarily grants access to the feature."
            )
            static let PurchaseDeferredRecovery =
            NSLocalizedString("While waiting for approval, the feature has been enabled. Note, without approval the feature may disable itself.",
                comment: "Error Dialog: Description Text: This is when a purchase is deferred because a child asked their parent to approve the in-app purchase. This temporarily grants access to the feature."
            )
            static let RestoreSucceededSplitBillNotPurchasedDescription =
            NSLocalizedString("Purchase Not Found",
                comment: "Error Dialog: Title Text: This is when the purchases were restored successfully, but the split bill feature has never been purchased."
            )
            static let RestoreSucceededSplitBillNotPurchasedRecovery =
            NSLocalizedString("Purchases were successfully restored but this feature has not been purchased. Tap Buy below to purchase this feature.",
                comment: "Error Dialog: Description Text: This is when the purchases were restored successfully, but the split bill feature has never been purchased."
            )
            static let RestoreFailedUnknownDescription =
            NSLocalizedString("App Store Error",
                comment: "Error Dialog: Title Text: When there is an unknown error connecting to the app store during a purchase restore."
            )
            static let RestoreFailedUnknownRecovery =
            NSLocalizedString("Unable to connect to the App Store. Please check your data connection and try again later.",
                comment: "Error Dialog: Description Text: When there is an unknown error connecting to the app store during a purchase restore."
            )
            static let PurchaseFailedUnknownDescription =
            NSLocalizedString("App Store Error",
                comment: "Error Dialog: Title Text: When there is an unknown error connecting to the app store during a purchase"
            )
            static let PurchaseFailedUnknownRecovery =
            NSLocalizedString("Unable to connect to the App Store. Please check your data connection and try again later.",
                comment: "Error Dialog: Description Text: When there is an unknown error connecting to the app store during a purchase."
            )
            static let RestoreFailedPaymentNotAllowedDescription =
            NSLocalizedString("Restore Failed",
                comment: "Error Dialog: Title Text: Purchases Restricted on this device"
            )
            static let RestoreFailedPaymentNotAllowedRecovery =
            NSLocalizedString("In-App purchases are restricted on this device. Please remove the restriction and try again.",
                comment: "Error Dialog: Description Text: Purchases Restricted on this device"
            )
            static let PurchaseFailedPaymentNotAllowedDescription =
            NSLocalizedString("Purchase Failed",
                comment: "Error Dialog: Title Text: Purchases Restricted on this device"
            )
            static let PurchaseFailedPaymentNotAllowedRecovery =
            NSLocalizedString("In-App purchases are restricted on this device. Please remove the restriction and try again.",
                comment: "Error Dialog: Description Text: Purchases Restricted on this device"
            )
        }
    }
}

extension EmailSupportHandler {
    static let Recipient = "support@saturdayapps.com"
    struct LocalizedString {
        static let EmailSubject =
        NSLocalizedString("Gratuity Support",
            comment: "Support Email: Subject"
        )
        static let EmailBody =
        NSLocalizedString("BLANKSTRING",
            comment: "Support Email: Body"
        )
    }
}




