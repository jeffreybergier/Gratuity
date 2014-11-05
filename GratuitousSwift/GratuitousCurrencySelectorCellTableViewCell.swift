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
    private let CURRENCYSIGNDEFAULT = 0
    private let CURRENCYSIGNDOLLAR = 1
    private let CURRENCYSIGNPOUND = 2
    private let CURRENCYSIGNEURO = 3
    private let CURRENCYSIGNYEN = 4
    private let CURRENCYSIGNNONE = 5
    
    @IBOutlet private weak var textLabelDefault: UILabel?
    @IBOutlet private weak var textLabelDollarSign: UILabel?
    @IBOutlet private weak var textLabelPoundSign: UILabel?
    @IBOutlet private weak var textLabelEuroSign: UILabel?
    @IBOutlet private weak var textLabelYenSign: UILabel?
    @IBOutlet private weak var textLabelNone: UILabel?
    
    private weak var instanceTextLabel: UILabel?
    
    private var userDefaults = NSUserDefaults.standardUserDefaults()
    private var cellIdentity:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "overrideCurrencySymbolUpdatedOnDisk:", name: "overrideCurrencySymbolUpdatedOnDisk", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "settingsTableViewControllerDidAppear:", name: "settingsTableViewControllerDidAppear", object: nil)
        
        if let textLabelDefault = self.textLabelDefault {
            self.setTextColorAndFontSize(textLabelDefault)
            self.cellIdentity = self.CURRENCYSIGNDEFAULT
        }
        
        if let textLabelDollarSign = self.textLabelDollarSign {
            self.setTextColorAndFontSize(textLabelDollarSign)
            self.cellIdentity = self.CURRENCYSIGNDOLLAR
        }
        
        if let textLabelPoundSign = self.textLabelPoundSign {
            self.setTextColorAndFontSize(textLabelPoundSign)
            self.cellIdentity = self.CURRENCYSIGNPOUND
        }
        
        if let textLabelEuroSign = self.textLabelEuroSign {
            self.setTextColorAndFontSize(textLabelEuroSign)
            self.cellIdentity = self.CURRENCYSIGNEURO
        }
        
        if let textLabelYenSign = self.textLabelYenSign {
            self.setTextColorAndFontSize(textLabelYenSign)
            self.cellIdentity = self.CURRENCYSIGNYEN
        }
        
        if let textLabelNone = self.textLabelNone {
            self.setTextColorAndFontSize(textLabelNone)
            self.cellIdentity = self.CURRENCYSIGNNONE
        }
        
        self.readUserDefaultsAndSetCheckmarkWithTimer(false)
    }
    
    func settingsTableViewControllerDidAppear(notification: NSNotification?) {
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
    }
    
    func overrideCurrencySymbolUpdatedOnDisk(notification: NSNotification?) {
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
    }
    
    private func setTextColorAndFontSize(sender: UILabel) {
        self.instanceTextLabel = sender
        sender.textColor = GratuitousColorSelector.lightTextColor()
        sender.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    private func readUserDefaultsAndSetCheckmarkWithTimer(timer: Bool) {
        let onDiskCurrencySign: NSNumber = self.userDefaults.integerForKey("overrideCurrencySymbol")
        
        if self.cellIdentity == onDiskCurrencySign.integerValue {
            self.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.layer.borderWidth = 2.0
            self.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
            if timer {
                let slowFadeOutTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "slowFadeOutOfBorderAroundCell:", userInfo: nil, repeats: false)
            }
        } else {
            self.accessoryType = UITableViewCellAccessoryType.None
            self.layer.borderWidth = 0.0
            self.layer.borderColor = GratuitousColorSelector.darkBackgroundColor().CGColor
        }
        
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
    
    private func saveUserDefaultToDisk() {
        self.userDefaults.setInteger(self.cellIdentity, forKey: "overrideCurrencySymbol")
        self.userDefaults.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName("overrideCurrencySymbolUpdatedOnDisk", object: self)
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
        super.setSelected(selected, animated: animated)
        
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
                completion: { finished in
                    self.saveUserDefaultToDisk()
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
