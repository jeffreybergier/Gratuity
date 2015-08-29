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
class GratuitousAppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    //initialize the window and the storyboard
    var window: UIWindow?
    let defaultsManager = GratuitousUserDefaults()
    private let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
    private let currencyFormatter = GratuitousCurrencyFormatter()
    private let watchSession: WCSession? = {
        if WCSession.isSupported() {
           return WCSession.defaultSession()
        } else {
            return .None
        }
    }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //crashlytics intializer
//        Fabric.with([Crashlytics()])
        
        if let session = self.watchSession {
            session.delegate = self
            session.activateSession()
        }
        
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
//        if let session = self.watchSession,
//            let url = self.generateNewImages() {
//                session.transferFile(url, metadata: ["CurrencyCode" : self.currencyFormatter.currencyCode])
//        }
        
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
    
    @available(iOS 9, *)
    func generateNewImages() -> NSURL? {
        //generate images for the watch
        if let _ = self.watchSession {
            //let subtitleTextAttributes = GratuitousUIColor.WatchFonts.subtitleText
            let valueTextAttributes = GratuitousUIColor.WatchFonts.valueText
            //let largerButtonTextAttributes = GratuitousUIColor.WatchFonts.buttonText
            
            let imageGenerator = GratuitousLabelImageGenerator()
            var images = [UIImage]()
            for i in 1 ... 250 {
                let string = NSAttributedString(string: self.currencyFormatter.currencyFormattedString(i), attributes: valueTextAttributes)
                if let image = imageGenerator.generateImageForAttributedString(string) {
                    images += [image]
                }
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(images)
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let dataURL = documentsURL.URLByAppendingPathComponent("imageArray.data")
            data.writeToURL(dataURL, atomically: true)
            return dataURL
        }
        return .None
    }


    func sessionWatchStateDidChange(session: WCSession) {
        print("GratuitousiOSConnectivityDelegate: sessionWatchStateDidChange: \(session)")
    }

    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        print("GratuitousiOSConnectivityDelegate: Message Received: \(message) without reply handler")
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("GratuitousiOSConnectivityDelegate: Message Received: \(message)")
        replyHandler(["reply" : "sending data..."])
        if let session = self.watchSession,
            let url = self.generateNewImages() {
                session.transferFile(url, metadata: ["CurrencyCode" : self.currencyFormatter.currencyCode])
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("GratuitousiOSConnectivityDelegate: didReceiveApplicationContext: \(applicationContext)")
    }
    
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        print("GratuitousiOSConnectivityDelegate: didFinishUserInfoTransfer: \(userInfoTransfer)")
    }
    
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        print("GratuitousiOSConnectivityDelegate: didReceiveUserInfo: \(userInfo)")
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print("GratuitousiOSConnectivityDelegate: didFinishFileTransfer: \(fileTransfer)")
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("GratuitousiOSConnectivityDelegate: didReceiveFile: \(file)")
    }
}

