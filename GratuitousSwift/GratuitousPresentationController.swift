//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousPresentationController: UIPresentationController {
    
    private lazy var _dimmingView: UIView = {
        let dimView = UIView()
        let tap = UITapGestureRecognizer(target:self, action:"dimmingViewTapped:")
        let swipe = UISwipeGestureRecognizer(target:self, action:"dimmingViewTapped:")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        
        dimView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        dimView.alpha = 0.0
        dimView.addGestureRecognizer(swipe)
        dimView.addGestureRecognizer(tap)
        
        return dimView
    }()
    
    var dimmingView: UIView {
        let dimmingView = _dimmingView
        return dimmingView
    }
    
    func dimmingViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func presentationTransitionWillBegin() {
        self.dimmingView.frame = self.containerView!.bounds
        self.dimmingView.alpha = 0.0
        
        self.containerView!.insertSubview(self.dimmingView, atIndex: 0)
        
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
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let modifier: CGFloat
        switch UIApplication.sharedApplication().preferredContentSizeCategory {
        case UIContentSizeCategoryExtraLarge:
            modifier = 10
        case UIContentSizeCategoryExtraExtraLarge:
            modifier = 20
        case UIContentSizeCategoryExtraExtraExtraLarge:
            modifier = 40
        case UIContentSizeCategoryAccessibilityMedium:
            modifier = 90
        case UIContentSizeCategoryAccessibilityLarge:
            modifier = 150
        case UIContentSizeCategoryAccessibilityExtraLarge:
            modifier = 300
        case UIContentSizeCategoryAccessibilityExtraExtraLarge:
            modifier = 5000
        case UIContentSizeCategoryAccessibilityExtraExtraExtraLarge:
            modifier = 5000
        default:
            modifier = 0
        }
        
        let toContainerPreferredSize = container.preferredContentSize
        let toWidth: CGFloat
        if toContainerPreferredSize.width + modifier > parentSize.width {
            toWidth = parentSize.width
        } else {
            toWidth = toContainerPreferredSize.width + modifier
        }

        let toHeight: CGFloat
        if toContainerPreferredSize.height + (modifier * 1.4) > parentSize.height {
            toHeight = parentSize.height
        } else {
            toHeight = toContainerPreferredSize.height + (modifier * 1.4)
        }
        let contentViewSize = CGSize(width: toWidth, height: toHeight)
        return contentViewSize
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        return UIModalPresentationStyle.Custom
    }
    
    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = self.containerView!.bounds
        self.presentedView()?.frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let toSize = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: self.containerView!.bounds.size)
        
        let originX = ((self.containerView!.bounds.size.width - toSize.width) / 2)
        let originY = ((self.containerView!.bounds.size.height - toSize.height) / 2)
        let contentViewPoint = CGPoint(x: originX, y: originY)
        
        let rect = CGRect(origin: contentViewPoint, size: toSize)
        return rect
    }
}