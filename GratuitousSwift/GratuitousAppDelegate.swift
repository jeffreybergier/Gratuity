//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import WatchConnectivity
import Fabric
import Crashlytics

@UIApplicationMain
final class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let dataSource = GratuitousiOSDataSource(use: .AppLifeTime)
    private lazy var storyboard: UIStoryboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    private lazy var presentationRightTransitionerDelegate = GratuitousTransitioningDelegate(type: .Right, animate: false)
    private lazy var presentationBottomTransitionerDelegate = GratuitousTransitioningDelegate(type: .Bottom, animate: false)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
        //Fabric.with([Crashlytics()])
        
        self.window!.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        
        if #available(iOS 9, *) {
            self.transferBulkCurrencySymbolsIfNeeded()
        }
        
        return true
    }
    
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
    
    @available (iOS 9, *)
    private func transferBulkCurrencySymbolsIfNeeded() {
        //on first run make a last ditch effort to send a lot of currency symbols to the watch
        //this may prevent waiting on the watch later
        if let watchConnectivityManager = self.dataSource.watchConnectivityManager as? GratuitousiOSConnectivityManager,
            let session = watchConnectivityManager.session
            where session.paired == true && session.watchAppInstalled == true {
                if self.dataSource.defaultsManager.freshWatchAppInstall == true {
                    self.dataSource.defaultsManager.freshWatchAppInstall = false
                    let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
                    dispatch_async(backgroundQueue) {
                        let generator = GratuitousCurrencyStringImageGenerator()
                        if let files = generator.generateAllCurrencySymbols() {
                            watchConnectivityManager.transferBulkData(files)
                        }
                    }
                }
        } else {
            // watch app not installed or watch not paired
            self.dataSource.defaultsManager.freshWatchAppInstall = true
        }
    }
}

