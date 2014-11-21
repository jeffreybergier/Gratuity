//
//  GratuitousEnums.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/7/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import Foundation

enum CustomTransitionMode: Int {
    case Present = 0, Dismiss
}

enum CustomTransitionStyle: Int {
    case Modal = 0, Popover
}

enum CurrencySign: Int {
    case Default = 0, Dollar, Pound, Euro, Yen, None
    
    func string() -> String {
        switch self {
        case .Default:
            return ""
        case .Dollar:
            return "$"
        case .Pound:
            return "£"
        case .Euro:
            return "€"
        case .Yen:
            return "¥"
        case .None:
            return ""
        }
    }
}

enum CorrectedScreenAndTextSize: Int {
    //this takes into account screen size and text size adjustment. Thats why there are fake screen sizes.
    case iPhone4or5 = 0, iPhone6, iPhone6Plus, iPad, iPadPlus, iPadPlusPlus
}

enum ActualScreenSizeBasedOnWidth: Int {
    //this takes into account screen size and text size adjustment. Thats why there are fake screen sizes.
    case iPhone4or5 = 0, iPhone6, iPhone6Plus, iPad
}
