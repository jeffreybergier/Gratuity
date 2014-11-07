//
//  GratuitousSettingsButtons.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/6/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousSettingsButtons: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        
        self.addTarget(self, action: "touchDown:", forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: "touchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: "touchUp:", forControlEvents: UIControlEvents.TouchUpOutside)
        
        self.prepareButtonAppearance()
    }
    
    private func prepareButtonAppearance() {
        self.tintColor = GratuitousColorSelector.lightTextColor()
        self.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        self.adjustsImageWhenHighlighted = false
        
        self.setTitleColor(GratuitousColorSelector.lightTextColor(), forState: UIControlState.Normal)
        self.setTitleColor(GratuitousColorSelector.darkTextColor(), forState: UIControlState.Highlighted)
        
        self.layer.borderColor = GratuitousColorSelector.lightTextColor().CGColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 6.0
    }
    
    func touchDown(sender: GratuitousSettingsButtons) {
        self.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
    }
    
    func touchUp(sender: GratuitousSettingsButtons) {
        UIView.animateWithDuration(0.0001,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
            },
            completion: { finished in
                UIView.animateWithDuration(GratuitousAnimations.duration()*2,
                    delay: 0.0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: {
                        self.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                    },
                    completion: { finished in })
        })
        
    }
    
    func systemTextSizeDidChange(notification: NSNotification) {
        self.prepareButtonAppearance()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
