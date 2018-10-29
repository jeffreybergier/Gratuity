//
//  PurchaseSplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import MessageUI
import AVFoundation
import UIKit

final class PurchaseSplitBillViewController: SmallModalScollViewController {
    
    // MARK: Instance Variables
    
    @IBOutlet fileprivate weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var descriptionParagraphLabel: UILabel?
    @IBOutlet fileprivate weak var subtitleLabel: UILabel?
    @IBOutlet fileprivate weak var purchaseButton: GratuitousBorderedButton?
    @IBOutlet fileprivate weak var restoreButton: GratuitousBorderedButton?
    @IBOutlet fileprivate weak var modalBlockingView: UIView?
    @IBOutlet fileprivate var descriptionParagraphHeightConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate weak var purchaseButtonSpinnerWidthConstraint: NSLayoutConstraint? // need to be strong or else they are released when inactive
    @IBOutlet fileprivate weak var restoreButtonSpinnerWidthConstraint: NSLayoutConstraint? // need to be strong or else they are released when inactive
    @IBOutlet fileprivate weak var purchaseButtonSpinner: UIActivityIndicatorView?
    @IBOutlet fileprivate weak var restoreButtonSpinner: UIActivityIndicatorView?
    @IBOutlet fileprivate weak var videoPlayerSurroundView: UIView?
    @IBOutlet fileprivate weak var videoPlayerView: UIView?
    
