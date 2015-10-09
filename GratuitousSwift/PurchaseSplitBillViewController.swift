//
//  PurchaseSplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit
import AVFoundation
import MessageUI

class PurchaseSplitBillViewController: SmallModalScollViewController {
    
    // MARK: Instance Variables
    
    @IBOutlet private weak var videoPlayerView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionParagraphLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var purchaseButton: UIButton?
    @IBOutlet private weak var restoreButton: UIButton?
    @IBOutlet private weak var purchaseButtonSpinnerWidthConstraint: NSLayoutConstraint? // need to be strong or else they are released when inactive
    @IBOutlet private weak var restoreButtonSpinnerWidthConstraint: NSLayoutConstraint? // need to be strong or else they are released when inactive
    @IBOutlet private weak var purchaseButtonSpinner: UIActivityIndicatorView?
    @IBOutlet private weak var restoreButtonSpinner: UIActivityIndicatorView?
    
    private var dataSource: GratuitousiOSDataSource = (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).dataSource
    
    enum State {
        case Normal
        case RestoreInProgress
        case PurchaseInProgress
        case SplitBillProductNotFoundInStoreFront
    }
    
    private var state = State.Normal {
        didSet {
            UIView.animateWithDuration(0.3) {
                let buttomDimmedAlpha = CGFloat(0.6)
                let buttonFullAlpha = CGFloat(1.0)
                switch self.state {
                case .Normal:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = true
                    self.restoreButton?.enabled = true
                    self.purchaseButton?.alpha = buttonFullAlpha
                    self.restoreButton?.alpha = buttonFullAlpha
                case .RestoreInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 1
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                    self.purchaseButton?.alpha = buttomDimmedAlpha
                    self.restoreButton?.alpha = buttomDimmedAlpha
                case .PurchaseInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                    self.purchaseButton?.alpha = buttomDimmedAlpha
                    self.restoreButton?.alpha = buttomDimmedAlpha
                case .SplitBillProductNotFoundInStoreFront:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                    self.purchaseButton?.alpha = buttomDimmedAlpha
                    self.restoreButton?.alpha = buttomDimmedAlpha
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = NSBundle.mainBundle().pathForResource("gratuityInfoDemoVideo@2x", ofType: "mov") {
            let player = AVPlayer(URL: NSURL.fileURLWithPath(moviePath))
            player.allowsExternalPlayback = false
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None // cause the player to loop
            let playerLayer = AVPlayerLayer(player: player)
            return (player, playerLayer)
        }
        return nil
        }()
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource.purchaseManager?.beginObserving()
        self.requestSplitBillProductWithCompletionHandler()
        self.state = .SplitBillProductNotFoundInStoreFront
        
        if let videoPlayer = self.videoPlayer {
            let player = videoPlayer.player
            let layer = videoPlayer.layer
            
            let desiredSize = self.videoPlayerView?.frame.size
            var desiredFrame = CGRect(x: 0, y: 0, width: 640, height: 1136)
            if let desiredSize = desiredSize {
                desiredFrame = CGRect(origin: CGPointZero, size: desiredSize)
            }
            
            layer.frame = desiredFrame
            layer.backgroundColor = UIColor.blackColor().CGColor
            layer.videoGravity = AVLayerVideoGravityResizeAspect
            
            self.videoPlayerView?.layer.addSublayer(layer)
            self.videoPlayerView?.clipsToBounds = true
            
            //player.play()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seekToTime(kCMTimeZero)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlaybackFinished:", name: AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.player.currentItem)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func configureDynamicTextLabels() {
        super.configureDynamicTextLabels()
        
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = headlineFont.pointSize * 2
        
        //configure the large title label
        self.titleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .Headline)
        self.titleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.titleLabel?.text = NSLocalizedString("Gratuity", comment: "Large Title of Watch Info View Controller")
        
        //configure the subtitle label
        self.subtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .Headline)
        self.subtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.subtitleLabel?.text = NSLocalizedString("Split Bill", comment: "Subtitle for the purchase split bill view controller")
        
        //configure the paragraph of text
        self.descriptionParagraphLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.descriptionParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.descriptionParagraphLabel?.text = NSLocalizedString("The Split Bill feature of Gratuity is offered as an in-app purchase. You can purchase this feature below. If you have already purchased this feature, tap the 'Restore' button below.", comment: "Paragraph that how to purchase the split bill feature.")
        
        // configure the button text
        self.configureBuyButton()
        self.restoreButton?.setTitle("Restore Purchases", forState: UIControlState.Normal)
    }
    
    private func configureBuyButton() {
        if let priceString = self.priceString {
            let purchaseString = NSLocalizedString("Buy – \(priceString)", comment: "")
            self.purchaseButton?.setTitle(purchaseString, forState: UIControlState.Normal)
        } else {
            // need to request the product!!!
            let downloadingLocalizedString = NSLocalizedString("Downloading Price...", comment: "")
            self.purchaseButton?.setTitle(downloadingLocalizedString, forState: UIControlState.Normal)
        }
    }
    
    // MARK: Purchasing
    
    private let priceNumberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        return formatter
    }()
    
