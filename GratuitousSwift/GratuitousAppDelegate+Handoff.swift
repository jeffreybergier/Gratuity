//
//  GratuitousAppDelegate+Handoff.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

extension GratuitousAppDelegate {
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        let handled: Bool
        let completion: () -> Void
        if let handoff = HandoffTypes(rawValue: userActivity.activityType) {
            switch handoff {
            case .SplitBillPurchase:
                completion = { self.window?.rootViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.PurchaseSplitBill.rawValue, sender: self) }
                handled = true
            case .MainTipInterface:
                completion = { }
                handled = true
            case .SettingsInterface:
                completion = { self.window?.rootViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.Settings.rawValue, sender: self) }
                handled = true
            case .SplitBillInterface:
                completion = { self.window?.rootViewController?.performSegueWithIdentifier(TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self) }
                handled = true
            }
        } else {
            completion = {}
            handled = false
        }
        
        if let presentedVC = self.window?.rootViewController?.presentedViewController {
            presentedVC.dismissViewControllerAnimated(true, completion: completion)
        } else {
            completion()
        }
        
        return handled
    }
}