//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

class GratuitousRightPresentationController: GratuitousPresentationController {
    
    private lazy var _dimmingView :UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target:self, action:"dimmingViewTapped:")
        let swipe = UISwipeGestureRecognizer(target:self, action:"dimmingViewTapped:")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.alpha = 0.0
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipe)
        
        return view
    }()
    
    override var dimmingView: UIView {
        return _dimmingView
    }
    
    @objc private func dimmingViewTapped(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
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
                divisionConstant = 1.9
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
}
