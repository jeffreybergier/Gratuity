//
//  PreferredCurrencySelectorCellTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/2/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import QuartzCore

class GratuitousCurrencySelectorCellTableViewCell: UITableViewCell, GratuitousiOSDataSourceDelegate {
    
    weak var instanceTextLabel: UILabel? {
        didSet {
            self.prepareTextLabel()
        }
    }
    var animatingBorderColor = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = GratuitousUIConstant.thinBorderWidth()
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        
    }
    
    func setInterfaceRefreshNeeded() {
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
    }
    
    @objc private func systemTextSizeDidChange(notification:NSNotification) {
        self.prepareTextLabel()
        self.layer.borderWidth = GratuitousUIConstant.thinBorderWidth()
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
        self.layoutIfNeeded()
    }
    
    private func prepareTextLabel() {
        self.instanceTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.instanceTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.layoutIfNeeded()
    }
    
    private func readUserDefaultsAndSetCheckmarkWithTimer(timer: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate
        if let defaultsManager = appDelegate?.dataSource.defaultsManager {
            if defaultsManager.overrideCurrencySymbol.rawValue == self.tag {
                self.accessoryType = UITableViewCellAccessoryType.Checkmark
                if self.animatingBorderColor == false {
                    //if this property is being animated, don't change it
                    self.layer.borderColor = GratuitousUIConstant.lightBackgroundColor().CGColor
                }
                self.accessoryType = UITableViewCellAccessoryType.Checkmark
                if timer {
                    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "slowFadeOutOfBorderAroundCell:", userInfo: nil, repeats: false)
                }
            } else {
                self.accessoryType = UITableViewCellAccessoryType.None
                if self.animatingBorderColor == false {
                    self.layer.borderColor = GratuitousUIConstant.darkBackgroundColor().CGColor //UIColor.blackColor().CGColor
                }
                self.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        self.layoutIfNeeded()
    }
    
    func slowFadeOutOfBorderAroundCell(timer: NSTimer?) {
        timer?.invalidate()
        
        if self.animatingBorderColor == false {
            //wow animations in Core Animation are so much harder than UIViewAnimations
            let colorAnimation = CABasicAnimation(keyPath: "borderColor")
            colorAnimation.fromValue = GratuitousUIConstant.lightBackgroundColor().CGColor
            colorAnimation.toValue = GratuitousUIConstant.darkBackgroundColor().CGColor
            self.layer.borderColor = GratuitousUIConstant.darkBackgroundColor().CGColor //UIColor.blackColor().CGColor
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = GratuitousUIConstant.animationDuration() * 3
            animationGroup.animations = [colorAnimation]
            animationGroup.delegate = self
            animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.layer.addAnimation(animationGroup, forKey: "borderColor")
        }
    }
    
    override func animationDidStart(anim: CAAnimation) {
        self.animatingBorderColor = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        //this timer was needed because this seems to get called slightly too soon and if the user touched the same cell again it would repeat the animation and it was jarring.
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "cgAnimationDidFinish:", userInfo: nil, repeats: false)
    }
    
    func cgAnimationDidFinish(timer: NSTimer?) {
        timer?.invalidate()
        
        self.animatingBorderColor = false
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
                self.instanceTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
            },
            completion: { finished in })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
                self.instanceTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
            },
            completion: { finished in })
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
                self.instanceTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
            },
            completion: { finished in })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
        
            // Configure the view for the selected state
            if selected {
                UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
                    delay: 0.0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: {
                        self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()//.colorWithAlphaComponent(0.8)
                        self.instanceTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
                    },
                    completion: { finished in
                        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
                            delay: 0.0,
                            options: UIViewAnimationOptions.BeginFromCurrentState,
                            animations: {
                                self.backgroundColor = GratuitousUIConstant.darkBackgroundColor() //UIColor.blackColor()
                                self.instanceTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
                            },
                            completion: { finished in
                        })
                })
            }
    
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
