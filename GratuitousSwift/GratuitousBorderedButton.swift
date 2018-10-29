//
//  GratuitousSettingsButtons.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/6/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousBorderedButton: UIButton {
    
    var titleStyle = UIFontTextStyle.headline {
        didSet {
            self.prepareTitleLabelFont()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        self.addObserver(self, forKeyPath: "highlighted", options: [.new, .old], context: nil)
        
        self.prepareButtonAppearance()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let oldValue = (change?[.oldKey] as? NSNumber)?.boolValue, let newValue = (change?[.newKey] as? NSNumber)?.boolValue, newValue != oldValue && keyPath == "highlighted" {
                switch newValue {
                case true:
                    self.highlightButton()
                case false:
                    self.unhighlightButton()
                }
        }
    }
    
    fileprivate func prepareTitleLabelFont() {
        self.titleLabel?.font = UIFont.preferredFont(forTextStyle: self.titleStyle)
    }
    
    fileprivate func prepareButtonAppearance() {
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.prepareTitleLabelFont()
        
        self.setTitleColor(GratuitousUIConstant.lightTextColor(), for: UIControlState())
        self.setTitleColor(UIColor.black, for: UIControlState.highlighted)
        
        self.layer.borderColor = GratuitousUIConstant.lightTextColor().cgColor
        self.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.layer.cornerRadius = GratuitousUIConstant.cornerRadius
    }
    
    func highlightButton() {
        self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
    }
    
    func unhighlightButton() {
        UIView.animate(withDuration: 0.0001,
            delay: 0.0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
            },
            completion: { finished in
                UIView.animate(withDuration: GratuitousUIConstant.animationDuration()*2,
                    delay: 0.0,
                    options: UIViewAnimationOptions.beginFromCurrentState,
                    animations: {
                        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                    },
                    completion: .none)
        })
    }
    
    @objc fileprivate func systemTextSizeDidChange(_ notification: Notification?) {
        DispatchQueue.main.async {
            self.prepareTitleLabelFont()
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "highlighted")
        NotificationCenter.default.removeObserver(self)
    }
}
