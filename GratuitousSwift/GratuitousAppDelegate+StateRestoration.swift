//
//  GratuitousAppDelegate+StateRestoration.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

extension GratuitousAppDelegate {
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        if self.window?.rootViewController?.presentedViewController == .None {
            UIApplication.sharedApplication().ignoreSnapshotOnNextApplicationLaunch()
        }
        return true
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        if let coderVersion = coder.decodeObjectForKey(UIApplicationStateRestorationBundleVersionKey) as? String,
            let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
            where coderVersion == bundleVersion {
                return true
        } else {
            return false
        }
    }
    
    func application(application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        guard let viewControllerID = identifierComponents.last as? String else { return .None }
        
        let vc: UIViewController?
        switch viewControllerID {
        case "TipViewController":
            vc = .None // do nothing because this is the main view controller
        case "SettingsTableViewController":
            vc = .None // do nothing because we actually need to customize the nav controller for this view controller
        default:
            vc = self.storyboard.instantiateViewControllerWithIdentifier(viewControllerID)
        }
        
        if let vc = vc,
            let transitionable = vc as? CustomAnimatedTransitionable {
                switch transitionable.customTransitionType {
                case .Right:
                    vc.transitioningDelegate = self.presentationRightTransitionerDelegate
                    vc.modalPresentationStyle = UIModalPresentationStyle.Custom
                case .Bottom:
                    vc.transitioningDelegate = self.presentationBottomTransitionerDelegate
                    vc.modalPresentationStyle = UIModalPresentationStyle.Custom
                case .NotApplicable:
                    break
                }
        }
        
        return vc
    }

}