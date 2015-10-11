//
//  GratuitousiOSLocalizedStrings.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

extension UIAlertAction {
    struct Gratuity {
        struct LocalizedString {
            static let Dismiss =
            NSLocalizedString("Dismiss",
                comment: "Alert: Action Button: Dismiss Button"
            )
            static let EmailSupport =
            NSLocalizedString("Email Support",
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




