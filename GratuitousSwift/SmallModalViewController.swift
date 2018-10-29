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
    
    private var borderHidden = false
    private var peekMode = false
    private var doneButton: UIBarButtonItem?
    
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .Bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
        self.configureDynamicTextLabels()
        
        if self.peekMode == true {
            self.doneButton = self.navigationBar?.items?.last?.rightBarButtonItem
            self.navigationBar?.items?.last?.rightBarButtonItem = .None
        }

    }
    
    override var preferredContentSize: CGSize {
        get {
            return _preferredContentSize
        }
        set {
            _preferredContentSize = newValue
        }
    }
    private var _preferredContentSize = CGSize(width: 320, height: 568)
    
    @objc private func dismissViewControllerGestureTriggered(sender: UIGestureRecognizer?) {
        guard let sender = sender else { return }
        switch sender.state {
        case .Ended:
            self.dismissViewControllerAnimated(true, completion: .None)
        default:
            return
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // just in case this is not called by the trait collection changing
        self.navigationBarHeightDidChange()
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case this is not called by the trait collection changing
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.03 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.navigationBarHeightDidChange()
        }
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    func setPeekModeEnabled() {
        self.preferredContentSize = CGSize(width: 320, height: 400)
        self.borderHidden = true
        self.peekMode = true
    }
    
    func setPopModeEnabled() {
        self.preferredContentSize = CGSize(width: 320, height: 568)
        self.navigationBar?.items?.last?.rightBarButtonItem = self.doneButton
        self.borderHidden = false
        self.peekMode = false
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.configureDynamicTextLabels()
            self.switchOnScreenSizeToDetermineBorderSurround()
        }
    }
    
    func configureDynamicTextLabels() {
        
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // needs to be called slightly after animation to work
            self.navigationBarHeightDidChange()
        }
        
        self.navigationBarHeightDidChange()
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    func navigationBarHeightDidChange() {
        self.navigationBar?.sizeToFitWithStatusBar()
    }
    
    private func switchOnScreenSizeToDetermineBorderSurround() {
        let shorterThanScreen = self.view.bounds.height < UIScreen.mainScreen().bounds.size.height
        let narrowerThanScreen = self.view.bounds.width < UIScreen.mainScreen().bounds.size.width
        
        if (shorterThanScreen || narrowerThanScreen) && self.borderHidden == false {
            self.showBorder()
        } else {
            self.hideBorder()
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
        self.contentView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.contentView?.clipsToBounds = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.Landscape, UIInterfaceOrientationMask.PortraitUpsideDown]
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension UINavigationBar {
    func sizeToFitWithStatusBar() {
        self.layoutSubviews()
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
