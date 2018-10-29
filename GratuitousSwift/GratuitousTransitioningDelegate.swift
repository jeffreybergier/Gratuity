//
//  GratuitousTransitioningDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    fileprivate let type: GratuitousTransitioningDelegateType
    fileprivate let shouldAnimate: Bool
    
    lazy var rightAnimationController: GratuitousAnimatedTransitioning = {
        let a = GratuitousAnimatedTransitioning()
        a.style = .right
        a.shouldAnimate = self.shouldAnimate
        return a
    }()
    lazy var bottomAnimationController: GratuitousAnimatedTransitioning = {
        let a = GratuitousAnimatedTransitioning()
        a.style = .bottom
        a.shouldAnimate = self.shouldAnimate
        return a
    }()
    
    init(type: GratuitousTransitioningDelegateType, animate: Bool) {
        self.type = type
        self.shouldAnimate = animate
    }
        
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        switch self.type {
        case .right:
            return GratuitousRightPresentationController(presentedViewController: presented, presenting: presenting)
        case .bottom:
            return GratuitousPresentationController(presentedViewController: presented, presenting: presenting)
        case .notApplicable:
            return .none
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animationController: GratuitousAnimatedTransitioning?
        switch self.type {
        case .bottom:
            animationController = self.bottomAnimationController
        case .right:
            animationController = self.rightAnimationController
        case .notApplicable:
            animationController = nil
        }
        animationController?.isPresentation = true
        
        return animationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController: UIViewControllerAnimatedTransitioning?
        switch self.type {
        case .bottom:
            animationController = self.bottomAnimationController
        case .right:
            animationController = self.rightAnimationController
        case .notApplicable:
            animationController = nil
        }
        (animationController as! GratuitousAnimatedTransitioning).isPresentation = false
        
        return animationController
    }
}
