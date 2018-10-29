//
//  GratuitousUIColor.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/4/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import UIKit

struct GratuitousUIColor {
    
    static func lightBackgroundColor() -> UIColor {
        return self.ultraLightTextColor()
    }
    
    static func darkBackgroundColor() -> UIColor {
        let color = UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return color
    }
    
    static func ultraLightTextColor() -> UIColor {
        let color = UIColor(red: 200/255.0, green: 0, blue: 0, alpha: 1)
        return color
    }
    
    static func mediumBackgroundColor() -> UIColor {
        let color = UIColor(red: 100/255.0, green: 0, blue: 0, alpha: 1)
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
            NSAttributedStringKey.font : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 20, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let bodyText = [
            NSAttributedStringKey.font : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 16, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let splitBillValueText = [
            NSAttributedStringKey.font : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 27, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let valueText = [
            NSAttributedStringKey.font : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 24, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.ultraLightTextColor()
        ]
        static let hugeValueText = [
            NSAttributedStringKey.font : UIFont.fuuutuuura(style: Fuuutuuura.Medium, size: 40, fallbackStyle: UIFontStyle.headline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.ultraLightTextColor()
        ]
        
        #endif
        
        #if os(iOS)
        
        static let tutorialTitleText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 21.5, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let titleText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let subtitleText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 20, fallbackStyle: UIFontStyle.subheadline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let buttonText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 20, fallbackStyle: UIFontStyle.headline),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.ultraLightTextColor()
        ]
        static let valueText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 27, fallbackStyle: UIFontStyle.body),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.ultraLightTextColor()
        ]
        static let smallValueText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 22, fallbackStyle: UIFontStyle.body),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.lightTextColor()
        ]
        static let pickerItemText = [
            NSAttributedStringKey.font : UIFont.futura(style: Futura.Medium, size: 24, fallbackStyle: UIFontStyle.body),
            NSAttributedStringKey.foregroundColor : GratuitousUIColor.ultraLightTextColor()
        ]
        
        #endif
    }
}
