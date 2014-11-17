//
//  GratuitousColorSelector.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousUIConstant: NSObject {
    
    class func lightBackgroundColor() -> UIColor {
        //return UIColor(red: 185.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return self.lightTextColor()
    }
    
    class func darkBackgroundColor() -> UIColor {
        return UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    class func lightTextColor() -> UIColor {
        return UIColor(red: 150.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
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
   
}
