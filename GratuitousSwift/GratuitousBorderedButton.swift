//
//  GratuitousSettingsButtons.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/6/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

final class GratuitousBorderedButton: UIButton {
    
    var titleStyle = UIFontStyle.Headline {
        didSet {
            self.prepareTitleLabelFont()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
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
    
    private func prepareTitleLabelFont() {
        self.titleLabel?.font = UIFont.preferredFontForTextStyle(self.titleStyle.description)
    }
    
    private func prepareButtonAppearance() {
        self.backgroundColor = GratuitousUIConstant.darkBackgroundColor()
        self.prepareTitleLabelFont()
        
        self.setTitleColor(GratuitousUIConstant.lightTextColor(), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        
        self.layer.borderColor = GratuitousUIConstant.lightTextColor().CGColor
        self.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.layer.cornerRadius = GratuitousUIConstant.cornerRadius
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
            self.prepareTitleLabelFont()
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "highlighted")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
