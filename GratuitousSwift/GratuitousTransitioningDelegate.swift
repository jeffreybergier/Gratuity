//
//  GratuitousTransitioningDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let type: GratuitousTransitioningDelegateType
    private let shouldAnimate: Bool
    
    lazy var rightAnimationController: GratuitousAnimatedTransitioning = {
        let a = GratuitousAnimatedTransitioning()
        a.style = .Right
        a.shouldAnimate = self.shouldAnimate
        return a
    }()
    lazy var bottomAnimationController: GratuitousAnimatedTransitioning = {
        let a = GratuitousAnimatedTransitioning()
        a.style = .Bottom
        a.shouldAnimate = self.shouldAnimate
        return a
    }()
    
    init(type: GratuitousTransitioningDelegateType, animate: Bool) {
        self.type = type
        self.shouldAnimate = animate
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
