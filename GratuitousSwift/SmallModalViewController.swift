//
//  SmallModalViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class SmallModalViewController: UIViewController, CustomAnimatedTransitionable {
    
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var navigationBar: UINavigationBar?
    
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .Bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipe = UISwipeGestureRecognizer(target:self, action:"dismissViewControllerGestureTriggered:")
        swipe.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipe)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        self.configureDynamicTextLabels()
    }
    
    @objc private func dismissViewControllerGestureTriggered(sender: UIGestureRecognizer?) {
        guard let sender = sender else { return }
        switch sender.state {
        case .Ended:
            self.dismissViewControllerAnimated(true, completion: .None)
        default:
            return
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case this is not called by the trait collection changing
        self.navigationBarHeightDidChange()
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification) {
        self.configureDynamicTextLabels()
    }
    
    func configureDynamicTextLabels() {
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // needs to be called slightly after animation to work
            self.navigationBarHeightDidChange()
        }
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    func navigationBarHeightDidChange() {
        self.navigationBar?.sizeToFitWithStatusBar()
    }
    
    private func switchOnScreenSizeToDetermineBorderSurround() {
        let actualHeight = UIScreen.mainScreen().bounds.size.height
        switch actualHeight {
        case 0 ..< 480:
            self.showBorder()
        case 480 ... 568:
            self.hideBorder()
        case 569 ..< CGFloat.max:
            self.showBorder()
        default:
            break
        }
    }
    
    private func hideBorder() {
        self.contentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().CGColor
        self.contentView?.layer.borderWidth = 0
        self.contentView?.layer.cornerRadius = 0
        self.contentView?.clipsToBounds = true
    }
    
    private func showBorder() {
        self.contentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().CGColor
        self.contentView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.contentView?.layer.cornerRadius = 6
        self.contentView?.clipsToBounds = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension UINavigationBar {
    func sizeToFitWithStatusBar() {
        self.sizeToFit()
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let frameInWindowCoordinates = self.convertRect(self.frame, toView: .None)
        if frameInWindowCoordinates.origin.y <= statusBarHeight {
            //navbar is touching status bar
            let navBarHeight = self.frame.size.height
            self.frame.size.height = statusBarHeight + navBarHeight
        }
    }
}
