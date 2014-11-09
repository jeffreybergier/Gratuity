//
//  GratuitousTransitionDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/7/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTransitionDelegate: NSObject, UIViewControllerAnimatedTransitioning {
    var modePresentDismiss = CustomTransitionMode.Present
    var stylePopoverModal = CustomTransitionStyle.Modal
    var originPoint = CGPointZero
    
    private let animationDurationPresent = GratuitousAnimations.duration()*2
    private let animationDurationDismiss = GratuitousAnimations.duration()*1
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> (NSTimeInterval) {
        return self.modePresentDismiss == CustomTransitionMode.Present ? self.animationDurationPresent : self.animationDurationDismiss
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let sourceRect = transitionContext.initialFrameForViewController(fromViewController)
        
        let transformScaleSmall = CGAffineTransformMakeScale(0.05, 0.05)
        let transformScaleLarge = self.stylePopoverModal == CustomTransitionStyle.Modal ? CGAffineTransformMakeScale(1.00, 1.00) : CGAffineTransformMakeScale(0.80, 0.80)
        let originalCenter = toViewController.view.center
        let containerView = transitionContext.containerView()
        
        if self.modePresentDismiss == CustomTransitionMode.Present {
            containerView.addSubview(toViewController.view)
            toViewController.view.frame = sourceRect
            toViewController.view.center = originPoint
            toViewController.view.alpha = 0.5
            toViewController.view.transform = transformScaleSmall
            if self.stylePopoverModal == .Popover {
                toViewController.view.layer.borderWidth = 3.0
                toViewController.view.layer.cornerRadius = 5.0
                toViewController.view.layer.borderColor = GratuitousColorSelector.lightBackgroundColor().CGColor
                toViewController.view.clipsToBounds = true
            }
            
            UIView.animateWithDuration(self.animationDurationPresent,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    toViewController.view.transform = transformScaleLarge
                    toViewController.view.center = originalCenter
                    toViewController.view.alpha = 1.0
                },
                completion: { finished in
                    transitionContext.completeTransition(true)
            })
        } else {
            UIView.animateWithDuration(self.animationDurationPresent,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 1.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    fromViewController.view.transform = transformScaleSmall
                    fromViewController.view.center = self.originPoint
                    fromViewController.view.alpha = 0.15
                },
                completion: { finished in
                    fromViewController.view.removeFromSuperview()
                    transitionContext.completeTransition(true)
            })
        }
    }
}

class GratuitousInteractiveTransitionAnimation: UIPercentDrivenInteractiveTransition {
    var viewController: UIViewController?
    var shouldComplete = false
    let panGestureRecognizer: UIPanGestureRecognizer
    
    
    override init() {
        //Horrible! I can't call super until the pan gesture recognizer is initialized. But I can't use self until after I call super. Convenience means sacrificing speed and initializing this object twice for no reason. I don't want to have to deal with the optional.
        //thanks swift! /s
        self.panGestureRecognizer = UIPanGestureRecognizer()
        super.init()
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onPan:")
    }
    
    func attachToViewController(viewController: UIViewController) {
        self.viewController = viewController
        self.viewController?.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    func onPan(pan: UIPanGestureRecognizer) {
        if let viewController = self.viewController {
            if let panSuperview = pan.view?.superview {
                let translation = pan.translationInView(panSuperview)
                switch pan.state {
                case .Began:
                    viewController.dismissViewControllerAnimated(true, completion: nil)
                case .Changed:
                    let dragAmount = CGFloat(UIScreen.mainScreen().bounds.width / 2)
                    let dragThreshold = CGFloat(0.5)
                    var dragPercent = CGFloat(translation.x / dragAmount)
                    dragPercent = CGFloat(fmaxf(Float(dragPercent), 0.0))
                    dragPercent = CGFloat(fminf(Float(dragPercent), 1.0))
                    self.updateInteractiveTransition(dragPercent)
                    self.shouldComplete = dragPercent >= dragThreshold
                case .Cancelled, .Ended:
                    if (pan.state == .Cancelled) || (self.shouldComplete == false) {
                        self.cancelInteractiveTransition()
                    } else {
                        self.finishInteractiveTransition()
                    }
                default:
                    break
                }
            }
        } else {
            println("GratuitousInteractiveTransitionAnimation: Panning started but there was no view controller. This should never happen")
        }
    }
    
    func completionSpeed() -> CGFloat {
        return 1 - self.completionSpeed
    }
}





