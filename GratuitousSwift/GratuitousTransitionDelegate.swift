//
//  GratuitousTransitionDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/7/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTransitionDelegate: NSObject {
    var mode = SwatchTransitionMode.Present
    private let animationDurationPresent = GratuitousAnimations.duration()*8
    private let animationDurationDismiss = GratuitousAnimations.duration()*4
    
    func transitionDuration(transitionContext: AnyObject) -> (NSTimeInterval) {
        return self.mode == SwatchTransitionMode.Present ? self.animationDurationPresent : self.animationDurationDismiss
    }
    
    func animateTransition(transitionContext: AnyObject) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UIViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UIViewController
        
        let sourceRect = transitionContext.initialFrameForViewController(fromViewController)
        
        let transformScale = CGAffineTransformMakeScale(0.05, 0.05)
        let containerView = transitionContext.containerView()
        
        if self.mode == SwatchTransitionMode.Present {
            containerView.addSubview(toViewController.view)
            toViewController.view.layer.anchorPoint = CGPointZero
            toViewController.view.frame = sourceRect
            toViewController.view.transform = transformScale
            
            UIView.animateWithDuration(self.animationDurationPresent,
                delay: 0.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    toViewController.view.transform = CGAffineTransformIdentity
                },
                completion: { finished in
                    transitionContext.completeTransition(true)
            })
        } else {
            
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