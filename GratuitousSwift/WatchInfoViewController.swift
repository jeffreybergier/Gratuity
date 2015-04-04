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
    
    private weak var defaultsManager: GratuitousUserDefaults? = {
        let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate
        return appDelegate?.defaultsManager
        }()
    
    private let videoPlayer: (player: AVPlayer, layer: AVPlayerLayer)? = {
        if let moviePath = NSBundle.mainBundle().pathForResource("CurrencySymbolUpdating", ofType: "mov") {
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
            var desiredFrame = CGRect(x: 0, y: 0, width: 136, height: 170)
            if let desiredSize = desiredSize {
                desiredFrame = CGRect(origin: CGPointZero, size: desiredSize)
            }
            
            layer.frame = desiredFrame
            layer.backgroundColor = UIColor.blackColor().CGColor
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            self.videoPlayerView?.layer.addSublayer(layer)
            self.videoPlayerView?.clipsToBounds = true
            player.play()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.videoPlayer == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        self.defaultsManager?.watchInfoViewControllerWasDismissed = true
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
}
