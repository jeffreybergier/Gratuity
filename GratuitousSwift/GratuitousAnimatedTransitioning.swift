//
//  GratuitousAnimatedTransitioning.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresentation = true
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 20.0 //GratuitousUIConstant.animationDuration()
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromVC.view
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toVC.view
        
        if self.isPresentation {
            transitionContext.containerView().addSubview(toView)
        }
        
        let animatingVC = self.isPresentation ? toVC : fromVC
        let animatingView = animatingVC.view
        
        animatingView.frame = transitionContext.finalFrameForViewController(animatingVC)
        
        let presentedTransform = CGAffineTransformIdentity
        let dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(CGFloat(8 * M_PI)))
        
        animatingView.transform = self.isPresentation ? dismissedTransform : presentedTransform
        
        UIView.animateWithDuration(GratuitousUIConstant.animationDuration(),
            delay: 0.0,
            usingSpringWithDamping: 1.01,
            initialSpringVelocity: 1.0,
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                animatingView.transform = self.isPresentation ? presentedTransform : dismissedTransform
            },
            completion: { finished in
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}
