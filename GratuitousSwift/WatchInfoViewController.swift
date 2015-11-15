//
//  WatchInfoViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 4/4/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import AVFoundation
import Crashlytics

final class WatchInfoViewController: SmallModalScollViewController {
    
    @IBOutlet private weak var gratuityTitleLabel: UILabel?
    @IBOutlet private weak var gratuityParagraphLabel: UILabel?
    @IBOutlet private weak var gratuitySubtitleLabel: UILabel?
    @IBOutlet private weak var videoPlayerSurroundView: UIView?
    @IBOutlet private weak var videoPlayerView: UIView?
    
    private let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = NSBundle.mainBundle().pathForResource("gratuityInfoDemoVideo@2x", ofType: "mp4") {
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
        
        self.videoPlayerSurroundView?.layer.borderWidth = 1
        self.videoPlayerSurroundView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.videoPlayerSurroundView?.layer.borderColor = GratuitousUIColor.lightTextColor().CGColor
        
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
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logContentViewWithName(AnswersString.ViewDidAppear, contentType: .None, contentId: .None, customAttributes: .None)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func configureDynamicTextLabels() {
        super.configureDynamicTextLabels()
        
        let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let headlineFontSize = headlineFont.pointSize * 2
        
        //configure the large title label
        self.gratuityTitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .Headline)
        self.gratuityTitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuityTitleLabel?.text = WatchInfoViewController.LocalizedString.ExtraLargeTextLabel
        
        //configure the subtitle label
        self.gratuitySubtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .Headline)
        self.gratuitySubtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuitySubtitleLabel?.text = WatchInfoViewController.LocalizedString.LargeTextLabel
        
        //configure the navbar
        self.navigationBar?.items?.first?.title = WatchInfoViewController.LocalizedString.NavBarTitleLabel
        
        //configure the paragraph of text
        self.gratuityParagraphLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.gratuityParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuityParagraphLabel?.text = WatchInfoViewController.LocalizedString.AboutGratuityForAppleWatch
        
    }
    
    @objc private func videoPlaybackFinished(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            if let videoPlayer = self.videoPlayer {
                videoPlayer.player.seekToTime(kCMTimeZero)
            }
        }
    }
}
