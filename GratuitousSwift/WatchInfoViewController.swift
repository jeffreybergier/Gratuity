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
    
    
    private weak var defaultsManager: GratuitousUserDefaults? = {
        let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate
        return appDelegate?.defaultsManager
        }()
    
    private let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = NSBundle.mainBundle().pathForResource("gratuityInfoDemoVideo@2x", ofType: "mov") {
            if let movieURL = NSURL.fileURLWithPath(moviePath) {
                if let player = AVPlayer(URL: movieURL) {
                    player.allowsExternalPlayback = false
                    player.actionAtItemEnd = AVPlayerActionAtItemEnd.None // cause the player to loop
                    if let playerLayer = AVPlayerLayer(player: player) {
                        return (player, playerLayer)
                    }
                }
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
            
            self.videoPlayerParentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().CGColor
            self.videoPlayerParentView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
            self.videoPlayerParentView?.layer.cornerRadius = 6
            self.videoPlayerParentView?.clipsToBounds = true
            
            let headlineFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            let headlineFontSize = headlineFont.pointSize * 2
            
            //preparing the paragraph text label
            self.gratuityTitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 1.3, fallbackStyle: .Headline)
            self.gratuityTitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
            self.gratuityTitleLabel?.text = NSLocalizedString("Gratuity", comment: "")
            
            //preparing the paragraph text label
            self.gratuitySubtitleLabel?.font = UIFont.futura(style: .Medium, size: headlineFontSize * 0.85, fallbackStyle: .Headline)
            self.gratuitySubtitleLabel?.textColor = GratuitousUIConstant.lightTextColor()
            self.gratuitySubtitleLabel?.text = NSLocalizedString("Apple Watch", comment: "")
            
            //preparing the paragraph text label
            self.gratuityParagraphLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            self.gratuityParagraphLabel?.textColor = GratuitousUIConstant.lightTextColor()
            self.gratuityParagraphLabel?.text = NSLocalizedString("Did you just open a shiny new Apple Watch? Don't forget to install Gratuity. You can do so in the Apple Watch App on the home screen.", comment: "")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let videoPlayer = self.videoPlayer {
            videoPlayer.player.play()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        self.defaultsManager?.watchInfoViewControllerWasDismissed = true
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
}
