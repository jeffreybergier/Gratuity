//
//  WatchInfoViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 4/4/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import UIKit
import AVFoundation

class WatchInfoViewController: UIViewController {
    
    @IBOutlet private weak var videoPlayerView: UIView?
    @IBOutlet private weak var videoPlayerParentView: UIView?
    @IBOutlet private weak var gratuityTitleLabel: UILabel?
    @IBOutlet private weak var gratuityParagraphLabel: UILabel?
    @IBOutlet private weak var gratuitySubtitleLabel: UILabel?
    @IBOutlet private weak var dismissButton: UIButton?
    
    private weak var defaultsManager: GratuitousUserDefaults? = {
        let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate
        return appDelegate?.defaultsManager
        }()
    
    private let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = NSBundle.mainBundle().pathForResource("gratuityInfoDemoVideo@2x", ofType: "mov"),
            let movieURL = NSURL.fileURLWithPath(moviePath),
            let player = AVPlayer(URL: movieURL) {
                player.allowsExternalPlayback = false
                player.actionAtItemEnd = AVPlayerActionAtItemEnd.None // cause the player to loop
                if let playerLayer = AVPlayerLayer(player: player) {
                    return (player, playerLayer)
                }
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        self.configureDynamicTextLabels()
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
    
    private func configureDynamicTextLabels() {
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = headlineFont.pointSize * 2
        
        //configure the large title label
        self.gratuityTitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .Headline)
        self.gratuityTitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuityTitleLabel?.text = NSLocalizedString("Gratuity", comment: "Large Title of Watch Info View Controller")
        
        //configure the subtitle label
        self.gratuitySubtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .Headline)
        self.gratuitySubtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuitySubtitleLabel?.text = NSLocalizedString("Apple Watch", comment: "Large SubTitle of Watch Info View Controller")
        
        //configure the paragraph of text
        self.gratuityParagraphLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.gratuityParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuityParagraphLabel?.text = NSLocalizedString("Did you just open a shiny new Apple Watch? Don't forget to install Gratuity. You can do so in the Apple Watch App on the home screen.", comment: "Paragraph that explains how to install the watch app")
        
        // prepare the button
        self.dismissButton?.setTitle(NSLocalizedString("Dismiss", comment: "Dismiss button for the Apple Watch Info Screen."), forState: UIControlState.Normal)
        
        // check screen height and draw border if appropriate
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification) {
        self.configureDynamicTextLabels()
    }
    
    @objc private func videoPlaybackFinished(notification: NSNotification) {
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seekToTime(kCMTimeZero)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    private func switchOnScreenSizeToDetermineBorderSurround() {
        let actualHeight = UIScreen.mainScreen().bounds.size.height
        switch actualHeight {
        case 0 ..< 480:
            self.showBorder()
        case 480 ... 568:
            self.hideBorder()
        case 569 ..< CGFloat.max:
            self.showBorder()
        default:
            break
        }
    }
    
    private func hideBorder() {
        self.videoPlayerParentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().CGColor
        self.videoPlayerParentView?.layer.borderWidth = 0
        self.videoPlayerParentView?.layer.cornerRadius = 0
        self.videoPlayerParentView?.clipsToBounds = true
    }
    
    private func showBorder() {
        self.videoPlayerParentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().CGColor
        self.videoPlayerParentView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.videoPlayerParentView?.layer.cornerRadius = 6
        self.videoPlayerParentView?.clipsToBounds = true
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        self.defaultsManager?.watchInfoViewControllerWasDismissed = true
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
