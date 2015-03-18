//
//  GratuitousMenuInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 3/17/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class GratuitousMenuInterfaceController: WKInterfaceController {
    
    private var interfaceControllerIsConfigured = false
    var menuType: MenuType {
        return MenuType.Unknown
    }
    
    enum MenuType {
        case Unknown, SwitchBillFromScrollingToThreeButton, SwitchTipFromScrollingToThreeButton, SwitchBillFromThreeButtonToScrolling, SwitchTipFromThreeButtonToScrolling
    }
    
    override func willActivate() {
        super.willActivate()
        
        if self.interfaceControllerIsConfigured == false {
            let backgroundQueue = dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            dispatch_async(backgroundQueue) {
                // configure the menu
                self.addMenuItemWithItemIcon(WKMenuItemIcon.Shuffle, title: NSLocalizedString("Switch", comment: ""), action: "menuSwitchUIButtonChosen")
                self.addMenuItemWithItemIcon(WKMenuItemIcon.Repeat, title: NSLocalizedString("Start Over", comment: ""), action: "menuStartOverButtonChosen")
                self.addMenuItemWithItemIcon(WKMenuItemIcon.More, title: NSLocalizedString("Settings", comment: ""), action: "menuSettingsButtonChosen")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.interfaceControllerIsConfigured = true
                }
            }
        }
    }
    
    @objc private func menuSwitchUIButtonChosen() {
        switch self.menuType {
        case .SwitchBillFromScrollingToThreeButton:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
        case .SwitchBillFromThreeButtonToScrolling:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
        case .SwitchTipFromScrollingToThreeButton:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
        case .SwitchTipFromThreeButtonToScrolling:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
        case .Unknown:
            break
        }
    }
    
    @objc private func menuStartOverButtonChosen() {
        self.popToRootController()
    }
    
    @objc private func menuSettingsButtonChosen() {
        self.presentControllerWithName("SettingsInterfaceController", context: nil)
    }
}