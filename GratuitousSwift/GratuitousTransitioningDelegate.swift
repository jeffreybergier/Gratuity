//
//  GratuitousTransitioningDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    let type: GratuitousTransitioningDelegateType
    
    lazy var rightAnimationController: GratuitousAnimatedTransitioning = {
        let a = GratuitousAnimatedTransitioning()
        a.style = .Right
        return a
    }()
    lazy var bottomAnimationController: GratuitousAnimatedTransitioning = {
        let a = GratuitousAnimatedTransitioning()
        a.style = .Bottom
        return a
    }()
    
    init(type: GratuitousTransitioningDelegateType) {
        self.type = type
    }
        
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        switch self.type {
        case .Right:
            return GratuitousRightPresentationController(presentedViewController: presented, presentingViewController: presenting)
        case .Bottom:
            return GratuitousPresentationController(presentedViewController: presented, presentingViewController: presenting)
        case .NotApplicable:
            return .None
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animationController: GratuitousAnimatedTransitioning?
        switch self.type {
        case .Bottom:
            animationController = self.bottomAnimationController
        case .Right:
            animationController = self.rightAnimationController
        case .NotApplicable:
            animationController = nil
        }
        animationController?.isPresentation = true
        
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController: UIViewControllerAnimatedTransitioning?
        switch self.type {
        case .Bottom:
            animationController = self.bottomAnimationController
        case .Right:
            animationController = self.rightAnimationController
        case .NotApplicable:
            animationController = nil
        }
        (animationController as! GratuitousAnimatedTransitioning).isPresentation = false
        
        return animationController
    }
}
