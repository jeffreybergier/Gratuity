//
//  PurchaseSplitBillViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/24/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit
import AVFoundation

class PurchaseSplitBillViewController: SmallModalScollViewController {
    
    @IBOutlet private weak var videoPlayerView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionParagraphLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var purchaseButton: UIButton?
    @IBOutlet private weak var restoreButton: UIButton?
    
    private var dataSource: GratuitousiOSDataSource = (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).dataSource
    
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
            
            player.play()
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
        
    }
    
    @IBAction private func didTapRestoreButton(sender: UIButton?) {
        self.dataSource.purchaseManager?.restorePurchasesWithCompletionHandler() { queue, success, error in
            print("PurchaseSplitBillViewController: Attempted to Restore Purchases With Success: \(success)")
            if let error = error { print("PurchaseSplitBillViewController: Attempted to Restore Purchases Failed with Error: \(error)") }
        }
    }
}
