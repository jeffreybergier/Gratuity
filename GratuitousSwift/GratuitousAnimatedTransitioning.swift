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

@objc protocol CustomAnimatedTransitionable {
    var customTransitionType: GratuitousTransitioningDelegateType { get }
}

extension UINavigationController: CustomAnimatedTransitionable {
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .Right
    }
}

class GratuitousAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var style: GratuitousTransitioningDelegateType = .Bottom
    var isPresentation = true
    var shouldAnimate = true
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        let duration: NSTimeInterval
        if self.isPresentation == false || self.shouldAnimate == true {
            duration = GratuitousUIConstant.animationDuration() * 2
        } else {
            duration = 0.01
        }
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else { return }
        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else { return }
        guard let transitionContextContainerView = transitionContext.containerView() else { return }
        
        let fromView = fromVC.view
        let toView = toVC.view
        
        if self.isPresentation == true {
            transitionContextContainerView.addSubview(toView)
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
        
        let originX: CGFloat
        let originY: CGFloat
        let transformTX: CGFloat
        let transformTY: CGFloat
        switch self.style {
        case .Bottom:
            originX = appearedFrame.origin.x
            originY = transitionContextContainerView.bounds.height
            transformTX = 0
            transformTY = 0 - (transitionContextContainerView.bounds.height * 0.2)
        default:
            originX = appearedFrame.origin.x + appearedFrame.size.width
            originY = appearedFrame.origin.y
            transformTX = 0 - (transitionContextContainerView.bounds.width * 0.2)
            transformTY = 0
        }
        
        let dismissedFrame = CGRect(
            x: originX,
            y: originY,
            width: appearedFrame.size.width,
            height: appearedFrame.size.height
        )
        
        let initialFrame = self.isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = self.isPresentation ? appearedFrame : dismissedFrame
        let animatingInTransform = self.isPresentation ? CGAffineTransformIdentity : CGAffineTransformScale(animatingInView.transform, 0.9, 0.9)
        let animatingOutScaleTransform = CGAffineTransformScale(animatingOutView.transform, 0.8, 0.8)
        let animatingOutTransform = self.isPresentation ? CGAffineTransformTranslate(animatingOutScaleTransform, transformTX, transformTY) : CGAffineTransformIdentity
        
        animatingInView.frame = initialFrame
        animatingInView.transform = self.isPresentation ? CGAffineTransformScale(animatingInView.transform, 0.9, 0.9) : CGAffineTransformIdentity
        
        let springDamping: CGFloat = self.isPresentation ? 0.8 : 0.6
        let springVelocity: CGFloat = self.isPresentation ? 1.0 : 1.8
        
        toVC.viewWillAppear(true)
        fromVC.viewWillDisappear(true)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState],
            animations: {
                animatingInView.frame = finalFrame
                animatingInView.transform = animatingInTransform
                animatingOutView.transform = animatingOutTransform
            },
            completion: { finished in
                toVC.viewDidAppear(true)
                fromVC.viewDidDisappear(true)
                if self.isPresentation == false {
                    fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(true)
        })
    }
}
