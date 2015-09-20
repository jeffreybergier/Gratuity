//
//  GratuitousAnimatedTransitioning.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/19/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

@objc enum GratuitousTransitioningDelegateType: Int {
    case Bottom, Right, NotApplicable
}

class GratuitousAnimatedTransitioning: NSObject {
    var isPresentation = true
}

@objc protocol CustomAnimatedTransitionable {
    var customTransitionType: GratuitousTransitioningDelegateType { get }
}

extension UINavigationController: CustomAnimatedTransitionable {
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .Right
    }
}