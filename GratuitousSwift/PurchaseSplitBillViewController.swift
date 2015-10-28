//
//  PurchaseSplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import MessageUI
import XCGLogger
import AVFoundation
import Crashlytics

final class PurchaseSplitBillViewController: SmallModalScollViewController {
    
    // MARK: Instance Variables
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionParagraphLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var purchaseButton: GratuitousBorderedButton?
    @IBOutlet private weak var restoreButton: GratuitousBorderedButton?
    @IBOutlet private weak var modalBlockingView: UIView?
    @IBOutlet private var descriptionParagraphHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var purchaseButtonSpinnerWidthConstraint: NSLayoutConstraint? // need to be strong or else they are released when inactive
    @IBOutlet private weak var restoreButtonSpinnerWidthConstraint: NSLayoutConstraint? // need to be strong or else they are released when inactive
    @IBOutlet private weak var purchaseButtonSpinner: UIActivityIndicatorView?
    @IBOutlet private weak var restoreButtonSpinner: UIActivityIndicatorView?
    @IBOutlet private weak var videoPlayerSurroundView: UIView?
    @IBOutlet private weak var videoPlayerView: UIView?
    
    private let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = NSBundle.mainBundle().pathForResource("gratuityiOSDemoVideo@2x", ofType: "mp4") {
            let player = AVPlayer(URL: NSURL.fileURLWithPath(moviePath))
            player.allowsExternalPlayback = false
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.None // cause the player to loop
            let playerLayer = AVPlayerLayer(player: player)
            return (player, playerLayer)
        }
        return nil
    }()
    
    private let log = XCGLogger.defaultInstance()
    
    private let purchaseManager = GratuitousPurchaseManager()
    private var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferencesSetLocally = newValue }
    }
    
    enum State {
        case Normal
        case RestoreInProgress
        case PurchaseInProgress
        case SplitBillProductNotFoundInStoreFront
    }
    
    private var state = State.Normal {
        didSet {
            UIView.animateWithDuration(GratuitousUIConstant.animationDuration()) {
                let modalPresentAlpha = CGFloat(0.5)
                let modalInvisibleAlpha = CGFloat(0.0)
                switch self.state {
                case .Normal:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = true
                    self.restoreButton?.enabled = true
                    self.purchaseButton?.alpha = 1
                    self.restoreButton?.alpha = 1
                    self.descriptionParagraphHeightConstraint?.active = false
                    self.modalBlockingView?.alpha = modalInvisibleAlpha
                case .RestoreInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 1
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                    self.purchaseButton?.alpha = 1
                    self.restoreButton?.alpha = 1
                    self.descriptionParagraphHeightConstraint?.active = false
                    self.modalBlockingView?.alpha = modalPresentAlpha
                case .PurchaseInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                    self.purchaseButton?.alpha = 1
                    self.restoreButton?.alpha = 1
                    self.descriptionParagraphHeightConstraint?.active = false
                    self.modalBlockingView?.alpha = modalPresentAlpha
                case .SplitBillProductNotFoundInStoreFront:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                    self.purchaseButton?.alpha = 0.6
                    self.restoreButton?.alpha = 0
                    self.descriptionParagraphHeightConstraint?.active = true
                    self.modalBlockingView?.alpha = modalInvisibleAlpha
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.purchaseManager.beginObserving()
        self.requestSplitBillProductWithCompletionHandler()
        self.state = .SplitBillProductNotFoundInStoreFront
        
        self.videoPlayerSurroundView?.layer.borderWidth = 1
        self.videoPlayerSurroundView?.layer.cornerRadius = 8
        self.videoPlayerSurroundView?.layer.borderColor = GratuitousUIColor.lightTextColor().CGColor
        
        if let videoPlayer = self.videoPlayer {
            let layer = videoPlayer.layer
            
            self.updateViewPlayerBounds()
            layer.backgroundColor = UIColor.blackColor().CGColor
            layer.videoGravity = AVLayerVideoGravityResizeAspect
            
            self.videoPlayerView?.layer.addSublayer(layer)
            self.videoPlayerView?.clipsToBounds = true
        }

    }
    
    override func configureDynamicTextLabels() {
        super.configureDynamicTextLabels()
        
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = headlineFont.pointSize * 2
        
        //configure the large title label
        self.titleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .Headline)
        self.titleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.titleLabel?.text = PurchaseSplitBillViewController.LocalizedString.ExtraLargeTextLabel
        
        //configure the subtitle label
        self.subtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .Headline)
        self.subtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.subtitleLabel?.text = PurchaseSplitBillViewController.LocalizedString.LargeTextLabel
        
        //configure the navigation bar
        self.navigationBar?.items?.first?.title = PurchaseSplitBillViewController.LocalizedString.NavBarTitleLabel
        
        //configure the paragraph of text
        self.descriptionParagraphLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.descriptionParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        //configure the button text
        self.purchaseButton?.titleStyle = .Headline
        self.restoreButton?.titleStyle = .Subheadline
        
        // configure the button text
        self.configureDynamicElements()
        self.restoreButton?.setTitle(PurchaseSplitBillViewController.LocalizedString.RestorePurchasesButton, forState: UIControlState.Normal)
    }
    
    private func configureDynamicElements() {
        if let splitBillProduct = self.splitBillProduct {
            let purchaseString = PurchaseSplitBillViewController.LocalizedString.PurchaseButtonText
            self.purchaseButton?.setTitle(purchaseString + " – \(self.priceString)", forState: UIControlState.Normal)
            self.descriptionParagraphLabel?.text = splitBillProduct.localizedDescription ?? ""
            
        } else {
            // need to request the product!!!
            let downloadingLocalizedString = PurchaseSplitBillViewController.LocalizedString.DownloadingAppStoreInfoButtonText
            self.purchaseButton?.setTitle(downloadingLocalizedString, forState: UIControlState.Normal)
            self.descriptionParagraphLabel?.text = ""
        }
    }
    
    private func updateViewPlayerBounds() -> Bool {
        if let videoPlayerViewBounds = self.videoPlayerView?.bounds, let videoLayer = self.videoPlayer?.layer {
            videoLayer.frame = videoPlayerViewBounds
            return true
        } else {
            return false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewPlayerBounds()
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seekToTime(kCMTimeZero)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoPlaybackFinished:", name: AVPlayerItemDidPlayToEndTimeNotification, object: videoPlayer.player.currentItem)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewPlayerBounds()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.videoPlayer?.player.play()
        }
        Answers.logContentViewWithName(AnswersString.ViewDidAppear, contentType: .None, contentId: .None, customAttributes: .None)
    }
    
    @objc private func videoPlaybackFinished(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.videoPlayer?.player.pause()
            self.videoPlayer?.player.seekToTime(kCMTimeZero)
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.videoPlayer?.player.play()
            }
        }
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ context in self.updateViewPlayerBounds() }, completion: .None)
    }
    
    // MARK: Purchasing
    
    private let priceNumberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        return formatter
    }()
    
    private var priceString: String {
        let priceString: String?
        if let splitBillProduct = self.splitBillProduct {
            self.priceNumberFormatter.locale = splitBillProduct.priceLocale
            priceString = self.priceNumberFormatter.stringFromNumber(splitBillProduct.price)
        } else {
            priceString = .None
        }
        return priceString ?? ""
    }
    
    private var splitBillProduct: SKProduct? {
        didSet {
            self.configureDynamicElements()
        }
    }
    
    private func requestSplitBillProductWithCompletionHandler() {
        let request = SKProductsRequest(productIdentifiers: Set([GratuitousPurchaseManager.splitBillPurchaseIdentifier]))
        self.purchaseManager.initiateRequest(request) { [weak self] request, response, error in
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
                let actions = [
                    UIAlertAction(type: .Dismiss, completionHandler: self?.didTapDismissButtonThatClosesCurrentViewController),
                    UIAlertAction(type: .EmailSupport, completionHandler: self?.didTapEmailSupportActionButton)
                ]
                self?.shouldDismissVCAfterEmailVCDismisses = true
                let errorVC = UIAlertController(actions: actions, error: userFacingError)
                self?.presentViewController(errorVC, animated: true, completion: .None)
            }
            self?.state = .Normal
        }
    }
    
    // MARK: Handle User Input
    
    @IBAction private func didTapPurchaseButton(sender: UIButton?) {
        guard let splitBillProduct = self.splitBillProduct else { return }
        self.state = .PurchaseInProgress
        Answers.logCustomEventWithName(AnswersString.DidStartPurchase, customAttributes: .None)
        self.purchaseManager.initiatePurchaseWithPayment(SKPayment(product: splitBillProduct)) { transaction in
            // change the UI back to normal state
            self.state = .Normal
            // update the preferences
            let purchased = self.purchaseManager.verifySplitBillPurchaseTransaction()
            if transaction.transactionState == .Deferred {
                // if the transaction is deferred I give temporary access.
                // the receipt is checked on every launch, so this will get undone if it doesn't get deferred
                self.applicationPreferences.splitBillPurchased = true
            } else {
                // update the preference based on the receipt
                // the receipt is the source of truth, all the error handling is just sugar coating
                self.applicationPreferences.splitBillPurchased = purchased
            }
            
            // We need to finish the transaction unless its in the Deferred or Purchasing state
            switch transaction.transactionState {
            case .Purchased, .Restored, .Failed:
                self.purchaseManager.finishTransaction(transaction)
            case .Deferred, .Purchasing:
                break //do nothing
            }
            
            // lets present stuff to the user
            let answersError: NSError?
            if let userFacingErrorTuple = self.errorErrorForPurchaseTransaction(transaction) {
                // an error ocurred, lets show it to the user.
                let alertVC = UIAlertController(actions: userFacingErrorTuple.userAlertActions, error: userFacingErrorTuple.userFacingError)
                if let _ = self.presentingViewController {
                    // if this view controller has been dismissed, I don't want to try and present this error, it will fail anwyway
                    self.presentViewController(alertVC, animated: true, completion: .None)
                }
                answersError = userFacingErrorTuple.userFacingError
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
                answersError = transaction.error
            }
            
            if purchased == true {
                // its purchased but we need to see if it was already bought before or if its truly a new purchase
                let calendar = NSCalendar.currentCalendar()
                if let purchaseDate = self.purchaseManager.splitBillPurchaseData()
                    where calendar.isDateInToday(purchaseDate) == true
                {
                    Answers.logPurchaseWithPrice(splitBillProduct.price, currency: splitBillProduct.priceLocale.localeIdentifier, success: NSNumber(bool: purchased), itemName: splitBillProduct.localizedTitle, itemType: "In-App-Purchase", itemId: splitBillProduct.productIdentifier, customAttributes: answersError?.dictionaryForAnswers)
                    Answers.logCustomEventWithName(AnswersString.PurchaseSucceededNotBoughtBefore, customAttributes: answersError?.dictionaryForAnswers)
                } else {
                    Answers.logCustomEventWithName(AnswersString.PurchaseSucceededAlreadyBought, customAttributes: answersError?.dictionaryForAnswers)
                }
            } else {
                Answers.logCustomEventWithName(AnswersString.PurchaseFailed, customAttributes: answersError?.dictionaryForAnswers)
            }
        }
    }
    
    private func dateIsToday(queryDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        calendar.isDateInToday(queryDate)
        return false
    }
    
    @IBAction private func didTapRestoreButton(sender: UIButton?) {
        self.state = .RestoreInProgress
        Answers.logCustomEventWithName(AnswersString.DidStartRestore, customAttributes: .None)
        self.purchaseManager.restorePurchasesWithCompletionHandler() { queue, error in
            
            // change the UI back to normal state
            self.state = .Normal
            // update the preference based on the receipt
            // the receipt is the source of truth, all the error handling is just sugar coating
            let splitBillPurchased = self.purchaseManager.verifySplitBillPurchaseTransaction()
            self.applicationPreferences.splitBillPurchased = splitBillPurchased
            
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
                Answers.logCustomEventWithName(AnswersString.RestoreFailed, customAttributes: error.dictionaryForAnswers)
            } else {
                // restoration completed successfully
                if splitBillPurchased == true {
                    // the purchase was restored by the restore attempt
                    let presentingViewController = self.presentingViewController
                    self.dismissViewControllerAnimated(true) {
                        presentingViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
                    }
                    Answers.logCustomEventWithName(AnswersString.RestoreSucceededAlreadyBought, customAttributes: .None)
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
                    Answers.logCustomEventWithName(AnswersString.RestoreSucceededNotBought, customAttributes: error.dictionaryForAnswers)
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
    
    private var shouldDismissVCAfterEmailVCDismisses = false
    
    private func didTapEmailSupportActionButton(action: UIAlertAction) {
        let emailManager = EmailSupportHandler(type: .GenericEmailSupport, delegate: self)
        if let mailVC = emailManager.presentableMailViewController {
            Answers.logCustomEventWithName(AnswersString.DidOpenInternalEmail, customAttributes: .None)
            self.presentViewController(mailVC, animated: true, completion: .None)
        } else {
            Answers.logCustomEventWithName(AnswersString.DidOpenExternalEmail, customAttributes: .None)
            emailManager.switchAppForEmailSupport()
        }
    }
    
    // MARK: Handle Going Away
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        self.purchaseManager.endObserving()
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension PurchaseSplitBillViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.state = .Normal
        controller.dismissViewControllerAnimated(true) {
            if self.shouldDismissVCAfterEmailVCDismisses == true {
                self.dismissViewControllerAnimated(true, completion: .None)
            }
        }
        if let error = error {
            self.log.error("Error while sending email. Error Description: \(error.description)")
        }
        
        switch result {
        case MFMailComposeResultCancelled:
            Answers.logCustomEventWithName(AnswersString.DidCancelEmail, customAttributes: error?.dictionaryForAnswers)
        case MFMailComposeResultSent:
            Answers.logCustomEventWithName(AnswersString.DidSendEmail, customAttributes: error?.dictionaryForAnswers)
        case MFMailComposeResultSaved:
            Answers.logCustomEventWithName(AnswersString.DidSaveEmail, customAttributes: error?.dictionaryForAnswers)
        case MFMailComposeResultFailed:
            Answers.logCustomEventWithName(AnswersString.DidFailEmail, customAttributes: error?.dictionaryForAnswers)
        default:
            break
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
