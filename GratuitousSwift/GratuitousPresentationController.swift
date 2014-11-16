//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousPresentationController: UIPresentationController {
    
    var dimmingView = UIView()
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        self.prepareDimmingView()
    }
    
    override func presentationTransitionWillBegin() {
        self.dimmingView.frame = self.containerView.bounds
        self.dimmingView.alpha = 0.0
        
        self.containerView.insertSubview(self.dimmingView, atIndex: 0)
        
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                (UIViewControllerTransitionCoordinatorContext) -> Void in
                    self.dimmingView.alpha = 1.0
                },
                completion: nil)
        } else {
            self.dimmingView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({
                (UIViewControllerTransitionCoordinatorContext) -> Void in
                    self.dimmingView.alpha = 0.0
                },
                completion: nil)
        } else {
            self.dimmingView.alpha = 0.0
        }
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let floatWidth = Float(parentSize.width / 2.0)
        let cgWidth = CGFloat(floorf(floatWidth))
        return CGSizeMake(cgWidth, parentSize.height)
    }
    
    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = self.containerView.bounds
        self.presentedView().frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        
        presentedViewFrame.size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: self.containerView.bounds.size)
        presentedViewFrame.origin.x = self.containerView.bounds.size.width - presentedViewFrame.size.width
        
        return presentedViewFrame
    }
    
    func prepareDimmingView() {
        self.dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        self.dimmingView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target:self, action:"dimmingViewTapped:")
        self.dimmingView.addGestureRecognizer(tap)
    }
    
    func dimmingViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
