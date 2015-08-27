//
//  AppDelegate.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 10/8/14.
//  Copyright (c) 2014 SaturdayApps. All rights reserved.
//

import UIKit
//import Fabric
//import Crashlytics

@UIApplicationMain
class GratuitousAppDelegate: UIResponder, UIApplicationDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let defaultsManager = GratuitousUserDefaults()
    private let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //crashlytics intializer
//        Fabric.with([Crashlytics()])
        
        //initialize the view controller from the storyboard
        let tipViewController = self.storyboard.instantiateInitialViewController()
        
        //configure the window
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        }
        
        // Check if the date is April 24 or later to display watch info UI
        self.defaultsManager.watchInfoViewControllerShouldAppear = self.defaultsManager.currentDateIsAfterWatchRelease(considerJuneCutoff: true)
        
        // if the device is an iphone 4s or an ipad, mark watchInfoViewControllerWasDismissed as true
        if self.defaultsManager.watchInfoViewControllerWasDismissed == false {
            self.defaultsManager.watchInfoViewControllerWasDismissed = self.checkForWatchInvalidDevice()
        }
        
        self.window?.rootViewController = tipViewController
        self.window?.backgroundColor = GratuitousUIConstant.darkBackgroundColor();
        self.window?.tintColor = GratuitousUIConstant.lightTextColor()
        self.window!.makeKeyAndVisible() //if window is not initialized yet, this should crash.
        
        // remove later
        self.generateImages()
        
        return true
    }
    
    private func checkForWatchInvalidDevice() -> Bool {
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            return true
        case .Phone:
            let screenHeight = UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width ? UIScreen.mainScreen().bounds.size.height : UIScreen.mainScreen().bounds.size.width
            if screenHeight < 568 { // if its an iphone and if the screen is smaller than 568, its an iphone 4s and its not apple watch compatible
                return true
            } else {
                return false
            }
        case .Unspecified:
            return false
        }
    }
    
    func generateImages() {
        //generate images for the watch
        let queue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
        dispatch_async(queue) {
            //let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
            let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
            //let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
            
            let imageGenerator = GratuitousLabelImageGenerator()
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsPath: NSString = paths.first! //Get the docs directory
            for i in 1 ... 100 {
                let string = NSAttributedString(string: "$\(i)", attributes: valueTextAttributes)
                if let image = imageGenerator.generateImageForAttributedString(string) {
                    let filePath = documentsPath.stringByAppendingPathComponent("image\(i).png")
                    let data = UIImagePNGRepresentation(image)
                    data?.writeToFile(filePath, atomically: true)
                }
            }
            print("Files written to path: \(documentsPath)")
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //Crashlytics.sharedInstance().crash()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

