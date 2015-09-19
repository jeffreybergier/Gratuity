//
//  GratuitousTransitioningDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
        
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return GratuitousPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationController() -> GratuitousAnimatedTransitioning {
        let animationController = GratuitousAnimatedTransitioning()
        return animationController
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
