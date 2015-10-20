//
//  PreferredCurrencySelectorCellTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/2/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import QuartzCore

final class GratuitousCurrencySelectorCellTableViewCell: GratuitousSelectFadeTableViewCell {
    
    override weak var animatableTextLabel: UILabel? {
        didSet {
            self.prepareTextLabel()
        }
    }
    
    func setInterfaceRefreshNeeded() {
        self.readUserDefaultsAndSetCheckmarkWithTimer(true)
    }
    
    private func prepareTextLabel() {
        self.readUserDefaultsAndSetCheckmarkWithTimer(false)
        self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.animatableTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.layoutIfNeeded()
    }
    
    private func readUserDefaultsAndSetCheckmarkWithTimer(timer: Bool) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate
            where appDelegate.preferencesSetLocally.overrideCurrencySymbol.rawValue == self.tag {
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
                self.layer.borderColor = GratuitousUIConstant.darkBackgroundColor().CGColor
            }
            self.accessoryType = UITableViewCellAccessoryType.None
        }
        self.layoutIfNeeded()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}