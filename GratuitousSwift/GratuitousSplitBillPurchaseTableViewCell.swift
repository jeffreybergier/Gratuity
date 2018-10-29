//
//  GratuitousSplitBillPurchaseTableViewCell.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousSplitBillPurchaseTableViewCell: GratuitousSelectFadeTableViewCell {
    
    fileprivate var applicationPreferences: GratuitousUserDefaults {
        return (UIApplication.shared.delegate as! GratuitousAppDelegate).preferences
    }
    
    @IBOutlet fileprivate var lockIconTrailingConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate var lockIconWidthConstraint: NSLayoutConstraint?
    @IBOutlet fileprivate var purchaseTextLabel: UILabel?
    
    enum UIState {
        case lockShowing
        case checkMarkShowing
    }
    
    fileprivate var viewSourceOfTruth = UIState.lockShowing {
        didSet {
            switch self.viewSourceOfTruth {
            case .lockShowing:
                self.lockIconTrailingConstraint?.constant = 10
                self.lockIconWidthConstraint?.isActive = false
                self.accessoryType = .none
            case .checkMarkShowing:
                self.lockIconTrailingConstraint?.constant = 0
                self.lockIconWidthConstraint?.isActive = true
                self.accessoryType = .checkmark
            }
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.animatableTextLabel = self.purchaseTextLabel
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.purchaseStateMayHaveChanged(_:)), name: NSNotification.Name(rawValue: GratuitousDefaultsObserver.NotificationKeys.BillTipValueChangedByRemote), object: .none)
        
        self.verifySplitBillPurchaseAndUpdateUI()
    }
    
    fileprivate func verifySplitBillPurchaseAndUpdateUI() {
        if self.applicationPreferences.splitBillPurchased == true {
            self.viewSourceOfTruth = .checkMarkShowing
        } else {
            self.viewSourceOfTruth = .lockShowing
        }
    }
    
    @objc fileprivate func purchaseStateMayHaveChanged(_ notification: Notification?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.verifySplitBillPurchaseAndUpdateUI()
            }) 
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
