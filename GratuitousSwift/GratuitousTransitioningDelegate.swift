//
//  GratuitousTransitioningDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTransitioningDelegate: UIPercentDrivenInteractiveTransition, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate {
    
    private var interactive = false
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    var sourceViewController: TipViewController! {
        didSet {
            self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
            self.enterPanGesture.edges = UIRectEdge.Right
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
        }
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        let translation = pan.translationInView(pan.view!)
        // do some math to translate this to a percentage based value
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds) * 0.5
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
        case UIGestureRecognizerState.Began:
            // set our interactive flag to true
            self.interactive = true
            // trigger the start of the transition
            self.sourceViewController.didTapSettingsButton(nil)
            //self.sourceViewController.performSegueWithIdentifier("interactiveSettingsSegue", sender: self)
        case UIGestureRecognizerState.Changed:
            // update progress of the transition
            self.updateInteractiveTransition(d)
        default: // .Ended, .Cancelled, .Failed ...
            // return flag to false and finish the transition
            self.interactive = false
            self.finishInteractiveTransition()
//            if(d > 0.1){
//                self.finishInteractiveTransition()
//            }
//            else {
//                self.cancelInteractiveTransition()
//            }
        }
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return GratuitousPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationController() -> GratuitousAnimatedTransitioning {
        return GratuitousAnimatedTransitioning()
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = self.animationController()
        animationController.isPresentation = true
        
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = self.animationController()
        animationController.isPresentation = false
        
        return animationController
    }
}
