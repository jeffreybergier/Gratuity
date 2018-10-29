//
//  PreferredCurrencySelectorCellTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/2/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousCurrencySelectorCellTableViewCell: GratuitousSelectFadeTableViewCell {
    
    override weak var animatableTextLabel: UILabel? {
        didSet {
            self.prepareTextLabel()
        }
    }
    
    func setInterfaceRefreshNeeded() {
        self.readUserDefaultsAndSetCheckmark()
    }
    
    fileprivate func prepareTextLabel() {
        self.readUserDefaultsAndSetCheckmark()
        self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
        self.animatableTextLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        
        // Configure the view for the selected state
        if selected {
            UIView.animate(withDuration: GratuitousUIConstant.animationDuration(),
                delay: 0.0,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: {
                    self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
                    self.animatableTextLabel?.textColor = GratuitousUIConstant.darkTextColor()
                },
                completion: { finished in
                    UIView.animate(withDuration: GratuitousUIConstant.animationDuration(),
                        delay: 0.0,
                        options: UIViewAnimationOptions.beginFromCurrentState,
                        animations: {
                            self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                            self.animatableTextLabel?.textColor = GratuitousUIConstant.lightTextColor()
                        },
                        completion: .none)
            })
        }
    }
    
    fileprivate func readUserDefaultsAndSetCheckmark() {
        if let appDelegate = UIApplication.shared.delegate as? GratuitousAppDelegate, appDelegate.preferencesSetLocally.overrideCurrencySymbol.rawValue == self.tag {
                self.accessoryType = UITableViewCellAccessoryType.checkmark
                if self.animatingBorderColor == false {
                    //if this property is being animated, don't change it
                    self.layer.borderColor = GratuitousUIConstant.lightBackgroundColor().cgColor
                }
                self.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            self.accessoryType = UITableViewCellAccessoryType.none
            if self.animatingBorderColor == false {
                self.layer.borderColor = GratuitousUIConstant.darkBackgroundColor().cgColor
            }
            self.accessoryType = UITableViewCellAccessoryType.none
        }
        self.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