    fileprivate let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = Bundle.main.path(forResource: "gratuityiOSDemoVideo@2x", ofType: "mp4") {
            let player = AVPlayer(url: URL(fileURLWithPath: moviePath))
            player.allowsExternalPlayback = false
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.none // cause the player to loop
            let playerLayer = AVPlayerLayer(player: player)
            return (player, playerLayer)
        }
        return nil
    }()
        
    fileprivate let purchaseManager = GratuitousPurchaseManager()
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        get { return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences }
        set { (UIApplication.shared.delegate as! GratuitousAppDelegate).preferencesSetLocally = newValue }
    }
    
    enum State {
        case normal
        case restoreInProgress
        case purchaseInProgress
        case splitBillProductNotFoundInStoreFront
    }
    
    fileprivate var state = State.normal {
        didSet {
            UIView.animate(withDuration: GratuitousUIConstant.animationDuration(), animations: {
                let modalPresentAlpha = CGFloat(0.5)
                let modalInvisibleAlpha = CGFloat(0.0)
                switch self.state {
                case .normal:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.isEnabled = true
                    self.restoreButton?.isEnabled = true
                    self.purchaseButton?.alpha = 1
                    self.restoreButton?.alpha = 1
                    self.descriptionParagraphHeightConstraint?.isActive = false
                    self.modalBlockingView?.alpha = modalInvisibleAlpha
                case .restoreInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 1
                    self.purchaseButton?.isEnabled = false
                    self.restoreButton?.isEnabled = false
                    self.purchaseButton?.alpha = 1
                    self.restoreButton?.alpha = 1
                    self.descriptionParagraphHeightConstraint?.isActive = false
                    self.modalBlockingView?.alpha = modalPresentAlpha
                case .purchaseInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.isEnabled = false
                    self.restoreButton?.isEnabled = false
                    self.purchaseButton?.alpha = 1
                    self.restoreButton?.alpha = 1
                    self.descriptionParagraphHeightConstraint?.isActive = false
                    self.modalBlockingView?.alpha = modalPresentAlpha
                case .splitBillProductNotFoundInStoreFront:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.isEnabled = false
                    self.restoreButton?.isEnabled = false
                    self.purchaseButton?.alpha = 0.6
                    self.restoreButton?.alpha = 0
                    self.descriptionParagraphHeightConstraint?.isActive = true
                    self.modalBlockingView?.alpha = modalInvisibleAlpha
                }
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.purchaseManager.beginObserving()
        self.requestSplitBillProductWithCompletionHandler()
        self.state = .splitBillProductNotFoundInStoreFront
        
        self.videoPlayerSurroundView?.layer.borderWidth = 1
        self.videoPlayerSurroundView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.videoPlayerSurroundView?.layer.borderColor = GratuitousUIColor.lightTextColor().cgColor
        
        if let videoPlayer = self.videoPlayer {
            let layer = videoPlayer.layer
            
            self.updateViewPlayerBounds()
            layer.backgroundColor = UIColor.black.cgColor
            layer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            self.videoPlayerView?.layer.addSublayer(layer)
            self.videoPlayerView?.clipsToBounds = true
        }

    }
    
    override func configureDynamicTextLabels() {
        super.configureDynamicTextLabels()
        
        let headlineFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        let headlineFontSize = headlineFont.pointSize * 2
        
        //configure the large title label
        self.titleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .headline)
        self.titleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.titleLabel?.text = PurchaseSplitBillViewController.LocalizedString.ExtraLargeTextLabel
        
        //configure the subtitle label
        self.subtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .headline)
        self.subtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.subtitleLabel?.text = PurchaseSplitBillViewController.LocalizedString.LargeTextLabel
        
        //configure the navigation bar
        self.navigationBar?.items?.first?.title = PurchaseSplitBillViewController.LocalizedString.NavBarTitleLabel
        
        //configure the paragraph of text
        self.descriptionParagraphLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.descriptionParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        
        //configure the button text
        self.purchaseButton?.titleStyle = .headline
        self.restoreButton?.titleStyle = .subheadline
        
        // configure the button text
        self.configureDynamicElements()
        self.restoreButton?.setTitle(PurchaseSplitBillViewController.LocalizedString.RestorePurchasesButton, for: UIControlState())
    }
    
    fileprivate func configureDynamicElements() {
        if let splitBillProduct = self.splitBillProduct {
            let purchaseString = PurchaseSplitBillViewController.LocalizedString.PurchaseButtonText
            self.purchaseButton?.setTitle(purchaseString + " – \(self.priceString)", for: UIControlState())
            self.descriptionParagraphLabel?.text = splitBillProduct.localizedDescription
            
        } else {
            // need to request the product!!!
            let downloadingLocalizedString = PurchaseSplitBillViewController.LocalizedString.DownloadingAppStoreInfoButtonText
            self.purchaseButton?.setTitle(downloadingLocalizedString, for: UIControlState())
            self.descriptionParagraphLabel?.text = ""
        }
    }
    
    @discardableResult
    fileprivate func updateViewPlayerBounds() -> Bool {
        if let videoPlayerViewBounds = self.videoPlayerView?.bounds, let videoLayer = self.videoPlayer?.layer {
            videoLayer.frame = videoPlayerViewBounds
            return true
        } else {
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViewPlayerBounds()
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seek(to: kCMTimeZero)
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlaybackFinished(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.player.currentItem)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateViewPlayerBounds()
        let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.videoPlayer?.player.play()
        }
    }
    
    @objc fileprivate func videoPlaybackFinished(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.videoPlayer?.player.pause()
            self.videoPlayer?.player.seek(to: kCMTimeZero)
            let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.videoPlayer?.player.play()
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { context in self.updateViewPlayerBounds() }, completion: .none)
    }
    
    // MARK: Purchasing
    
    fileprivate let priceNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        return formatter
    }()
    
    fileprivate var priceString: String {
        let priceString: String?
        if let splitBillProduct = self.splitBillProduct {
            self.priceNumberFormatter.locale = splitBillProduct.priceLocale
            priceString = self.priceNumberFormatter.string(from: splitBillProduct.price)
        } else {
            priceString = .none
        }
        return priceString ?? ""
    }
    
    fileprivate var splitBillProduct: SKProduct? {
        didSet {
            self.configureDynamicElements()
        }
    }
    
    fileprivate func requestSplitBillProductWithCompletionHandler() {
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
                let userFacingError = NSError(purchaseError: .productRequestFailed)
                let actions = [
                    UIAlertAction(kind: .dismiss, completionHandler: self?.didTapDismissButtonThatClosesCurrentViewController),
                    UIAlertAction(kind: .emailSupport, completionHandler: self?.didTapEmailSupportActionButton)
                ]
                self?.shouldDismissVCAfterEmailVCDismisses = true
                let errorVC = UIAlertController(actions: actions, error: userFacingError)
                self?.present(errorVC, animated: true, completion: .none)
            }
            self?.state = .normal
        }
    }
    
    // MARK: Handle User Input
    
    @IBAction fileprivate func didTapPurchaseButton(_ sender: UIButton?) {
        guard let splitBillProduct = self.splitBillProduct else { return }
        self.state = .purchaseInProgress
        self.purchaseManager.initiatePurchaseWithPayment(SKPayment(product: splitBillProduct)) { transaction in
            // change the UI back to normal state
            self.state = .normal
            // update the preferences
            let purchased = self.purchaseManager.verifySplitBillPurchaseTransaction()
            if transaction.transactionState == .deferred {
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
            case .purchased, .restored, .failed:
                self.purchaseManager.finishTransaction(transaction)
            case .deferred, .purchasing:
                break //do nothing
            }
            
            // lets present stuff to the user
            if let userFacingErrorTuple = self.errorForPurchaseTransaction(transaction) {
                // an error ocurred, lets show it to the user.
                let alertVC = UIAlertController(actions: userFacingErrorTuple.userAlertActions, error: userFacingErrorTuple.userFacingError)
                if let _ = self.presentingViewController {
                    // if this view controller has been dismissed, I don't want to try and present this error, it will fail anwyway
                    self.present(alertVC, animated: true, completion: .none)
                }
            } else {
                switch transaction.transactionState {
                case .purchased, .restored:
                    let presentingViewController = self.presentingViewController
                    self.dismiss(animated: true, completion: {
                        presentingViewController?.performSegue(withIdentifier: TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
                    })
                case .deferred, .failed, .purchasing:
                    break //do nothing
                }
            }
        }
    }
    
    fileprivate func dateIsToday(_ queryDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(queryDate)
    }
    
    @IBAction fileprivate func didTapRestoreButton(_ sender: UIButton?) {
        self.state = .restoreInProgress
        self.purchaseManager.restorePurchasesWithCompletionHandler() { queue, error in
            
            // change the UI back to normal state
            self.state = .normal
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
                        self.present(alertVC, animated: true, completion: .none)
                    }
                }
            } else {
                // restoration completed successfully
                if splitBillPurchased == true {
                    // the purchase was restored by the restore attempt
                    let presentingViewController = self.presentingViewController
                    self.dismiss(animated: true) {
                        presentingViewController?.performSegue(withIdentifier: TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
                    }
                } else {
                    // the restoration was successful, but the customer never purchased the product
                    let actions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .buy, completionHandler: self.didTapAlertBuyButton),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                    let error = NSError(purchaseError: .restoreSucceededSplitBillNotPurchased)
                    let alertVC = UIAlertController(actions: actions, error: error)
                    if let _ = self.presentingViewController {
                        // if this view controller has been dismissed, I don't want to try and present this error, it will fail anwyway
                        self.present(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: Callbacks for UIAlertViewController
    
    fileprivate func didTapDismisseAlertButtonForDeferredPurchase(_ action: UIAlertAction) {
        let presentingViewController = self.presentingViewController
        self.dismiss(animated: true, completion: {
            presentingViewController?.performSegue(withIdentifier: TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
        })
    }
    
    fileprivate func didTapDismissButtonThatClosesCurrentViewController(_ action: UIAlertAction) {
        self.dismiss(animated: true, completion: .none)
    }
    
    fileprivate func didTapAlertBuyButton(_ action: UIAlertAction) {
        self.didTapPurchaseButton(.none)
    }
    
    fileprivate var shouldDismissVCAfterEmailVCDismisses = false
    
    fileprivate func didTapEmailSupportActionButton(_ action: UIAlertAction) {
        let emailManager = EmailSupportHandler(kind: .genericEmailSupport, delegate: self)
        if let mailVC = emailManager.presentableMailViewController {
            self.present(mailVC, animated: true, completion: .none)
        } else {
            emailManager.switchAppForEmailSupport()
        }
    }
    
    // MARK: Handle Going Away
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        self.purchaseManager.endObserving()
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension PurchaseSplitBillViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.state = .normal
        controller.dismiss(animated: true) {
            if self.shouldDismissVCAfterEmailVCDismisses == true {
                self.dismiss(animated: true, completion: .none)
            }
        }
        if let error = error {
            log?.error("Error while sending email. Error Description: \(error)")
        }
    }
}

// MARK: Crazy Error Code Logic for Purchases and Restores

extension PurchaseSplitBillViewController {
    fileprivate typealias UserFacingError = (userFacingError: NSError, userAlertActions: [UIAlertAction])
    fileprivate func errorForPurchaseTransaction(_ transaction: SKPaymentTransaction) -> UserFacingError? {
        let userFacingError: NSError?
        let userAlertActions: [UIAlertAction]
        
        if let error = transaction.error as NSError? {
            if let reason = StoreKitPurchaseErrorCode(rawValue: error.code) {
                switch reason {
                case .unknown:
                    userFacingError = NSError(purchaseError: .purchaseFailedUnknown)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .clientInvalid:
                    userFacingError = NSError(purchaseError: .purchaseFailedClientInvalid)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .paymentCancelled:
                    userFacingError = .none
                    userAlertActions = []
                case .paymentInvalid:
                    userFacingError = NSError(purchaseError: .purchaseFailedPaymentInvalid)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .paymentNotAllowed:
                    userFacingError = .none
                    userAlertActions = []
                case .productNotAvailable:
                    userFacingError = NSError(purchaseError: .purchaseFailedProductNotAvailable)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                }
            } else {
                // there was an error but it didn't match one of the known codes
                if error.isaGratuitousPurchaseError() == true {
                    // if we already custom crafted this error, we can show it to the user
                    userFacingError = error as NSError
                } else {
                    // otherwise we'll give a generic failure
                    userFacingError = NSError(purchaseError: .restoreFailedUnknown)
                }
                userAlertActions = [
                    UIAlertAction(kind: .dismiss, completionHandler: .none),
                    UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                ]
            }
        } else {
            // there was no error, so lets check the transaction state
            switch transaction.transactionState {
            case .purchased, .restored:
                // true true success
                userFacingError = .none
                userAlertActions = []
            case .deferred:
                // Deferred for parents to approve, granting temporary access
                userFacingError = NSError(purchaseError: .purchaseDeferred)
                userAlertActions = [UIAlertAction(kind: .dismiss, completionHandler: self.didTapDismisseAlertButtonForDeferredPurchase)]
            case .failed:
                // not sure how we made it this far, but thats OK, unknown error
                userFacingError = NSError(purchaseError: .purchaseFailedUnknown)
                userAlertActions = [
                    UIAlertAction(kind: .dismiss, completionHandler: .none),
                    UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                ]
            case .purchasing:
                // should not ever see this but will do nothing because most likely stuff is still in progress
                userFacingError = .none
                userAlertActions = []
            }
        }
        
        if let userFacingError = userFacingError {
            return (userFacingError: userFacingError, userAlertActions: userAlertActions)
        } else {
            return .none
        }
    }
    
    fileprivate func errorFromRestoreError(_ error: NSError?) -> UserFacingError? {
        let userFacingError: NSError?
        let userAlertActions: [UIAlertAction]
        
        if let error = error {
            if let reason = StoreKitPurchaseErrorCode(rawValue: error.code) {
                switch reason {
                case .unknown:
                    userFacingError = NSError(purchaseError: .restoreFailedUnknown)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .clientInvalid:
                    userFacingError = NSError(purchaseError: .restoreFailedClientInvalid)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .paymentCancelled:
                    userFacingError = .none
                    userAlertActions = []
                case .paymentInvalid:
                    userFacingError = NSError(purchaseError: .restoreFailedPaymentInvalid)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                case .paymentNotAllowed:
                    userFacingError = .none
                    userAlertActions = []
                case .productNotAvailable:
                    userFacingError = NSError(purchaseError: .restoreFailedProductNotAvailable)
                    userAlertActions = [
                        UIAlertAction(kind: .dismiss, completionHandler: .none),
                        UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                    ]
                }
            } else {
                // there was an error but it didn't match one of the known codes
                if error.isaGratuitousPurchaseError() == true {
                    // if we already custom crafted this error, we can show it to the user
                    userFacingError = error
                } else {
                    // otherwise we'll give a generic failure
                    userFacingError = NSError(purchaseError: .restoreFailedUnknown)
                }
                userAlertActions = [
                    UIAlertAction(kind: .dismiss, completionHandler: .none),
                    UIAlertAction(kind: .emailSupport, completionHandler: self.didTapEmailSupportActionButton)
                ]
            }
        } else {
            // there was no error, there's probably not an issue.
            userFacingError = .none
            userAlertActions = []
        }
        
        if let userFacingError = userFacingError {
            return (userFacingError: userFacingError, userAlertActions: userAlertActions)
        } else {
            return .none
        }
    }
}
