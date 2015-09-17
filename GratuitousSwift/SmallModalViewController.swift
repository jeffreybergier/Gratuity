//
//  SmallModalViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class SmallModalViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView?
    @IBOutlet weak var navigationBar: UINavigationBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "systemTextSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        self.configureDynamicTextLabels()
    }
    
    @objc private func systemTextSizeDidChange(notification: NSNotification) {
        self.configureDynamicTextLabels()
    }
    
    func configureDynamicTextLabels() {
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.switchOnScreenSizeToDetermineBorderSurround()
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
