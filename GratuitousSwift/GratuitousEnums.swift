//
//  GratuitousEnums.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/7/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

enum CustomTransitionMode: Int {
    case Present = 0, Dismiss
}

enum CustomTransitionStyle: Int {
    case Modal = 0, Popover
}

enum CurrencySign: Int, Printable {
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
    
    var description: String {
        get {
            switch self {
            case .Default:
                return "Currency Sign: Default"
            case .Dollar:
                return "Currency Sign: Dollar"
            case .Pound:
                return "Currency Sign: Pound"
            case .Euro:
                return "Currency Sign: Euro"
            case .Yen:
                return "Currency Sign: Yen"
            case .None:
                return "Currency Sign: None"
            }
        }
    }
}

enum TableViewTextSizeAdjustedForDynamicType: Int {
    //this takes into account screen size and text size adjustment. Thats why there are fake screen sizes.
    case iPhone4or5 = 0, iPhone6, iPhone6Plus, iPad, iPadPlus, iPadPlusPlus
    
    func rowHeight() -> CGFloat {
        switch self {
        case .iPhone4or5:
            return 60.0
        case .iPhone6:
            return 73.0
        case .iPhone6Plus:
            return 83.0
        case .iPad:
            return 93.0
        case .iPadPlus:
            return 103.0
        case .iPadPlusPlus:
            return 117.0
        }
    }
    func textSizeAdjustment() -> Double {
        switch self {
        case .iPhone4or5:
            return 1.0
        case .iPhone6:
            return 1.2
        case .iPhone6Plus:
            return 1.4
        case .iPad:
            return 1.6
        case .iPadPlus:
            return 1.8
        case .iPadPlusPlus:
            return 2.0
        }
    }
}

enum ActualScreenSizeBasedOnWidth: Int {
    //this takes into account screen size and text size adjustment. Thats why there are fake screen sizes.
    case iPhone4or5 = 0, iPhone6, iPhone6Plus, iPad
}

enum CorrectInterface: Int, Printable {
    case Unknown = 0, CrownScroll, StepByStep
    
    var description: String {
        get {
            switch self {
            case .Unknown:
                return "CorrectInterface Enum: Unknown"
            case .CrownScroll:
                return "CorrectInterface Enum: CrownScroll"
            case .StepByStep:
                return "CorrectInterface Enum: StepByStep"
            }
        }
    }
}

// Operator Overloading!!
// AssertingNilCoalescing operator crashes when LHS is nil when App is in Debug Build.
// When App is in release build, it performs ?? operator
// Crediting http://blog.human-friendly.com/theanswer-equals-maybeanswer-or-a-good-alternative

infix operator !! { associativity right precedence 110 }
public func !!<A>(lhs:A?, rhs:@autoclosure()->A)->A {
    assert(lhs != nil)
    return lhs ?? rhs()
}