    private var priceString: String? {
        let priceString: String?
        if let splitBillProduct = self.splitBillProduct {
            self.priceNumberFormatter.locale = splitBillProduct.priceLocale
            priceString = self.priceNumberFormatter.stringFromNumber(splitBillProduct.price)
            return priceString
        } else {
            return .None
        }
    }
    
    private var splitBillProduct: SKProduct? {
        didSet {
            self.configureBuyButton()
        }
    }
    
    private func requestSplitBillProductWithCompletionHandler() {
        let request = SKProductsRequest(productIdentifiers: Set([GratuitousPurchaseManager.splitBillPurchaseIdentifier]))
        self.dataSource.purchaseManager?.initiateRequest(request) { [weak self] request, response, error in
            self?.state = .Normal
            let guaranteedSplitBillProductArray = response?.products.filter() { product -> Bool in
                if product.productIdentifier == GratuitousPurchaseManager.splitBillPurchaseIdentifier {
                    return true
                } else {
                    return false
                }
            }
            
            if let splitBillProduct = guaranteedSplitBillProductArray?.first {
                self?.splitBillProduct = splitBillProduct
            } else {
                let userFacingError = NSError(purchaseError: .ProductRequestFailed)
                let dismissAction = UIAlertAction(type: .Dismiss, completionHandler: self?.didTapDismissButtonThatClosesCurrentViewController)
                let errorVC = UIAlertController(actions: [dismissAction], error: userFacingError)
                self?.presentViewController(errorVC, animated: true, completion: .None)
            }
        }
    }

    // MARK: Handle Looping the Video Player
    
