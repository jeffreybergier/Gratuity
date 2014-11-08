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

/*
- (NSTimeInterval)transitionDuration:(id )transitionContext {
    return self.mode == SwatchTransitionModePresent ? SWATCH_PRESENT_DURATION : SWATCH_DISMISS_DURATION;
    }
    
    - (void)animateTransition:(id )transitionContext {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
        
        CGAffineTransform rotation = CGAffineTransformMakeRotation(- M_PI / 2);
        UIView *container = [transitionContext containerView];
        
        if (self.mode == SwatchTransitionModePresent) {
            [container addSubview:toVC.view];
            
            toVC.view.layer.anchorPoint = CGPointZero;
            toVC.view.frame = sourceRect;
            toVC.view.transform = rotation;
            
            [UIView animateWithDuration:SWATCH_PRESENT_DURATION
                delay:0
                usingSpringWithDamping:0.25
                initialSpringVelocity:3
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                toVC.view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
                }];
        } else if(self.mode == SwatchTransitionModeDismiss) {
            [UIView animateWithDuration:SWATCH_DISMISS_DURATION
                delay:0
                options:UIViewAnimationOptionCurveEaseIn
                animations:^{
                fromVC.view.transform = rotation;
                } completion:^(BOOL finished) {
                [fromVC.view removeFromSuperview];
                [transitionContext completeTransition:YES];
                }];
        }
    }
*/