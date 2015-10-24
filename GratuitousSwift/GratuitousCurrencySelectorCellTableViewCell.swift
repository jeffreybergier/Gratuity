//
//  PreferredCurrencySelectorCellTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/2/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

final class GratuitousCurrencySelectorCellTableViewCell: GratuitousSelectFadeTableViewCell {
    
    override weak var animatableTextLabel: UILabel? {
        didSet {
            self.prepareTextLabel()
        }
    }
    
    func setInterfaceRefreshNeeded() {
        self.readUserDefaultsAndSetCheckmark()
    }
    
    private func prepareTextLabel() {
        self.readUserDefaultsAndSetCheckmark()
        self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.animatableTextLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.layoutIfNeeded()
    }
    
    private func readUserDefaultsAndSetCheckmark() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? GratuitousAppDelegate
            where appDelegate.preferencesSetLocally.overrideCurrencySymbol.rawValue == self.tag {
                self.accessoryType = UITableViewCellAccessoryType.Checkmark
                if self.animatingBorderColor == false {
                    //if this property is being animated, don't change it
                    self.layer.borderColor = GratuitousUIConstant.lightBackgroundColor().CGColor
                }
                self.accessoryType = UITableViewCellAccessoryType.Checkmark
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