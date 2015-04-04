//
//  GratuitousMenuInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/17/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class GratuitousMenuInterfaceController: WKInterfaceController {
    
    private var privateInterfaceControllerIsConfigured = false
    enum MenuItemTarget: Selector {
        case UserChoseMenuItem1 = "userChoseMenuItem1", UserChoseMenuItem2 = "userChoseMenuItem2", UserChoseMenuItem3 = "userChoseMenuItem3", UserChoseMenuItem4 = "userChoseMenuItem4"
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.privateInterfaceControllerIsConfigured == false {
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                dispatch_async(dispatch_get_main_queue()) {
                    // configure the menu
                    self.configureMenuItem1()
                    self.configureMenuItem2()
                    self.configureMenuItem3()
                    self.configureMenuItem4()
                    
                    self.privateInterfaceControllerIsConfigured = true
                }
            }
        }
    }
    
    func configureMenuItem1() {
        // presents a modal display of settings screen by default.
        self.addMenuItemWithItemIcon(WKMenuItemIcon.More, title: NSLocalizedString("Settings", comment: ""), action: MenuItemTarget.UserChoseMenuItem1.rawValue)
    }
    
    func configureMenuItem2() {
        // defaults to start over button
        //self.addMenuItemWithItemIcon(WKMenuItemIcon.Repeat, title: NSLocalizedString("Start Over", comment: ""), action: MenuItemTarget.UserChoseMenuItem2.rawValue)
    }
    
    func configureMenuItem3() {
        // defaults to switch UI to three button stepper bill
        //self.addMenuItemWithItemIcon(WKMenuItemIcon.Shuffle, title: NSLocalizedString("Switch", comment: ""), action: MenuItemTarget.UserChoseMenuItem3.rawValue)
    }
    
    func configureMenuItem4() {
        // does nothing by default
    }
    
    func userChoseMenuItem1() {
        // presents a modal display of settings screen by default.
        self.presentControllerWithName("SettingsInterfaceController", context: nil)
    }
    
    func userChoseMenuItem2() {
        // defaults to start over button
        //self.popToRootController()
    }
    
    func userChoseMenuItem3() {
        // defaults to switch UI to three button stepper bill
        //self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: ThreeButtonStepperInterfaceContext.Bill.rawValue)
    }
    
    func userChoseMenuItem4() {
        // does nothing by default
    }
}