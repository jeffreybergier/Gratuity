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
        
        if UIAccessibilityIsInvertColorsEnabled() {
            invertColors = true
        }
        
        return invertColors
    }
    
    static func lightBackgroundColor() -> UIColor {
        //return UIColor(red: 185.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return self.lightTextColor()
    }
    
    static func darkBackgroundColor() -> UIColor {
        var color = UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        if invertColorsIsEnabled() {
            color = UIColor.whiteColor()
        }
        
        return color
    }
    
    static func lightTextColor() -> UIColor {
        var color = UIColor(red: 150.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        if invertColorsIsEnabled() {
            color = UIColor.blackColor()
        }
        
        return color
        //return self.lightBackgroundColor()
    }
    
    static func darkTextColor() -> UIColor {
        //return UIColor(red: 104.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return self.darkBackgroundColor()
    }
    
    static func textShadowColor() -> UIColor {
        return UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    }
}
