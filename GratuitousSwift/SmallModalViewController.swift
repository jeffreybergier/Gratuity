//
//  SmallModalViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class RoundedRectModalNavigationController: UINavigationController {

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.switchOnScreenSizeToDetermineBorderSurround()
    }

    fileprivate func switchOnScreenSizeToDetermineBorderSurround() {
        let shorterThanScreen = self.view.bounds.height < UIScreen.main.bounds.size.height
        let narrowerThanScreen = self.view.bounds.width < UIScreen.main.bounds.size.width

        if (shorterThanScreen || narrowerThanScreen) {
            self.showBorder()
        } else {
            self.hideBorder()
        }
    }

    fileprivate func hideBorder() {
        self.view.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().cgColor
        self.view.layer.borderWidth = 0
        self.view.layer.cornerRadius = 0
        self.view.clipsToBounds = true
    }

    fileprivate func showBorder() {
        self.view.layer.borderColor = GratuitousUIColor.mediumBackgroundColor().cgColor
        self.view.layer.borderWidth = GratuitousUIConstant.thickBorderWidth()
        self.view.layer.cornerRadius = GratuitousUIConstant.cornerRadius
        self.view.clipsToBounds = true
    }

}

class SmallModalViewController: UIViewController, CustomAnimatedTransitionable {
    
//    @IBOutlet weak var contentView: UIView?

    fileprivate var borderHidden = false
    fileprivate var peekMode = false

    var customTransitionType: GratuitousTransitioningDelegateType {
        return .bottom
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.systemTextSizeDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
//        self.configureDynamicTextLabels()
//    }
    
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
    
//    func setPeekModeEnabled() {
//        self.preferredContentSize = CGSize(width: 320, height: 400)
//        self.borderHidden = true
//        self.peekMode = true
//    }
//
//    func setPopModeEnabled() {
//        self.preferredContentSize = CGSize(width: 320, height: 568)
//        self.borderHidden = false
//        self.peekMode = false
//    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape, UIInterfaceOrientationMask.portraitUpsideDown]
    }
}