    @objc private func videoPlaybackFinished(notification: NSNotification) {
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seekToTime(kCMTimeZero)
        }
    }
    
    // MARK: Handle User Input
    
    @IBAction private func didTapPurchaseButton(sender: UIButton?) {
        guard let splitBillProduct = self.splitBillProduct else { return }
        self.state = .PurchaseInProgress
        self.dataSource.purchaseManager?.initiatePurchaseWithPayment(SKPayment(product: splitBillProduct)) { transaction in
            
            // change the UI back to normal state
            self.state = .Normal
            // update the preferences
            if transaction.transactionState == .Deferred {
                // if the transaction is deferred I give temporary access.
                // the receipt is checked on every launch, so this will get undone if it doesn't get deferred
                self.dataSource.defaultsManager.splitBillPurchased = true
            } else {
                // update the preference based on the receipt
                // the receipt is the source of truth, all the error handling is just sugar coating
                if let splitBillPurchased = self.dataSource.purchaseManager?.verifySplitBillPurchaseTransaction() {
                    self.dataSource.defaultsManager.splitBillPurchased = splitBillPurchased
                }
            }
            
            // We need to finish the transaction unless its in the Deferred or Purchasing state
            switch transaction.transactionState {
            case .Purchased, .Restored, .Failed:
                self.dataSource.purchaseManager?.finishTransaction(transaction)
            case .Deferred, .Purchasing:
                break //do nothing
            }
            
            // lets present stuff to the user
            if let userFacingErrorTuple = self.errorErrorForPurchaseTransaction(transaction) {
                // an error ocurred, lets show it to the user.
                let alertVC = UIAlertController(actions: userFacingErrorTuple.userAlertActions, error: userFacingErrorTuple.userFacingError)
                if let _ = self.presentingViewController {
                    // if this view controller has been dismissed, I don't want to try and present this error, it will fail anwyway
                    self.presentViewController(alertVC, animated: true, completion: .None)
                }
            } else {
                switch transaction.transactionState {
                case .Purchased, .Restored:
                    let presentingViewController = self.presentingViewController
                    self.dismissViewControllerAnimated(true, completion: {
                        presentingViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
                    })
                case .Deferred, .Failed, .Purchasing:
                    break //do nothing
                }
            }
        }
    }
    
    @IBAction private func didTapRestoreButton(sender: UIButton?) {
        self.state = .RestoreInProgress
        self.dataSource.purchaseManager?.restorePurchasesWithCompletionHandler() { queue, error in
            
            // change the UI back to normal state
            self.state = .Normal
            // update the preference based on the receipt
            // the receipt is the source of truth, all the error handling is just sugar coating
            let splitBillPurchased: Bool
            if let purchased = self.dataSource.purchaseManager?.verifySplitBillPurchaseTransaction() {
                self.dataSource.defaultsManager.splitBillPurchased = purchased
                splitBillPurchased = purchased
            } else {
                splitBillPurchased = false
            }
            
            if let error = error {
                // the restore had some sort of error
                if let userFacingErrorTuple = self.errorFromRestoreError(error) {
                    // an error ocurred, lets show it to the user.
                    let alertVC = UIAlertController(actions: userFacingErrorTuple.userAlertActions, error: userFacingErrorTuple.userFacingError)
                    if let _ = self.presentingViewController {
                        // if this view controller has been dismissed, I don't want to try and present this error, it will fail anwyway
                        self.presentViewController(alertVC, animated: true, completion: .None)
                    }
                }
            } else {
                // restoration completed successfully
                if splitBillPurchased == true {
                    // the purchase was restored by the restore attempt
                    let presentingViewController = self.presentingViewController
                    self.dismissViewControllerAnimated(true) {
                        presentingViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
                    }
                } else {
                    // the restoration was successful, but the customer never purchased the product
                    let actions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .Buy, completionHandler: self.didTapAlertBuyButton),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                    let error = NSError(purchaseError: .RestoreSucceededSplitBillNotPurchased)
                    let alertVC = UIAlertController(actions: actions, error: error)
                    if let _ = self.presentingViewController {
                        // if this view controller has been dismissed, I don't want to try and present this error, it will fail anwyway
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: Callbacks for UIAlertViewController
    
    private func didTapDismisseAlertButtonForDeferredPurchase(action: UIAlertAction) {
        let presentingViewController = self.presentingViewController
        self.dismissViewControllerAnimated(true, completion: {
            presentingViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
        })
    }
    
    private func didTapDismissButtonThatClosesCurrentViewController(action: UIAlertAction) {
        self.dismissViewControllerAnimated(true, completion: .None)
    }
    
    private func didTapAlertBuyButton(action: UIAlertAction) {
        self.didTapPurchaseButton(.None)
    }
    
    private func didTapEmailSupportActionButton(action: UIAlertAction) {
        let emailManager = EmailSupportHandler(type: .GenericEmailSupport, delegate: self)
        if let mailVC = emailManager.presentableMailViewController {
            self.presentViewController(mailVC, animated: true, completion: .None)
        } else {
            emailManager.switchAppForEmailSupport()
        }
    }
    
    // MARK: Handle Going Away
    
    deinit {
        self.dataSource.purchaseManager?.endObserving()
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension PurchaseSplitBillViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.state = .Normal
        self.dismissViewControllerAnimated(true, completion: .None)
        if let error = error {
            NSLog("AboutTableViewController: Error while sending email. Error Description: \(error.description)")
        }
    }
}

// MARK: Crazy Error Code Logic for Purchases and Restores

extension PurchaseSplitBillViewController {
    private typealias UserFacingError = (userFacingError: NSError, userAlertActions: [UIAlertAction])
    private func errorErrorForPurchaseTransaction(transaction: SKPaymentTransaction) -> UserFacingError? {
        let userFacingError: NSError?
        let userAlertActions: [UIAlertAction]
        
        if let error = transaction.error {
            if let reason = StoreKitPurchaseErrorCode(rawValue: error.code) {
                switch reason {
                case .Unknown:
                    userFacingError = NSError(purchaseError: .PurchaseFailedUnknown)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .ClientInvalid:
                    userFacingError = NSError(purchaseError: .PurchaseFailedClientInvalid)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .PaymentCancelled:
                    userFacingError = .None
                    userAlertActions = []
                case .PaymentInvalid:
                    userFacingError = NSError(purchaseError: .PurchaseFailedPaymentInvalid)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .PaymentNotAllowed:
                    userFacingError = NSError(purchaseError: .PurchaseFailedPaymentNotAllowed)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .ProductNotAvailable:
                    userFacingError = NSError(purchaseError: .PurchaseFailedProductNotAvailable)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                }
            } else {
                // there was an error but it didn't match one of the known codes
                if error.isaGratuitousPurchaseError() == true {
                    // if we already custom crafted this error, we can show it to the user
                    userFacingError = error
                } else {
                    // otherwise we'll give a generic failure
                    userFacingError = NSError(purchaseError: .RestoreFailedUnknown)
                }
                userAlertActions = [
                    UIAlertAction(type: .Dismiss, completionHandler: .None),
                    UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                ]
            }
        } else {
            // there was no error, so lets check the transaction state
            switch transaction.transactionState {
            case .Purchased, .Restored:
                // true true success
                userFacingError = .None
                userAlertActions = []
            case .Deferred:
                // Deferred for parents to approve, granting temporary access
                userFacingError = NSError(purchaseError: .PurchaseDeferred)
                userAlertActions = [UIAlertAction(type: .Dismiss, completionHandler: self.didTapDismisseAlertButtonForDeferredPurchase)]
            case .Failed:
                // not sure how we made it this far, but thats OK, unknown error
                userFacingError = NSError(purchaseError: .PurchaseFailedUnknown)
                userAlertActions = [
                    UIAlertAction(type: .Dismiss, completionHandler: .None),
                    UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                ]
            case .Purchasing:
                // should not ever see this but will do nothing because most likely stuff is still in progress
                userFacingError = .None
                userAlertActions = []
            }
        }
        
        if let userFacingError = userFacingError {
            return (userFacingError: userFacingError, userAlertActions: userAlertActions)
        } else {
            return .None
        }
    }
    
    private func errorFromRestoreError(error: NSError?) -> UserFacingError? {
        let userFacingError: NSError?
        let userAlertActions: [UIAlertAction]
        
        if let error = error {
            if let reason = StoreKitPurchaseErrorCode(rawValue: error.code) {
                switch reason {
                case .Unknown:
                    userFacingError = NSError(purchaseError: .RestoreFailedUnknown)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .ClientInvalid:
                    userFacingError = NSError(purchaseError: .RestoreFailedClientInvalid)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .PaymentCancelled:
                    userFacingError = .None
                    userAlertActions = []
                case .PaymentInvalid:
                    userFacingError = NSError(purchaseError: .RestoreFailedPaymentInvalid)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .PaymentNotAllowed:
                    userFacingError = NSError(purchaseError: .RestoreFailedPaymentNotAllowed)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .ProductNotAvailable:
                    userFacingError = NSError(purchaseError: .RestoreFailedProductNotAvailable)
                    userAlertActions = [
                        UIAlertAction(type: .Dismiss, completionHandler: .None),
                        UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                }
            } else {
                // there was an error but it didn't match one of the known codes
                if error.isaGratuitousPurchaseError() == true {
                    // if we already custom crafted this error, we can show it to the user
                    userFacingError = error
                } else {
                    // otherwise we'll give a generic failure
                    userFacingError = NSError(purchaseError: .RestoreFailedUnknown)
                }
                userAlertActions = [
                    UIAlertAction(type: .Dismiss, completionHandler: .None),
                    UIAlertAction(type: .EmailSupport, completionHandler: self.didTapEmailSupportActionButton)
                ]
            }
        } else {
            // there was no error, there's probably not an issue.
            userFacingError = .None
            userAlertActions = []
        }
        
        if let userFacingError = userFacingError {
            return (userFacingError: userFacingError, userAlertActions: userAlertActions)
        } else {
            return .None
        }
    }
}
