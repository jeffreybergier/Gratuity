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
    
    fileprivate var borderHidden = false
    fileprivate var peekMode = false
    fileprivate var doneButton: UIBarButtonItem?
    
    var customTransitionType: GratuitousTransitioningDelegateType {
        return .bottom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        self.configureDynamicTextLabels()
        
        if self.peekMode == true {
            self.doneButton = self.navigationBar?.items?.last?.rightBarButtonItem
            self.navigationBar?.items?.last?.rightBarButtonItem = .none
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
    fileprivate var _preferredContentSize = CGSize(width: 320, height: 568)
    
    @objc fileprivate func dismissViewControllerGestureTriggered(_ sender: UIGestureRecognizer?) {
        guard let sender = sender else { return }
        switch sender.state {
        case .ended:
            self.dismiss(animated: true, completion: .none)
        default:
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // just in case this is not called by the trait collection changing
        self.navigationBarHeightDidChange()
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // just in case this is not called by the trait collection changing
        let delayTime = DispatchTime.now() + Double(Int64(0.03 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
    
    @objc fileprivate func systemTextSizeDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            self.configureDynamicTextLabels()
            self.switchOnScreenSizeToDetermineBorderSurround()
        }
    }
    
    func configureDynamicTextLabels() {
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            // needs to be called slightly after animation to work
            self.navigationBarHeightDidChange()
        }
        
        self.navigationBarHeightDidChange()
        self.switchOnScreenSizeToDetermineBorderSurround()
    }
    
    func navigationBarHeightDidChange() {
        self.navigationBar?.sizeToFitWithStatusBar()
    }
    
    fileprivate func switchOnScreenSizeToDetermineBorderSurround() {
        let shorterThanScreen = self.view.bounds.height < UIScreen.main.bounds.size.height
        let narrowerThanScreen = self.view.bounds.width < UIScreen.main.bounds.size.width
        
        if (shorterThanScreen || narrowerThanScreen) && self.borderHidden == false {
            self.showBorder()
        } else {
            self.hideBorder()
        }
    }
    
    fileprivate func hideBorder() {
        self.contentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().cgColor
        self.contentView?.layer.borderWidth = 0
        self.contentView?.layer.cornerRadius = 0
        self.contentView?.clipsToBounds = true
    }
    
    fileprivate func showBorder() {
        self.contentView?.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().cgColor
        self.contentView?.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.contentView?.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.contentView?.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape, UIInterfaceOrientationMask.portraitUpsideDown]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UINavigationBar {
    func sizeToFitWithStatusBar() {
        self.layoutSubviews()
        self.sizeToFit()
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let frameInWindowCoordinates = self.convert(self.frame, to: .none)
        if frameInWindowCoordinates.origin.y <= statusBarHeight {
            //navbar is touching status bar
            let navBarHeight = self.frame.size.height
            self.frame.size.height = statusBarHeight + navBarHeight
        }
    }
}
