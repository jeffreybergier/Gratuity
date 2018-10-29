//
//  GratuitousAnimatedTransitioning.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/19/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

@objc enum GratuitousTransitioningDelegateType: Int {
    case bottom, right, notApplicable
}

@objc protocol CustomAnimatedTransitionable {
    var customTransitionType: GratuitousTransitioningDelegateType { get }
}

extension UINavigationController: CustomAnimatedTransitionable {
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .right
    }
}

final class GratuitousAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var style: GratuitousTransitioningDelegateType = .bottom
    var isPresentation = true
    var shouldAnimate = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let duration: TimeInterval
        if self.isPresentation == false || self.shouldAnimate == true {
            duration = GratuitousUIConstant.animationDuration() * 2
        } else {
            duration = 0.01
        }
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromVC.view,
            let toView = toVC.view
        else { return }
        let transitionContextContainerView = transitionContext.containerView
    
        if self.isPresentation == true {
            transitionContextContainerView.addSubview(toView)
        }
        
        let animatingInVC = self.isPresentation ? toVC : fromVC
        let animatingInView = animatingInVC.view
        let animatingOutVC = self.isPresentation ? fromVC : toVC
        let animatingOutView = animatingOutVC.view
        
        let appearedFrame = CGRect(
            x: transitionContext.finalFrame(for: animatingInVC).origin.x,
            y: transitionContext.finalFrame(for: animatingInVC).origin.y,
            width: transitionContext.finalFrame(for: animatingInVC).width,
            height: transitionContext.finalFrame(for: animatingInVC).height
        )
        
        let originX: CGFloat
        let originY: CGFloat
        let transformTX: CGFloat
        let transformTY: CGFloat
        switch self.style {
        case .bottom:
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
        let animatingInTransform = self.isPresentation ? CGAffineTransform.identity : animatingInView?.transform.scaledBy(x: 0.9, y: 0.9)
        let animatingOutScaleTransform = animatingOutView?.transform.scaledBy(x: 0.8, y: 0.8)
        let animatingOutTransform = self.isPresentation ? animatingOutScaleTransform?.translatedBy(x: transformTX, y: transformTY) : CGAffineTransform.identity
        
        animatingInView?.frame = initialFrame
        animatingInView?.transform = self.isPresentation ? (animatingInView?.transform.scaledBy(x: 0.9, y: 0.9))! : CGAffineTransform.identity
        
        let springDamping: CGFloat = self.isPresentation ? 0.8 : 0.6
        let springVelocity: CGFloat = self.isPresentation ? 1.0 : 1.8
        
        toVC.viewWillAppear(true)
        fromVC.viewWillDisappear(true)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState],
            animations: {
                animatingInView?.frame = finalFrame
                animatingInView?.transform = animatingInTransform!
                animatingOutView?.transform = animatingOutTransform!
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
