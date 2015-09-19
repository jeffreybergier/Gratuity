//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
import WatchConnectivity
//import Fabric
//import Crashlytics

@UIApplicationMain
class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let dataSource = GratuitousiOSDataSource(use: .AppLifeTime)
    private lazy var storyboard: UIStoryboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    private var presentationTransitionerDelegate: GratuitousTransitioningDelegate?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch
        
        //crashlytics intializer
        //Fabric.with([Crashlytics()])
        
        self.window!.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        
        if let delegate = self.presentationTransitionerDelegate {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                delegate.shouldAnimate = true
            }
        }
        
        if #available(iOS 9, *) {
            self.transferBulkCurrencySymbolsIfNeeded()
        }
        
        return true
    }
    
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
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
        
        if let vc = vc {
            let delegate = GratuitousTransitioningDelegate()
            delegate.shouldAnimate = false
            vc.transitioningDelegate = delegate
            vc.modalPresentationStyle = UIModalPresentationStyle.Custom
            self.presentationTransitionerDelegate = delegate
        }
        
        return vc
    }
    
    @available (iOS 9, *)
    private func transferBulkCurrencySymbolsIfNeeded() {
        //on first run make a last ditch effort to send a lot of currency symbols to the watch
        //this may prevent waiting on the watch later
        if let watchConnectivityManager = self.dataSource.watchConnectivityManager as? GratuitousiOSConnectivityManager,
            let session = watchConnectivityManager.session
            where session.paired == true && session.watchAppInstalled == true {
                if self.dataSource.defaultsManager?.freshWatchAppInstall == true {
                    self.dataSource.defaultsManager?.freshWatchAppInstall = false
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
            self.dataSource.defaultsManager?.freshWatchAppInstall = true
        }
    }
}

