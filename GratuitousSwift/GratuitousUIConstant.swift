//
//  GratuitousColorSelector.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousUIConstant: NSObject {
    
    private class func invertColorsIsEnabled() -> Bool {
        var invertColors = false
        
        if UIAccessibilityIsInvertColorsEnabled() {
            invertColors = true
        }
        
        return invertColors
    }
    
    class func lightBackgroundColor() -> UIColor {
        //return UIColor(red: 185.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return self.lightTextColor()
    }
    
    class func darkBackgroundColor() -> UIColor {
        var color = UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        if invertColorsIsEnabled() {
            color = UIColor.whiteColor()
        }
        
        return color
    }
    
    class func lightTextColor() -> UIColor {
        var color = UIColor(red: 150.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        if invertColorsIsEnabled() {
            color = UIColor.blackColor()
        }
        
        return color
        //return self.lightBackgroundColor()
    }
    
    class func darkTextColor() -> UIColor {
        //return UIColor(red: 104.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return self.darkBackgroundColor()
    }
    
    class func textShadowColor() -> UIColor {
        return UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    }
    
    class func thickBorderWidth() -> CGFloat {
        return 2.0
    }
    
    class func thinBorderWidth() -> CGFloat {
        return 1.0
    }
    
    class func animationDuration() -> Double {
        return 0.3
    }
    
    class func originalFontForTableViewCellTextLabels() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: 35.0)
    }
    
    class func originalFontForTotalAmountTextLabel() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: 180.0)
    }
    
    class func originalFontForTipPercentageTextLabel() -> UIFont? {
        return UIFont(name: "Futura-Medium", size: 100.0)
    }
    
    class func deviceScreen() -> (padIdiom: Bool, largeDevice: Bool, smallDeviceLandscape: Bool, largeDeviceLandscape: Bool) {
        var padIdiom = false
        var largeDevice = false
        var smallDeviceLandscape = false
        var largeDeviceLandscape = false
        
        if UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width {
            if UIScreen.mainScreen().bounds.size.width > 321.0 {
                largeDevice = true
            }
        } else {
            if UIScreen.mainScreen().bounds.size.height > 321.0 {
                largeDevice = true
                largeDeviceLandscape = true
            } else {
                smallDeviceLandscape = true
            }
        }
        
        if UIScreen.mainScreen().traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            padIdiom = true
        }
        
        return (padIdiom: padIdiom, largeDevice: largeDevice, smallDeviceLandscape: smallDeviceLandscape, largeDeviceLandscape: largeDeviceLandscape)
    }
    
    class func largeTextLandscapeConstant() -> CGFloat {
        var constant: CGFloat = 0
        
        //then adjust for the preferred text size
        if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryLarge {
            constant = 0
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryExtraLarge {
            constant = 0
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryExtraExtraLarge {
            constant = 50
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryExtraExtraExtraLarge {
            constant = 50
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityMedium {
            constant = 100
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityLarge {
            constant = 100
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityExtraLarge {
            constant = 100
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityExtraExtraLarge {
            constant = 150
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityExtraExtraExtraLarge {
            constant = 150
        }
        
        return constant
    }

    
    class func actualScreenSizeBasedOnWidth() -> ActualScreenSizeBasedOnWidth {
        var actualScreenWidthEnum = ActualScreenSizeBasedOnWidth.iPhone4or5
        let actualScreenWidth = (UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width) ? UIScreen.mainScreen().bounds.size.width : UIScreen.mainScreen().bounds.size.height
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
    
    class func correctCellTextSize() -> TableViewTextSizeAdjustedForDynamicType {
        var screenEnum = TableViewTextSizeAdjustedForDynamicType.iPhone4or5
        var textSizeAdjustment = 0
        let actualScreenWidth = (UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width) ? UIScreen.mainScreen().bounds.size.width : UIScreen.mainScreen().bounds.size.height
        
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
        if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryLarge {
            textSizeAdjustment = 0
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryExtraLarge {
            textSizeAdjustment = 0
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryExtraExtraLarge {
            textSizeAdjustment = 1
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryExtraExtraExtraLarge {
            textSizeAdjustment = 1
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityMedium {
            textSizeAdjustment = 2
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityLarge {
            textSizeAdjustment = 2
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityExtraLarge {
            textSizeAdjustment = 2
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityExtraExtraLarge {
            textSizeAdjustment = 3
        } else if UIApplication.sharedApplication().preferredContentSizeCategory == UIContentSizeCategoryAccessibilityExtraExtraExtraLarge {
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
