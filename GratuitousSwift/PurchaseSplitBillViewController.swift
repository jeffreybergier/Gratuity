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

class PurchaseSplitBillViewController: SmallModalScollViewController, MFMailComposeViewControllerDelegate {
    
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
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.state = .Normal
        self.dismissViewControllerAnimated(true, completion: .None)
        if let error = error {
            NSLog("AboutTableViewController: Error while sending email. Error Description: \(error.description)")
        }
    }
    
    @IBAction private func didTapPurchaseButton(sender: UIButton?) {
        self.state = .PurchaseInProgress
        self.dataSource.purchaseManager?.purchaseSplitBillProductWithCompletionHandler() { transaction in
            self.state = .Normal
            print("PurchaseSplitBillViewController< Purchase Product Complete > Transaction: \(transaction), state: \(transaction.transactionState), error: \(transaction.error)")
            // do stuff in the UI
            self.dataSource.purchaseManager?.verifySplitBillPurchaseTransaction(transaction)
        }
    }
    
    @IBAction private func didTapRestoreButton(sender: UIButton?) {
        self.state = .RestoreInProgress
        self.dataSource.purchaseManager?.restorePurchasesWithCompletionHandler() { queue, success, error in
            self.state = .Normal
            if success == false {
                NSLog("PurchaseSplitBillViewController: Restoring Purchases Failed with Error: \(error)")
                let errorVC = UIAlertController(customStyle: .RestorePurchaseError, mailComposeDelegate: self, presentingViewController: self, error: error)
                self.presentViewController(errorVC, animated: true, completion: .None)
            } else {
                queue?.transactions.forEach() { transaction in
                    let verified = self.dataSource.purchaseManager?.verifySplitBillPurchaseTransaction(transaction)
                    print("PurchaseSplitBillViewController: Transaction: \(transaction) restored successfully. Verified Split Bill Purchase: \(verified)")
                }
            }
        }
    }
}

extension UIAlertController {
    enum CustomStyle {
        case RestorePurchaseError
    }
    
    convenience init(customStyle: CustomStyle, mailComposeDelegate: MFMailComposeViewControllerDelegate, presentingViewController: UIViewController, error: NSError?) {
        let errorTitle = NSLocalizedString("Restore Error", comment: "Error title when in-app purchase restore fails")
        let errorDescription = error?.localizedDescription ?? "An error ocurred while restoring purchase. Please try again later."
        
        self.init(title: errorTitle, message: errorDescription, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Button to dismiss alert/error"), style: UIAlertActionStyle.Cancel, handler: .None)
        let emailAction = UIAlertAction(title: NSLocalizedString("Email Support", comment: "Button that shows in the alert view when there was an error restoring purchases, used to email support."), style: UIAlertActionStyle.Default) { action in
            let subject = NSLocalizedString("Trouble Restoring In-App Purchases", comment: "This is the subject line of the email that users can send when they are having trouble restoring in app purchases")
            let body = NSLocalizedString("THISSHOULDBEBLANK", comment: "this is the body line of support requests, it should be blank, but the possibilies are endless")
            
            if MFMailComposeViewController.canSendMail() {
                let mailer = MFMailComposeViewController()
                mailer.mailComposeDelegate = mailComposeDelegate
                mailer.setSubject(subject)
                mailer.setToRecipients(["support@saturdayapps.com"])
                mailer.setMessageBody(body, isHTML: false)
                
                presentingViewController.presentViewController(mailer, animated: true, completion: .None)
            } else {
                let mailStringWrongEncoding = NSString(format: "mailto:support@saturdayapps.com?subject=%@&body=%@", subject, body)
                let mailString = mailStringWrongEncoding.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                if let mailString = mailString {
                    let mailToURL = NSURL(string: mailString)
                    if let mailToURL = mailToURL {
                        UIApplication.sharedApplication().openURL(mailToURL)
                    }
                }
            }
        }
        
        self.addAction(emailAction)
        self.addAction(dismissAction)
    }
}

extension NSError {
    
}
