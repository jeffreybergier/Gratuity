//
//  GratuitousErrors.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/4/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import MessageUI

extension NSError {
    struct GratuitousPurchaseError {
        static let domainKey = "GratuitousPurchaseError"
        
        enum ErrorCode: Int {
            case RestorePurchasesAlreadyInProgress = 01
            case ProductRequestNeeded = 02
            case PurchaseDeferred = 03
            case PurchaseFailed = 04
            case RestoreSucceededSplitBillNotPurchased = 05
            case RestoreFailed = 06
        }
    }
    
    convenience init(purchaseError: GratuitousPurchaseError.ErrorCode) {
        let errorDomain = GratuitousPurchaseError.domainKey
        let code = purchaseError.rawValue
        
        let localizedDescription: String
        let localizedRecoverySuggestion: String
        switch purchaseError {
        case .RestorePurchasesAlreadyInProgress:
            localizedDescription = NSLocalizedString("Restore in Progress", comment: "")
            localizedRecoverySuggestion = NSLocalizedString("A purchase restore is already in progress. Please wait for the first restore to finish before trying again.", comment: "")
        case .ProductRequestNeeded:
            localizedDescription = NSLocalizedString("Request Failure", comment: "")
            localizedRecoverySuggestion = NSLocalizedString("Failed to request products from the App Store. Check your data connection and try again later.", comment: "")
        case .PurchaseDeferred:
            localizedDescription = NSLocalizedString("Successfully Asked Permission", comment: "")
            localizedRecoverySuggestion = NSLocalizedString("While waiting for approval, the feature has been enabled. Note, without approval the feature may disable itself.", comment: "")
        case .PurchaseFailed:
            localizedDescription = NSLocalizedString("Purchase Failed", comment: "")
            localizedRecoverySuggestion = NSLocalizedString("The purchased was cancelled or failed. Check your data connection and try again later.", comment: "")
        case .RestoreSucceededSplitBillNotPurchased:
            localizedDescription = NSLocalizedString("Purchase Not Found", comment: "")
            localizedRecoverySuggestion = NSLocalizedString("The Split Bill Feature was not found while restoring In-App Purchases. Tap the Buy button to purchase this feature.", comment: "")
        case .RestoreFailed:
            localizedDescription = NSLocalizedString("Failed to Restore Purchases", comment: "")
            localizedRecoverySuggestion = NSLocalizedString("An error ocurred while restoring purchases, please check your data connection and try again later.", comment: "")
        }
        
        let userInfo = [
            NSLocalizedRecoverySuggestionErrorKey : localizedRecoverySuggestion,
            NSLocalizedDescriptionKey : localizedDescription
        ]
        
        self.init(domain: errorDomain, code: code, userInfo: userInfo)
    }
}

extension UIAlertController {
    enum CustomStyle {
        case EmailContactSupport
    }
    
    convenience init(actions: [UIAlertAction], error: NSError?) {
        let localizedDescription = error?.userInfo[NSLocalizedDescriptionKey] as? String ?? NSLocalizedString("Unknown Error", comment: "")
        let localizedRecoverySuggestion = error?.userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String ?? NSLocalizedString("An unknown error ocurred", comment: "")
        
        self.init(title: localizedDescription, message: localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.Alert)
        
        for action in actions {
            self.addAction(action)
        }
    }
}

extension UIAlertAction {
    enum Type {
        case Dismiss
        case EmailSupport
    }
    
    convenience init(type: Type, completionHandler: (UIAlertAction -> Void)?) {
        let title: String
        let style: UIAlertActionStyle
        switch type {
        case .Dismiss:
            title = NSLocalizedString("Dismiss", comment: "")
            style = UIAlertActionStyle.Cancel
        case .EmailSupport:
            title = NSLocalizedString("Email Support", comment: "")
            style = UIAlertActionStyle.Default
        }
        self.init(title: title, style: style, handler: completionHandler)
    }
}

class EmailSupportHandler {
    
    enum Type {
        case GenericEmailSupport
    }
    
    let subject: String
    let body: String
    let recipient = "support@saturdayapps.com"
    
    var presentableMailViewController: MFMailComposeViewController?

    init(type: Type, delegate: MFMailComposeViewControllerDelegate) {
        
        switch type {
        case .GenericEmailSupport:
            self.subject = NSLocalizedString("Gratuity Support", comment: "")
            self.body = NSLocalizedString("", comment: "")
        }
        
        if MFMailComposeViewController.canSendMail() {
            let mailer = MFMailComposeViewController()
            mailer.mailComposeDelegate = delegate
            mailer.setSubject(self.subject)
            mailer.setToRecipients([self.recipient])
            mailer.setMessageBody(self.body, isHTML: false)
            
            self.presentableMailViewController = mailer
        }
    }
    
    func switchAppForEmailSupport() {
        let mailStringWrongEncoding = NSString(format: "mailto:support@saturdayapps.com?subject=%@&body=%@", self.subject, self.body)
        let mailString = mailStringWrongEncoding.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let mailToURL = NSURL(string: mailString!)!
        UIApplication.sharedApplication().openURL(mailToURL)
    }
}