//
//  GratuitousSplitBillPurchaseTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousSplitBillPurchaseTableViewCell: GratuitousSelectFadeTableViewCell {
    
    private var applicationPreferences: GratuitousUserDefaults {
        return (UIApplication.sharedApplication().delegate as! GratuitousAppDelegate).preferences
    }
    
    @IBOutlet private var lockIconTrailingConstraint: NSLayoutConstraint?
    @IBOutlet private var lockIconWidthConstraint: NSLayoutConstraint?
    @IBOutlet private var purchaseTextLabel: UILabel?
    
    enum UIState {
        case LockShowing
        case CheckMarkShowing
    }
    
    private var viewSourceOfTruth = UIState.LockShowing {
        didSet {
            switch self.viewSourceOfTruth {
            case .LockShowing:
                self.lockIconTrailingConstraint?.constant = 10
                self.lockIconWidthConstraint?.active = false
                self.accessoryType = .None
            case .CheckMarkShowing:
                self.lockIconTrailingConstraint?.constant = 0
                self.lockIconWidthConstraint?.active = true
                self.accessoryType = .Checkmark
            }
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.animatableTextLabel = self.purchaseTextLabel
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.purchaseStateMayHaveChanged(_:)), name: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote, object: .None)
        
        self.verifySplitBillPurchaseAndUpdateUI()
    }
    
    private func verifySplitBillPurchaseAndUpdateUI() {
        if self.applicationPreferences.splitBillPurchased == true {
            self.viewSourceOfTruth = .CheckMarkShowing
        } else {
            self.viewSourceOfTruth = .LockShowing
        }
    }
    
    @objc private func purchaseStateMayHaveChanged(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.3) {
                self.verifySplitBillPurchaseAndUpdateUI()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
