//
//  GratuitousSettingsButtons.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/6/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

final class GratuitousSettingsButton: UIButton {
    
    var titleStyle = UIFontStyle.Headline {
        didSet {
            self.prepareButtonAppearance()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        self.addObserver(self, forKeyPath: "highlighted", options: [.New, .Old], context: nil)
        
        self.prepareButtonAppearance()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let oldValue = (change?["old"] as? NSNumber)?.boolValue, let newValue = (change?["new"] as? NSNumber)?.boolValue
            where newValue != oldValue && keyPath == "highlighted" {
                switch newValue {
                case true:
                    self.highlightButton()
                case false:
                    self.unhighlightButton()
                }
        }
    }
    
    private func prepareButtonAppearance() {
        self.tintColor = GratuitousUIConstant.lightTextColor()
        self.titleLabel?.font = UIFont.preferredFontForTextStyle(self.titleStyle.description)
        self.adjustsImageWhenHighlighted = false
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        
        self.setTitleColor(GratuitousUIConstant.lightTextColor(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        
        self.layer.borderColor = GratuitousUIConstant.lightTextColor().CGColor
        self.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.layer.cornerRadius = 6.0
        
        
        print("reversesTitleShadowWhenHighlighted: \(self.reversesTitleShadowWhenHighlighted)")
        print("adjustsImageWhenHighlighted: \(self.adjustsImageWhenHighlighted)")
        print("adjustsImageWhenDisabled: \(self.adjustsImageWhenDisabled)")
        print("showsTouchWhenHighlighted: \(self.showsTouchWhenHighlighted)")
        print("buttonType: \(self.buttonType)")

    }
    
    func highlightButton() {
        self.backgroundColor = GratuitousUIConstant.lightBackgroundColor()
    }
    
    func unhighlightButton() {
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
                    completion: .None)
        })
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.prepareButtonAppearance()
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "highlighted")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
