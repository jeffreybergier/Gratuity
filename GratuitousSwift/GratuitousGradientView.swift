//
//  GratuitousGradientView.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import QuartzCore

final class GratuitousGradientView: UIView {
    
    internal let gradient = CAGradientLayer()
    internal let gradientColors = [
        GratuitousUIConstant.darkBackgroundColor().CGColor, GratuitousUIConstant.darkBackgroundColor().CGColor,
        GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.6).CGColor,
        GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.5).CGColor,
        GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.4).CGColor
    ]
    
    var isUpsideDown:Bool = false {
        didSet {
            let colorArray = Array(self.gradientColors.reverse())
            self.gradient.colors = colorArray
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitializer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitializer()
    }
    
    private func commonInitializer() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "invertColorsDidChange:", name: UIAccessibilityInvertColorsStatusDidChangeNotification, object: nil)
        self.backgroundColor = UIColor.clearColor()
        self.gradient.frame = self.bounds
        self.gradient.colors = self.gradientColors
        self.layer.insertSublayer(self.gradient, atIndex: 0)
    }
    
    override func layoutSubviews() {
        self.gradient.frame = self.bounds
        super.layoutSubviews()
    }
    
    @objc private func invertColorsDidChange(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            //I know this is lazy... but it will rarely happen because its only when someone switches to inverted colors.
            //we can waste the extra ram for that one rare session.
            if UIAccessibilityIsInvertColorsEnabled() {
                var unusualGradientColors = [
                    GratuitousUIConstant.darkBackgroundColor().CGColor, GratuitousUIConstant.darkBackgroundColor().CGColor,
                    GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.6).CGColor,
                    GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.5).CGColor,
                    GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.4).CGColor
                ]
                if self.isUpsideDown {
                    unusualGradientColors = Array(unusualGradientColors.reverse())
                }
                self.gradient.colors = unusualGradientColors
            } else {
                var unusualGradientColors = [
                    GratuitousUIConstant.darkBackgroundColor().CGColor, GratuitousUIConstant.darkBackgroundColor().CGColor,
                    GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.6).CGColor,
                    GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.5).CGColor,
                    GratuitousUIConstant.darkBackgroundColor().colorWithAlphaComponent(0.4).CGColor
                ]
                if self.isUpsideDown {
                    unusualGradientColors = Array(unusualGradientColors.reverse())
                }
                self.gradient.colors = unusualGradientColors
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
