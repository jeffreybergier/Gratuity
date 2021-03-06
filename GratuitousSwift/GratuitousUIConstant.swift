//
//  GratuitousColorSelector.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

struct GratuitousUIConstant {
    
    static let cornerRadius = CGFloat(6.0)
    
    // bridging to another class that the watch app can use in order to reduce refactoring
    static func lightBackgroundColor() -> UIColor {
        return GratuitousUIColor.lightTextColor()
    }
    
    static func darkBackgroundColor() -> UIColor {
        return GratuitousUIColor.darkBackgroundColor()
    }
    
    static func lightTextColor() -> UIColor {
        return GratuitousUIColor.lightTextColor()
    }
    
    static func darkTextColor() -> UIColor {
        return GratuitousUIColor.darkTextColor()
    }
    
    static func textShadowColor() -> UIColor {
        return GratuitousUIColor.textShadowColor()
    }
    
    static func thickBorderWidth() -> CGFloat {
        return 2.0
    }
    
    static func thinBorderWidth() -> CGFloat {
        return 1.0
    }
    
    static func animationDuration() -> Double {
        return 0.3
    }
    
    static func originalFontForTableViewCellTextLabels() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: 35.0)
    }
    
    static func originalFontForTotalAmountTextLabel() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: 180.0)
    }
    
    static func originalFontForTipPercentageTextLabel() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: 100.0)
    }
    
    static func deviceScreen() -> (padIdiom: Bool, largeDevice: Bool, smallDeviceLandscape: Bool, largeDeviceLandscape: Bool) {
        var padIdiom = false
        var largeDevice = false
        var smallDeviceLandscape = false
        var largeDeviceLandscape = false
        
        if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
            if UIScreen.main.bounds.size.width > 321.0 {
                largeDevice = true
            }
        } else {
            if UIScreen.main.bounds.size.height > 321.0 {
                largeDevice = true
                largeDeviceLandscape = true
            } else {
                smallDeviceLandscape = true
            }
        }
        
        if UIScreen.main.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            padIdiom = true
        }
        
        return (padIdiom: padIdiom, largeDevice: largeDevice, smallDeviceLandscape: smallDeviceLandscape, largeDeviceLandscape: largeDeviceLandscape)
    }
    
    static func largeTextLandscapeConstant() -> CGFloat {
        var constant: CGFloat = 0
        
        //then adjust for the preferred text size
        if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.large {
            constant = 0
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.extraLarge {
            constant = 0
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.extraExtraLarge {
            constant = 50
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.extraExtraExtraLarge {
            constant = 50
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityMedium {
            constant = 100
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityLarge {
            constant = 100
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityExtraLarge {
            constant = 100
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityExtraExtraLarge {
            constant = 150
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityExtraExtraExtraLarge {
            constant = 150
        }
        
        return constant
    }

    
    static func actualScreenSizeBasedOnWidth() -> ActualScreenSizeBasedOnWidth {
        var actualScreenWidthEnum = ActualScreenSizeBasedOnWidth.iPhone4or5
        let actualScreenWidth = (UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width) ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
        if actualScreenWidth > 767 {
            actualScreenWidthEnum = ActualScreenSizeBasedOnWidth.iPad
        } else if actualScreenWidth > 413 {
            actualScreenWidthEnum = ActualScreenSizeBasedOnWidth.iPhone6Plus
        } else if actualScreenWidth > 374 {
            actualScreenWidthEnum = ActualScreenSizeBasedOnWidth.iPhone6
        } else if actualScreenWidth > 319 {
            actualScreenWidthEnum = ActualScreenSizeBasedOnWidth.iPhone4or5
        }
        return actualScreenWidthEnum
    }
    
    static func correctCellTextSize() -> TableViewTextSizeAdjustedForDynamicType {
        var screenEnum = TableViewTextSizeAdjustedForDynamicType.iPhone4or5
        var textSizeAdjustment = 0
        let actualScreenWidth = (UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width) ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
        
        //go through the real screen sizes
        if actualScreenWidth > 767 {
            screenEnum = TableViewTextSizeAdjustedForDynamicType.iPad
        } else if actualScreenWidth > 413 {
            screenEnum = TableViewTextSizeAdjustedForDynamicType.iPhone6Plus
        } else if actualScreenWidth > 374 {
            screenEnum = TableViewTextSizeAdjustedForDynamicType.iPhone6
        } else if actualScreenWidth > 319 {
            screenEnum = TableViewTextSizeAdjustedForDynamicType.iPhone4or5
        }
        
        //then adjust for the preferred text size
        if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.large {
            textSizeAdjustment = 0
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.extraLarge {
            textSizeAdjustment = 0
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.extraExtraLarge {
            textSizeAdjustment = 1
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.extraExtraExtraLarge {
            textSizeAdjustment = 1
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityMedium {
            textSizeAdjustment = 2
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityLarge {
            textSizeAdjustment = 2
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityExtraLarge {
            textSizeAdjustment = 2
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityExtraExtraLarge {
            textSizeAdjustment = 3
        } else if UIApplication.shared.preferredContentSizeCategory == UIContentSizeCategory.accessibilityExtraExtraExtraLarge {
            textSizeAdjustment = 3
        }
        
        //do the math to combine screen size and text size
        let rawAddition = screenEnum.rawValue + textSizeAdjustment
        if let mathAdjustment = TableViewTextSizeAdjustedForDynamicType(rawValue: rawAddition) {
            screenEnum = mathAdjustment
        } else {
            screenEnum = TableViewTextSizeAdjustedForDynamicType.iPadPlusPlus
        }
        
        return screenEnum
    }
}
