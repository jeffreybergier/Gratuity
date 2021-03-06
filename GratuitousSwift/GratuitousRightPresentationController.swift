//
//  GratuitousPresentationController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 11/15/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit

final class GratuitousRightPresentationController: GratuitousPresentationController {
    
    lazy var _dimmingView :UIView = {
        let view = UIView()
        let tap = UITapGestureRecognizer(target:self, action:#selector(self.dimmingViewTapped(_:)))
        let swipe = UISwipeGestureRecognizer(target:self, action:#selector(self.dimmingViewTapped(_:)))
        swipe.direction = UISwipeGestureRecognizerDirection.right
        
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        view.alpha = 0.0
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipe)
        
        return view
    }()
    
    override var dimmingView: UIView {
        let dimmingView = _dimmingView
        return dimmingView
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        let size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: self.containerView!.bounds.size)
        let point = CGPoint(x: self.containerView!.bounds.size.width - size.width, y: 0)
        
        let rect = CGRect(origin: point, size: size)
        return rect
    }
    
}
