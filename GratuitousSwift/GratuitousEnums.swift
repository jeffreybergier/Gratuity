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
    func textSizeAdjustment() -> CGFloat {
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

enum InterfaceControllerContext: String, Printable {
    case CrownScrollInfinite = "CrownScrollInfinite"
    case CrownScrollPagedTens = "CrownScrollPagedTens"
    case CrownScrollPagedOnes = "CrownScrollPagedOnes"
    case CrownScrollTipChooser = "CrownScrollTipChooser"
    case ThreeButtonStepperBill = "ThreeButtonStepperBill"
    case ThreeButtonStepperTip = "ThreeButtonStepperTip"
//    case StepperPagedOnes = "StepperPagedOnes"
//    case StepperTipChooser = "StepperTipChooser"
    case TotalAmountInterfaceController = "TotalAmountInterfaceController"
    case NotSet = "NotSet"
    
    var description: String {
        return "InterfaceControllerContext Enum: \(self.rawValue)"
    }
}

enum CorrectWatchInterface: Int, Printable {
    case CrownScrollInfinite = 0, CrownScrollPaged, ThreeButtonStepper//StepperInfinite, StepperPaged
    
    var description: String {
        switch self {
        case .CrownScrollInfinite:
            return "InterfaceState Enum: CrownScrollInfinite"
        case .CrownScrollPaged:
            return "InterfaceState Enum: CrownScrollPaged"
        case .ThreeButtonStepper:
            return "InterfaceState Enum: ThreeButtonStepper"
//        case .StepperInfinite:
//            return "InterfaceState Enum: StepperInfinite"
//        case .StepperPaged:
//            return "InterfaceState Enum: StepperPaged"
        }
    }
    
    static func interfaceStateFromString(string: String) -> CorrectWatchInterface? {
        switch string {
        case "CrownScrollInfinite":
            return CorrectWatchInterface.CrownScrollInfinite
        case "CrownScrollPaged":
            return CorrectWatchInterface.CrownScrollPaged
        case "ThreeButtonStepper":
            return CorrectWatchInterface.ThreeButtonStepper
        default:
            return nil
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

enum Futura: String, Printable, Hashable {
    case Medium = "Futura-Medium"
    case MediumItalic = "Futura-MediumItalic"
    case CondensedMedium = "Futura-CondensedMedium"
    case CondensedExtraBold = "Futura-CondensedExtraBold"
    
    var description: String {
        switch self {
        case Medium:
            return "Futura-Medium"
        case MediumItalic:
            return "Futura-MediumItalic"
        case CondensedMedium:
            return "Futura-CondensedMedium"
        case CondensedExtraBold:
            return"Futura-CondensedExtraBold"
        }
    }
    
    var hashValue: Int {
        return self.description.hashValue
    }
}

enum UIFontStyle: Printable, Hashable {
    case Headline
    case Body
    case Caption1
    case Caption2
    case Footnote
    case Subheadline
    
    var description: String {
        switch self {
        case .Headline:
            return UIFontTextStyleHeadline.description
        case Body:
            return UIFontTextStyleBody.description
        case Caption1:
            return UIFontTextStyleCaption1.description
        case Caption2:
            return UIFontTextStyleCaption2.description
        case Footnote:
            return UIFontTextStyleFootnote.description
        case Subheadline:
            return UIFontTextStyleSubheadline.description
        }
    }
    
    var hashValue: Int {
        return self.description.hashValue
    }
}

extension UIFont {
    convenience init?(futuraStyle: Futura, size: CGFloat) {
        self.init(name: futuraStyle.rawValue, size: size)
    }
    
    class func futura(#style: Futura, size: CGFloat, fallbackStyle: UIFontStyle) -> UIFont {
        return UIFont(futuraStyle: style, size: size) !! UIFont.preferredFontForTextStyle(fallbackStyle.description)
    }
}
