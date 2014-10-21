//
//  GratuitousColorSelector.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/10/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousColorSelector: NSObject {
    
    class func lightBackgroundColor() -> UIColor {
        //return UIColor(red: 185.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        return self.lightTextColor()
    }
    
    class func darkBackgroundColor() -> UIColor {
        return UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    class func lightTextColor() -> UIColor {
        return UIColor(red: 200.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        //return self.lightBackgroundColor()
    }
    
    class func darkTextColor() -> UIColor {
        //return UIColor(red: 104.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        return self.darkBackgroundColor()
    }
    
    class func textShadowColor() -> UIColor {
        return UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    }
   
}
