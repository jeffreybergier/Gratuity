//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousPresentationController: UIPresentationController {
    
    lazy var dimmingView :UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target:self, action:"dimmingViewTapped:")

        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.alpha = 0.0
        view.addGestureRecognizer(tap)
        
        return view
        }()
    
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
        return UIModalPresentationStyle.Custom
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        var divisionConstant = CGFloat(1.0)
        var textSizeAdjustment = CGFloat(0.0)
        let deviceScreen = GratuitousUIConstant.deviceScreen()
        
        if deviceScreen.smallDeviceLandscape {
            divisionConstant = 1.4
        }
        
        if deviceScreen.largeDevice {
            if deviceScreen.largeDeviceLandscape {
                divisionConstant = 2.1
            } else {
                divisionConstant = 1.2
            }
        }
        
        if deviceScreen.padIdiom {
            if deviceScreen.largeDeviceLandscape {
                divisionConstant = 2.7
            } else {
                divisionConstant = 2.3
            }
        }
        
        switch UIApplication.sharedApplication().preferredContentSizeCategory {
        case UIContentSizeCategoryExtraExtraExtraLarge:
            textSizeAdjustment = 0.25
        case UIContentSizeCategoryAccessibilityMedium:
            textSizeAdjustment = 0.5
        case UIContentSizeCategoryAccessibilityLarge:
            textSizeAdjustment = 0.75
        case UIContentSizeCategoryAccessibilityExtraLarge:
            textSizeAdjustment = 1.0
        case UIContentSizeCategoryAccessibilityExtraExtraLarge:
            textSizeAdjustment = 1.25
        case UIContentSizeCategoryAccessibilityExtraExtraExtraLarge:
            textSizeAdjustment = 1.5
        default:
            break
        }
        
        let divisionCalculation = (divisionConstant - textSizeAdjustment < 1.0) ? (1.0) : (divisionConstant - textSizeAdjustment)
        
        let floatWidth = Float(parentSize.width / divisionCalculation)
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
    
    func dimmingViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
