//
//  WatchInfoViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 4/4/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import UIKit
import AVFoundation

class WatchInfoViewController: SmallModalViewController {
    
    @IBOutlet private weak var videoPlayerView: UIView?
    @IBOutlet private weak var gratuityTitleLabel: UILabel?
    @IBOutlet private weak var gratuityParagraphLabel: UILabel?
    @IBOutlet private weak var gratuitySubtitleLabel: UILabel?
    @IBOutlet private weak var dismissButton: UIButton?
    
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
    }
    
    @objc private func videoPlaybackFinished(notification: NSNotification) {
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seekToTime(kCMTimeZero)
        }
    }
}
