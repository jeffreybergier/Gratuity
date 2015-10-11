//
//  GratuitousUIColor.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/4/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import UIKit

struct GratuitousUIColor {
    
    private static func invertColorsIsEnabled() -> Bool {
        var invertColors = false
        
        #if os(iOS)
            if UIAccessibilityIsInvertColorsEnabled() {
                invertColors = true
            }
        #endif
        
        return invertColors
    }
    
    static func lightBackgroundColor() -> UIColor {
        return self.ultraLightTextColor()
    }
    
    static func darkBackgroundColor() -> UIColor {
        var color = UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        if invertColorsIsEnabled() {
            color = UIColor.whiteColor()
        }
        
        return color
    }
    
    static func ultraLightTextColor() -> UIColor {
        var color = UIColor(red: 200/255.0, green: 0, blue: 0, alpha: 1)
        
        if invertColorsIsEnabled() {
            color = UIColor.whiteColor()
        }
        
        return color
    }
    
    static func mediumBackgroundColor() -> UIColor {
        var color = UIColor(red: 100/255.0, green: 0, blue: 0, alpha: 1)
        
        if invertColorsIsEnabled() {
            color = UIColor.darkGrayColor()
        }
        
        return color
    }
    
    static func lightTextColor() -> UIColor {
        return self.ultraLightTextColor()
    }
    
    static func darkTextColor() -> UIColor {
        return self.darkBackgroundColor()
    }
    
    static func textShadowColor() -> UIColor {
        return UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    }
    
    struct WatchFonts {
        
        #if os(watchOS)
        
        static let titleText = [
            NSFontAttributeName : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 20, fallbackStyle: UIFontStyle.Subheadline),
            NSForegroundColorAttributeName : GratuitousUIColor.lightTextColor()
        ]
        static let splitBillValueText = [
            NSFontAttributeName : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 27, fallbackStyle: UIFontStyle.Subheadline),
            NSForegroundColorAttributeName : GratuitousUIColor.lightTextColor()
        ]
        static let valueText = [
            NSFontAttributeName : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 24, fallbackStyle: UIFontStyle.Subheadline),
            NSForegroundColorAttributeName : GratuitousUIColor.ultraLightTextColor()
        ]
        static let hugeValueText = [
            NSFontAttributeName : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 40, fallbackStyle: UIFontStyle.Headline),
            NSForegroundColorAttributeName : GratuitousUIColor.ultraLightTextColor()
        ]
        
        #endif
        
        #if os(iOS)
        
        static let tutorialTitleText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 21.5, fallbackStyle: UIFontStyle.Subheadline),
            NSForegroundColorAttributeName : GratuitousUIColor.lightTextColor()
        ]
        static let titleText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.Subheadline),
            NSForegroundColorAttributeName : GratuitousUIColor.lightTextColor()
        ]
        static let subtitleText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 20, fallbackStyle: UIFontStyle.Subheadline),
            NSForegroundColorAttributeName : GratuitousUIColor.lightTextColor()
        ]
        static let buttonText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 20, fallbackStyle: UIFontStyle.Headline),
            NSForegroundColorAttributeName : GratuitousUIColor.ultraLightTextColor()
        ]
        static let valueText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 27, fallbackStyle: UIFontStyle.Body),
            NSForegroundColorAttributeName : GratuitousUIColor.ultraLightTextColor()
        ]
        static let smallValueText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.Body),
            NSForegroundColorAttributeName : GratuitousUIColor.lightTextColor()
        ]
        static let pickerItemText = [
            NSFontAttributeName : UIFont.futura(style: Futura.Medium, size: 24, fallbackStyle: UIFontStyle.Body),
            NSForegroundColorAttributeName : GratuitousUIColor.ultraLightTextColor()
        ]
        
        #endif
    }
}
