//
//  PreferredCurrencySelectorCellTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/2/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import QuartzCore

class GratuitousCurrencySelectorCellTableViewCell: UITableViewCell {
    
    weak var instanceTextLabel: UILabel? {
        didSet {
            self.prepareTextLabel()
        }
    }
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var animatingBorderColor = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 2.0
        self.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideCurrencySymbolUpdatedOnDisk:", name: "overrideCurrencySymbolUpdatedOnDisk", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func overrideCurrencySymbolUpdatedOnDisk(notification: NSNotification?) {
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
    }
    
    func systemTextSizeDidChange(notification:NSNotification) {
        self.prepareTextLabel()
    }
    
    private func prepareTextLabel() {
        self.instanceTextLabel?.textColor = GratuitousColorSelector.lightTextColor()
        self.instanceTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    private func readUserDefaultsAndSetCheckmarkWithTimer(timer: Bool) {
        if self.userDefaults.integerForKey("overrideCurrencySymbol") == self.tag {
            self.accessoryType = UITableViewCellAccessoryType.Checkmark
            if !self.animatingBorderColor {
                //if this property is being animated, don't change it
                self.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
            }
            self.accessoryType = UITableViewCellAccessoryType.Checkmark
            if timer {
                let slowFadeOutTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "slowFadeOutOfBorderAroundCell:", userInfo: nil, repeats: false)
            }
        } else {
            self.accessoryType = UITableViewCellAccessoryType.None
            if !self.animatingBorderColor {
                self.layer.borderColor = GratuitousColorSelector.darkBackgroundColor().CGColor
            }
            self.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func slowFadeOutOfBorderAroundCell(timer: NSTimer?) {
        timer?.invalidate()
        
        if !self.animatingBorderColor {
            //wow animations in Core Animation are so much harder than UIViewAnimations
            let colorAnimation = CABasicAnimation(keyPath: "borderColor")
            colorAnimation.fromValue = GratuitousColorSelector.lightBackgroundColor().CGColor
            colorAnimation.toValue = GratuitousColorSelector.darkBackgroundColor().CGColor
            self.layer.borderColor = GratuitousColorSelector.darkBackgroundColor().CGColor
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 2.0
            animationGroup.animations = [colorAnimation]
            animationGroup.delegate = self
            animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.layer.addAnimation(animationGroup, forKey: "borderColor")
        }
    }
    
    override func animationDidStart(anim: CAAnimation!) {
        self.animatingBorderColor = true
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        //this timer was needed because this seems to get called slightly too soon and if the user touched the same cell again it would repeat the animation and it was jarring.
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "cgAnimationDidFinish:", userInfo: nil, repeats: false)
    }
    
    func cgAnimationDidFinish(timer: NSTimer?) {
        timer?.invalidate()

        self.animatingBorderColor = false
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousAnimations.duration(),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
                self.instanceTextLabel?.textColor = GratuitousColorSelector.darkTextColor()
            },
            completion: { finished in })
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousAnimations.duration(),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.instanceTextLabel?.textColor = GratuitousColorSelector.lightTextColor()
            },
            completion: { finished in
        })
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousAnimations.duration(),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.instanceTextLabel?.textColor = GratuitousColorSelector.lightTextColor()
            },
            completion: { finished in })
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        // Configure the view for the selected state
        if selected {
            UIView.animateWithDuration(GratuitousAnimations.duration(),
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    self.backgroundColor = GratuitousColorSelector.lightBackgroundColor().colorWithAlphaComponent(0.8)
                    self.instanceTextLabel?.textColor = GratuitousColorSelector.darkTextColor()
                },
                completion: { finished in
                    UIView.animateWithDuration(GratuitousAnimations.duration(),
                        delay: 0.0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 1.0,
                        options: UIViewAnimationOptions.BeginFromCurrentState,
                        animations: {
                            self.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                            self.instanceTextLabel?.textColor = GratuitousColorSelector.lightTextColor()
                        },
                        completion: { finished in })
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
