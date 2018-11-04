//
//  WatchInfoViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 4/4/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import AVFoundation
import UIKit

final class WatchInfoViewController: SmallModalScollViewController {
    
    @IBOutlet fileprivate weak var gratuityTitleLabel: UILabel?
    @IBOutlet fileprivate weak var gratuityParagraphLabel: UILabel?
    @IBOutlet fileprivate weak var gratuitySubtitleLabel: UILabel?
    @IBOutlet fileprivate weak var videoPlayerSurroundView: UIView?
    @IBOutlet fileprivate weak var videoPlayerView: UIView?
    
    fileprivate let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = Bundle.main.path(forResource: "gratuityInfoDemoVideo@2x", ofType: "mp4") {
            let player = AVPlayer(url: URL(fileURLWithPath: moviePath))
            player.allowsExternalPlayback = false
            player.actionAtItemEnd = AVPlayerActionAtItemEnd.none // cause the player to loop
            let playerLayer = AVPlayerLayer(player: player)
            return (player, playerLayer)
        }
        return nil
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoPlayerSurroundView?.layer.borderWidth = 1
        self.videoPlayerSurroundView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.videoPlayerSurroundView?.layer.borderColor = GratuitousUIColor.lightTextColor().cgColor
        
        if let videoPlayer = self.videoPlayer {
            let player = videoPlayer.player
            let layer = videoPlayer.layer
            
            let desiredSize = self.videoPlayerView?.frame.size
            var desiredFrame = CGRect(x: 0, y: 0, width: 640, height: 1136)
            if let desiredSize = desiredSize {
                desiredFrame = CGRect(origin: CGPoint.zero, size: desiredSize)
            }
            
            layer.frame = desiredFrame
            layer.backgroundColor = UIColor.black.cgColor
            layer.videoGravity = AVLayerVideoGravity.resizeAspect
            
            self.videoPlayerView?.layer.addSublayer(layer)
            self.videoPlayerView?.clipsToBounds = true
            
            player.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.seek(to: kCMTimeZero)
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlaybackFinished(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer.player.currentItem)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func configureDynamicTextLabels() {
        
        let headlineFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        let headlineFontSize = headlineFont.pointSize * 2
        
        //configure the large title label
        self.gratuityTitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .headline)
        self.gratuityTitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuityTitleLabel?.text = WatchInfoViewController.LocalizedString.ExtraLargeTextLabel
        
        //configure the subtitle label
        self.gratuitySubtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .headline)
        self.gratuitySubtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuitySubtitleLabel?.text = WatchInfoViewController.LocalizedString.LargeTextLabel
        
        //configure the navbar
//        self.navigationBar?.items?.first?.title = WatchInfoViewController.LocalizedString.NavBarTitleLabel

        //configure the paragraph of text
        self.gratuityParagraphLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.gratuityParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.gratuityParagraphLabel?.text = WatchInfoViewController.LocalizedString.AboutGratuityForAppleWatch
        
    }
    
    @objc fileprivate func videoPlaybackFinished(_ notification: Notification?) {
        DispatchQueue.main.async {
            if let videoPlayer = self.videoPlayer {
                videoPlayer.player.seek(to: kCMTimeZero)
            }
        }
    }
}
