//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/20/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousPresentationController: UIPresentationController {
    
    fileprivate lazy var _dimmingView: UIView = {
        let dimView = UIView()
        let tap = UITapGestureRecognizer(target:self, action:#selector(self.dimmingViewTapped(_:)))
        let swipe = UISwipeGestureRecognizer(target:self, action:#selector(self.dimmingViewTapped(_:)))
        swipe.direction = UISwipeGestureRecognizerDirection.down
        
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
    
    @objc func dimmingViewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func presentationTransitionWillBegin() {
        self.dimmingView.frame = self.containerView!.bounds
        self.dimmingView.alpha = 0.0
        
        self.containerView!.insertSubview(self.dimmingView, at: 0)
        
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {
                (UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView.alpha = 1.0
                },
                completion: nil)
        } else {
            self.dimmingView.alpha = 1.0
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: {
                (UIViewControllerTransitionCoordinatorContext) -> Void in
                self.dimmingView.alpha = 0.0
                },
                completion: nil)
        } else {
            self.dimmingView.alpha = 0.0
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let modifier: CGFloat
        switch UIApplication.shared.preferredContentSizeCategory {
        case UIContentSizeCategory.extraLarge:
            modifier = 10
        case UIContentSizeCategory.extraExtraLarge:
            modifier = 20
        case UIContentSizeCategory.extraExtraExtraLarge:
            modifier = 40
        case UIContentSizeCategory.accessibilityMedium:
            modifier = 90
        case UIContentSizeCategory.accessibilityLarge:
            modifier = 150
        case UIContentSizeCategory.accessibilityExtraLarge:
            modifier = 300
        case UIContentSizeCategory.accessibilityExtraExtraLarge:
            modifier = 5000
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge:
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
    
    override var adaptivePresentationStyle : UIModalPresentationStyle {
        return UIModalPresentationStyle.custom
    }
    
    override func containerViewWillLayoutSubviews() {
        self.dimmingView.frame = self.containerView!.bounds
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var shouldPresentInFullscreen : Bool {
        return true
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        let toSize = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: self.containerView!.bounds.size)
        
        let originX = floor((self.containerView!.bounds.size.width - toSize.width) /? 2)
        let originY = floor((self.containerView!.bounds.size.height - toSize.height) /? 2)
        let contentViewPoint = CGPoint(x: originX, y: originY)
        
        let rect = CGRect(origin: contentViewPoint, size: toSize)
        return rect
    }
}
