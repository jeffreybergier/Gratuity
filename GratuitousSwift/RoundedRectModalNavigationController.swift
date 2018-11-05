//
//  SmallModalViewController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 9/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

class RoundedRectModalNavigationController: UINavigationController {

    override var preferredContentSize: CGSize {
        get { return CGSize(width: 320, height: 568) }
        set { super.preferredContentSize = newValue }
    }

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

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.landscape, UIInterfaceOrientationMask.portraitUpsideDown]
    }
}
