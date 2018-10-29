//
//  GratuitousAppDelegate+Handoff.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/15/15.
//  Copyright © 2015 SaturdayApps. All rights reserved.
//

import UIKit

extension GratuitousAppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let handled: Bool
        let completion: () -> Void
        if let handoff = HandoffTypes(rawValue: userActivity.activityType) {
            switch handoff {
            case .SplitBillPurchase:
                completion = { self.window?.rootViewController?.performSegue(withIdentifier: TipViewController.StoryboardSegues.PurchaseSplitBill.rawValue, sender: self) }
                handled = true
            case .MainTipInterface:
                completion = { }
                handled = true
            case .SettingsInterface:
                completion = { self.window?.rootViewController?.performSegue(withIdentifier: TipViewController.StoryboardSegues.Settings.rawValue, sender: self) }
                handled = true
            case .SplitBillInterface:
                completion = { self.window?.rootViewController?.performSegue(withIdentifier: TipViewController.StoryboardSegues.SplitBill.rawValue, sender: self) }
                handled = true
            }
        } else {
            completion = {}
            handled = false
        }
        
        if let presentedVC = self.window?.rootViewController?.presentedViewController {
            presentedVC.dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
        
        return handled
    }
}
