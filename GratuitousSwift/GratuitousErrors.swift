//
//  GratuitousErrors.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/4/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import MessageUI
import StoreKit

enum StoreKitPurchaseErrorCode: Int {
    case Unknown = 0 //SKErrorUnknown
    case ClientInvalid = 1 //SKErrorClientInvalid // client is not allowed to issue the request, etc.
    case PaymentCancelled = 2 //SKErrorPaymentCancelled // user cancelled the request, etc.
    case PaymentInvalid = 3 //SKErrorPaymentInvalid  // purchase identifier was invalid, etc.
    case PaymentNotAllowed = 4 //SKErrorPaymentNotAllowed // this device is not allowed to make the payment
    case ProductNotAvailable = 5 //SKErrorStoreProductNotAvailable // Product is not available in the current storefront
}

extension NSError {
    struct GratuitousPurchaseError {
        static let domainKey = NSError.Gratuity.DomainKey
        
        enum ErrorCode: Int {
            case RestorePurchasesAlreadyInProgress = 2001
            case PurchaseAlreadyInProgress = 2018
            case ProductRequestFailed = 2002
            case PurchaseDeferred = 2003
            case RestoreSucceededSplitBillNotPurchased = 2005
            case RestoreFailedUnknown = 2006
            case RestoreFailedClientInvalid = 2007
            case RestoreFailedPaymentInvalid = 2009
            case RestoreFailedPaymentNotAllowed = 2010
            case RestoreFailedProductNotAvailable = 2011
            case PurchaseFailedUnknown = 2012
            case PurchaseFailedClientInvalid = 2013
            case PurchaseFailedPaymentInvalid = 2015
            case PurchaseFailedPaymentNotAllowed = 2016
            case PurchaseFailedProductNotAvailable = 2017
        }
    }
    
    convenience init(purchaseError: GratuitousPurchaseError.ErrorCode) {
        let errorDomain = GratuitousPurchaseError.domainKey
        let code = purchaseError.rawValue
        
        let localizedDescription: String
        let localizedRecoverySuggestion: String
        switch purchaseError {
        case .RestorePurchasesAlreadyInProgress:
            localizedDescription = NSError.Gratuity.LocalizedString.RestorePurchasesAlreadyInProgressDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestorePurchasesAlreadyInProgressRecovery
        case .PurchaseAlreadyInProgress:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseAlreadyInProgressDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseAlreadyInProgressRecovery
        case .ProductRequestFailed:
            localizedDescription = NSError.Gratuity.LocalizedString.ProductRequestFailedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.ProductRequestFailedRecovery
        case .PurchaseDeferred:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseDeferredDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseDeferredRecovery
        case .RestoreSucceededSplitBillNotPurchased:
            localizedDescription = NSError.Gratuity.LocalizedString.RestoreSucceededSplitBillNotPurchasedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestoreSucceededSplitBillNotPurchasedRecovery
        case .RestoreFailedUnknown, .RestoreFailedClientInvalid, .RestoreFailedPaymentInvalid, .RestoreFailedProductNotAvailable:
            localizedDescription = NSError.Gratuity.LocalizedString.RestoreFailedUnknownDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestoreFailedUnknownRecovery
        case .PurchaseFailedUnknown, .PurchaseFailedClientInvalid, .PurchaseFailedPaymentInvalid, .PurchaseFailedProductNotAvailable:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseFailedUnknownDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseFailedUnknownRecovery
        case .RestoreFailedPaymentNotAllowed:
            localizedDescription = NSError.Gratuity.LocalizedString.RestoreFailedPaymentNotAllowedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestoreFailedPaymentNotAllowedRecovery
        case .PurchaseFailedPaymentNotAllowed:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseFailedPaymentNotAllowedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseFailedPaymentNotAllowedRecovery
        }
        
        let userInfo = [
            NSLocalizedRecoverySuggestionErrorKey : localizedRecoverySuggestion,
            NSLocalizedDescriptionKey : localizedDescription
        ]
        
        self.init(domain: errorDomain, code: code, userInfo: userInfo)
    }
    
    func isaGratuitousPurchaseError() -> Bool {
        if let _ = GratuitousPurchaseError.ErrorCode(rawValue: self.code) where self.domain == GratuitousPurchaseError.domainKey {
            return true
        } else {
            return false
        }
    }
}

extension UIAlertController {
    enum CustomStyle {
        case EmailContactSupport
    }
    
    convenience init(actions: [UIAlertAction], error: NSError?) {
        let localizedDescription = error?.userInfo[NSLocalizedDescriptionKey] as? String ?? UIAlertController.Gratuity.LocalizedString.UnknownErrorDescription
        let localizedRecoverySuggestion = error?.userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String ?? UIAlertController.Gratuity.LocalizedString.UnknownErrorRecovery
        
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
        case Buy
    }
    
    convenience init(type: Type, completionHandler: (UIAlertAction -> Void)?) {
        let title: String
        let style: UIAlertActionStyle
        switch type {
        case .Dismiss:
            title = UIAlertAction.Gratuity.LocalizedString.Dismiss
            style = UIAlertActionStyle.Cancel
        case .EmailSupport:
            title = UIAlertAction.Gratuity.LocalizedString.EmailSupport
            style = UIAlertActionStyle.Default
        case .Buy:
            title = UIAlertAction.Gratuity.LocalizedString.Buy
            style = UIAlertActionStyle.Default
        }
        self.init(title: title, style: style, handler: completionHandler)
    }
}

final class EmailSupportHandler {
    
    enum Type {
        case GenericEmailSupport
    }
    
    let subject: String
    let body: String
    let recipient = EmailSupportHandler.Recipient
    
    var presentableMailViewController: MFMailComposeViewController?

    init(type: Type, delegate: MFMailComposeViewControllerDelegate) {
        
        switch type {
        case .GenericEmailSupport:
            self.subject = EmailSupportHandler.LocalizedString.EmailSubject
            self.body = EmailSupportHandler.LocalizedString.EmailBody
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
        let mailStringWrongEncoding = NSString(format: "mailto:\(self.recipient)?subject=%@&body=%@", self.subject, self.body)
        let mailString = mailStringWrongEncoding.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let mailToURL = NSURL(string: mailString!)!
        UIApplication.sharedApplication().openURL(mailToURL)
    }
}