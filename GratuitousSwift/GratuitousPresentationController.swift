//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousPresentationController: UIPresentationController {
    
    var unwrappedContainerView: UIView! {
        return self.containerView!
    }
    
    private let _dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.alpha = 0.0
        return view
    }()
    
    var dimmingView: UIView {
        return _dimmingView
    }
    
    override func presentationTransitionWillBegin() {
        self.dimmingView.frame = self.unwrappedContainerView.bounds
        self.dimmingView.alpha = 0.0
        
        self.unwrappedContainerView.insertSubview(self.dimmingView, atIndex: 0)
        
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
        return UIModalPresentationStyle.Custom
    }
    
    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = self.unwrappedContainerView.bounds
        self.presentedView()!.frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        
        presentedViewFrame.size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: self.unwrappedContainerView.bounds.size)
        presentedViewFrame.origin.x = self.unwrappedContainerView.bounds.size.width - presentedViewFrame.size.width
        
        return presentedViewFrame
    }
}