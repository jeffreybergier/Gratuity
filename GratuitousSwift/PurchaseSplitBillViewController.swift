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
    }
    
    private var state = State.Normal {
        didSet {
            UIView.animateWithDuration(0.3) {
                switch self.state {
                case .Normal:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = true
                    self.restoreButton?.enabled = true
                case .RestoreInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinner?.alpha = 0
                    self.restoreButtonSpinner?.alpha = 1
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
                case .PurchaseInProgress:
                    self.restoreButtonSpinnerWidthConstraint?.constant = 0
                    self.purchaseButtonSpinnerWidthConstraint?.constant = 40
                    self.purchaseButtonSpinner?.alpha = 1
                    self.restoreButtonSpinner?.alpha = 0
                    self.purchaseButton?.enabled = false
                    self.restoreButton?.enabled = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        
    }
    
    @objc private func videoPlaybackFinished(notification: NSNotification) {
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seekToTime(kCMTimeZero)
        }
    }
    
    @IBAction private func didTapPurchaseButton(sender: UIButton?) {
        self.state = .PurchaseInProgress
        self.dataSource.purchaseManager?.purchaseSplitBillProductWithCompletionHandler() { transaction in
            
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
                self.presentViewController(alertVC, animated: true, completion: .None)
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
        self.dataSource.purchaseManager?.restorePurchasesWithCompletionHandler() { queue, success, error in
            
            // change the UI back to normal state
            self.state = .Normal
            // update the preference based on the receipt
            // the receipt is the source of truth, all the error handling is just sugar coating
            if let splitBillPurchased = self.dataSource.purchaseManager?.verifySplitBillPurchaseTransaction() {
                self.dataSource.defaultsManager.splitBillPurchased = splitBillPurchased
            }
        }
    }
    
    private enum StoreAction {
        case Purchase, Restore
    }
    private func errorErrorForPurchaseTransaction(transaction: SKPaymentTransaction) -> (userFacingError: NSError, userAlertActions: [UIAlertAction])? {
        let userFacingError: NSError?
        let userAlertActions: [UIAlertAction]
        
        if let error = transaction.error, let reason = StoreKitPurchaseErrorCode(rawValue: error.code) {
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
            switch transaction.transactionState {
            case .Purchased, .Restored:
                // true true success
                userFacingError = .None
                userAlertActions = []
            case .Deferred:
                // Deferred for parents to approve, granting temporary access
                userFacingError = NSError(purchaseError: .PurchaseDeferred)
                userAlertActions = [UIAlertAction(type: .Dismiss, completionHandler: self.deferredPurchaseAlertDismissed)]
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
    
//    private func errorFromTransaction(transaction: SKPaymentTransaction) -> (userFacingError: NSError, userAlertActions: [UIAlertAction])? {
//        if let transactionError = transaction.error,
//            let reason = StoreKitPurchaseErrorCode(rawValue: transactionError.code)
//            where reason == .PaymentCancelled {
//                // if the transaction is marked as canceled by the user, I don't want to present any error
//                return .None
//        }
//        
//        let userFacingError: NSError?
//        let userAlertActions: [UIAlertAction]
//
//        
//        
//        if let userFacingError = userFacingError {
//            return (userFacingError: userFacingError, userAlertActions: userAlertActions)
//        } else {
//            return .None
//        }
//    }
    
    private func deferredPurchaseAlertDismissed(action: UIAlertAction) {
        let presentingViewController = self.presentingViewController
        self.dismissViewControllerAnimated(true, completion: {
            presentingViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self)
        })
    }
    
    private func didTapEmailSupportActionButton(action: UIAlertAction) {
        let emailManager = EmailSupportHandler(type: .GenericEmailSupport, delegate: self)
        if let mailVC = emailManager.presentableMailViewController {
            self.presentViewController(mailVC, animated: true, completion: .None)
        } else {
            emailManager.switchAppForEmailSupport()
        }
    }
}

extension PurchaseSplitBillViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.state = .Normal
        self.dismissViewControllerAnimated(true, completion: .None)
        if let error = error {
            NSLog("AboutTableViewController: Error while sending email. Error Description: \(error.description)")
        }
    }
}
