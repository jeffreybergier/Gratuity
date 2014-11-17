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
        return GratuitousUIConstant.animationDuration() * 2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromVC.view
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toVC.view
        
        if self.isPresentation {
            transitionContext.containerView().addSubview(toView)
        }
        
        let animatingInVC = self.isPresentation ? toVC : fromVC
        let animatingInView = animatingInVC.view
        let animatingOutVC = self.isPresentation ? fromVC : toVC
        let animatingOutView = animatingOutVC.view
        
        let appearedFrame = CGRectMake(
            transitionContext.finalFrameForViewController(animatingInVC).origin.x,
            transitionContext.finalFrameForViewController(animatingInVC).origin.y,
            transitionContext.finalFrameForViewController(animatingInVC).width,
            transitionContext.finalFrameForViewController(animatingInVC).height
        )
        let dismissedFrame = CGRectMake(
            appearedFrame.origin.x + appearedFrame.size.width /*appearedFrame.origin.x - appearedFrame.size.width*/,
            appearedFrame.origin.y,
            appearedFrame.size.width,
            appearedFrame.size.height
        )
        
        let initialFrame = self.isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = self.isPresentation ? appearedFrame : dismissedFrame
        let animatingInTransform = self.isPresentation ? CGAffineTransformIdentity : CGAffineTransformScale(animatingInView.transform, 0.9, 0.9)
        let animatingOutScaleTransform = CGAffineTransformScale(animatingOutView.transform, 0.8, 0.8)
        let animatingOutTransform = self.isPresentation ? CGAffineTransformTranslate(animatingOutScaleTransform, 0 - (transitionContext.containerView().bounds.width * 0.2), 0) : CGAffineTransformIdentity
        
        animatingInView.frame = initialFrame
        animatingInView.transform = self.isPresentation ? CGAffineTransformScale(animatingInView.transform, 0.9, 0.9) : CGAffineTransformIdentity
        
        let springDamping: CGFloat = self.isPresentation ? 0.8 : 0.6
        let springVelocity: CGFloat = self.isPresentation ? 1.0 : 1.8
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                animatingInView.frame = finalFrame
                animatingInView.transform = animatingInTransform
                animatingOutView.transform = animatingOutTransform
            },
            completion: { finished in
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}
