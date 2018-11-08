//
//  GratuitousErrors.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/4/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import MessageUI
import UIKit

enum StoreKitPurchaseErrorCode: Int {
    case unknown = 0 //SKErrorUnknown
    case clientInvalid = 1 //SKErrorClientInvalid // client is not allowed to issue the request, etc.
    case paymentCancelled = 2 //SKErrorPaymentCancelled // user cancelled the request, etc.
    case paymentInvalid = 3 //SKErrorPaymentInvalid  // purchase identifier was invalid, etc.
    case paymentNotAllowed = 4 //SKErrorPaymentNotAllowed // this device is not allowed to make the payment
    case productNotAvailable = 5 //SKErrorStoreProductNotAvailable // Product is not available in the current storefront
}

extension NSError {
    struct GratuitousPurchaseError {
        static let domainKey = NSError.Gratuity.DomainKey
        
        enum ErrorCode: Int {
            case restorePurchasesAlreadyInProgress = 2001
            case purchaseAlreadyInProgress = 2018
            case productRequestFailed = 2002
            case purchaseDeferred = 2003
            case restoreSucceededSplitBillNotPurchased = 2005
            case restoreFailedUnknown = 2006
            case restoreFailedClientInvalid = 2007
            case restoreFailedPaymentInvalid = 2009
            case restoreFailedPaymentNotAllowed = 2010
            case restoreFailedProductNotAvailable = 2011
            case purchaseFailedUnknown = 2012
            case purchaseFailedClientInvalid = 2013
            case purchaseFailedPaymentInvalid = 2015
            case purchaseFailedPaymentNotAllowed = 2016
            case purchaseFailedProductNotAvailable = 2017
        }
    }
    
    convenience init(purchaseError: GratuitousPurchaseError.ErrorCode) {
        let errorDomain = GratuitousPurchaseError.domainKey
        let code = purchaseError.rawValue
        
        let localizedDescription: String
        let localizedRecoverySuggestion: String
        switch purchaseError {
        case .restorePurchasesAlreadyInProgress:
            localizedDescription = NSError.Gratuity.LocalizedString.RestorePurchasesAlreadyInProgressDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestorePurchasesAlreadyInProgressRecovery
        case .purchaseAlreadyInProgress:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseAlreadyInProgressDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseAlreadyInProgressRecovery
        case .productRequestFailed:
            localizedDescription = NSError.Gratuity.LocalizedString.ProductRequestFailedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.ProductRequestFailedRecovery
        case .purchaseDeferred:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseDeferredDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseDeferredRecovery
        case .restoreSucceededSplitBillNotPurchased:
            localizedDescription = NSError.Gratuity.LocalizedString.RestoreSucceededSplitBillNotPurchasedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestoreSucceededSplitBillNotPurchasedRecovery
        case .restoreFailedUnknown, .restoreFailedClientInvalid, .restoreFailedPaymentInvalid, .restoreFailedProductNotAvailable:
            localizedDescription = NSError.Gratuity.LocalizedString.RestoreFailedUnknownDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestoreFailedUnknownRecovery
        case .purchaseFailedUnknown, .purchaseFailedClientInvalid, .purchaseFailedPaymentInvalid, .purchaseFailedProductNotAvailable:
            localizedDescription = NSError.Gratuity.LocalizedString.PurchaseFailedUnknownDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.PurchaseFailedUnknownRecovery
        case .restoreFailedPaymentNotAllowed:
            localizedDescription = NSError.Gratuity.LocalizedString.RestoreFailedPaymentNotAllowedDescription
            localizedRecoverySuggestion = NSError.Gratuity.LocalizedString.RestoreFailedPaymentNotAllowedRecovery
        case .purchaseFailedPaymentNotAllowed:
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
        if let _ = GratuitousPurchaseError.ErrorCode(rawValue: self.code), self.domain == GratuitousPurchaseError.domainKey {
            return true
        } else {
            return false
        }
    }
}

extension UIAlertController {
    enum CustomStyle {
        case emailContactSupport
    }
    
    convenience init(actions: [UIAlertAction], error: NSError?) {
        let localizedDescription = error?.userInfo[NSLocalizedDescriptionKey] as? String ?? UIAlertController.Gratuity.LocalizedString.UnknownErrorDescription
        let localizedRecoverySuggestion = error?.userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String ?? UIAlertController.Gratuity.LocalizedString.UnknownErrorRecovery
        
        self.init(title: localizedDescription, message: localizedRecoverySuggestion, preferredStyle: UIAlertControllerStyle.alert)
        
        for action in actions {
            self.addAction(action)
        }
    }
}

extension UIAlertAction {
    enum Kind {
        case dismiss
        case emailSupport
        case copyEmailAddress
        case buy
    }
    
    convenience init(kind: Kind, completionHandler: ((UIAlertAction) -> Void)?) {
        let title: String
        let style: UIAlertActionStyle
        switch kind {
        case .dismiss:
            title = UIAlertAction.Gratuity.LocalizedString.Dismiss
            style = .cancel
        case .emailSupport:
            title = UIAlertAction.Gratuity.LocalizedString.EmailSupport
            style = .default
        case .copyEmailAddress:
            title = AutoMailViewController.LocalizedString.CopyEmailButton
            style = .default
        case .buy:
            title = UIAlertAction.Gratuity.LocalizedString.Buy
            style = .default
        }
        self.init(title: title, style: style, handler: completionHandler)
    }
}
