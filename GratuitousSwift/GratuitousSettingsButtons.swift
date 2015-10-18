//
//  GratuitousSettingsButtons.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/6/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousSettingsButtons: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        
        self.addTarget(self, action: "touchDown:", forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: "touchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: "touchUp:", forControlEvents: UIControlEvents.TouchUpOutside)
        
        self.prepareButtonAppearance()
    }
    
    private func prepareButtonAppearance() {
        self.tintColor = GratuitousUIConstant.lightTextColor()
        self.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.adjustsImageWhenHighlighted = false
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        
        self.setTitleColor(GratuitousUIConstant.lightTextColor(), forState: UIControlState.Normal)
        self.setTitleColor(GratuitousUIConstant.darkTextColor(), forState: UIControlState.Highlighted)
        
        self.layer.borderColor = GratuitousUIConstant.lightTextColor().CGColor
        self.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.layer.cornerRadius = 6.0
    }
    
    func touchDown(sender: GratuitousSettingsButtons) {
        self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
    }
    
    func touchUp(sender: GratuitousSettingsButtons) {
        UIView.animateWithDuration(0.0001,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
            },
            completion: { finished in
                UIView.animateWithDuration(GratuitousUIConstant.animationDuration()*2,
                    delay: 0.0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: {
                        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
                    },
                    completion: { finished in })
        })
        
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.prepareButtonAppearance()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
