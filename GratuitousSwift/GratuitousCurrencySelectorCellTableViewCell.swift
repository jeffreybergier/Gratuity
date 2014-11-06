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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideCurrencySymbolUpdatedOnDisk:", name: "overrideCurrencySymbolUpdatedOnDisk", object: nil)
    }
    
    func overrideCurrencySymbolUpdatedOnDisk(notification: NSNotification?) {
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
    }
    
    private func prepareTextLabel() {
        self.instanceTextLabel?.textColor = GratuitousColorSelector.lightTextColor()
        self.instanceTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    private func readUserDefaultsAndSetCheckmarkWithTimer(timer: Bool) {
        if self.userDefaults.integerForKey("overrideCurrencySymbol") == self.tag {
            self.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.layer.borderWidth = 2.0
            self.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
            self.accessoryType = UITableViewCellAccessoryType.Checkmark
            if timer {
                let slowFadeOutTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "slowFadeOutOfBorderAroundCell:", userInfo: nil, repeats: false)
            }
        } else {
            self.accessoryType = UITableViewCellAccessoryType.None
            self.layer.borderWidth = 0.0
            self.layer.borderColor = GratuitousColorSelector.darkBackgroundColor().CGColor
            self.accessoryType = UITableViewCellAccessoryType.None
        }
        
        UIView.animateWithDuration(GratuitousAnimations.duration(),
            delay: GratuitousAnimations.duration()+1,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.instanceTextLabel?.textColor = GratuitousColorSelector.lightTextColor()
            },
            completion: { finished in })
        
    }
    
    func slowFadeOutOfBorderAroundCell(timer: NSTimer?) {
        timer?.invalidate()
        
        //wow animations in Core Animation are so much harder than UIViewAnimations
        let colorAnimation = CABasicAnimation(keyPath: "borderColor")
        colorAnimation.fromValue = GratuitousColorSelector.lightBackgroundColor().CGColor
        colorAnimation.toValue = GratuitousColorSelector.darkBackgroundColor().CGColor
        self.layer.borderColor = GratuitousColorSelector.darkBackgroundColor().CGColor
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.0
        animationGroup.animations = [colorAnimation]
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.layer.addAnimation(animationGroup, forKey: "borderColor")
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
                    self.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
                    self.instanceTextLabel?.textColor = GratuitousColorSelector.darkTextColor()
                },
                completion: { finished in })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
