//
//  GratuitousAppDelegate+StateRestoration.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

extension GratuitousAppDelegate {
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        if self.window?.rootViewController?.presentedViewController == .none {
            return false
        }
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        if let coderVersion = coder.decodeObject(forKey: UIApplicationStateRestorationBundleVersionKey) as? String,
            let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String, coderVersion == bundleVersion {
                return true
        } else {
            return false
        }
    }
    
    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        guard let viewControllerID = identifierComponents.last as? String else { return .none }
        
        let vc: UIViewController?
        switch viewControllerID {
        case "TipViewController":
            vc = .none // do nothing because this is the main view controller
        case "SettingsTableViewController":
            vc = .none // do nothing because we actually need to customize the nav controller for this view controller
        default:
            vc = self.storyboard.instantiateViewController(withIdentifier: viewControllerID)
        }
        
        if let vc = vc,
            let transitionable = vc as? CustomAnimatedTransitionable {
                switch transitionable.customTransitionType {
                case .right:
                    vc.transitioningDelegate = self.presentationRightTransitionerDelegate
                    vc.modalPresentationStyle = UIModalPresentationStyle.custom
                case .bottom:
                    vc.transitioningDelegate = self.presentationBottomTransitionerDelegate
                    vc.modalPresentationStyle = UIModalPresentationStyle.custom
                case .notApplicable:
                    break
                }
        }
        
        return vc
    }

}
