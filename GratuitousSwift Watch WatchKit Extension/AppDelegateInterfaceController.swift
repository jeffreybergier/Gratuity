//
//  AppDelegateInterfaceController.swift
//  GratuitousSwift
//
//  Created by Jeffrey Bergier on 2/8/15.
//  Copyright (c) 2015 SaturdayApps. All rights reserved.
//

import WatchKit

class AppDelegateInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var crownScrollButton: WKInterfaceButton?
    @IBOutlet weak var stepByStepButton: WKInterfaceButton?
    
    private let dataSource = GratuitousWatchDataSource.sharedInstance
    
    override func willActivate() {
        super.willActivate()
        
        self.crownScrollButton?.setHidden(true)
        self.stepByStepButton?.setHidden(true)
        
        switch self.dataSource.interfaceState {
        case .CrownScrollInfinite:
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: InterfaceControllerContext.CrownScrollInfinite.rawValue)
        case .CrownScrollPaged:
            self.pushControllerWithName("CrownScrollBillInterfaceController", context: InterfaceControllerContext.CrownScrollPagedTens.rawValue)
        case .ThreeButtonStepper:
            self.pushControllerWithName("ThreeButtonStepperBillInterfaceController", context: InterfaceControllerContext.ThreeButtonStepperBill.rawValue)
//        case .StepperInfinite:
//            self.pushControllerWithName("StepperInfiniteInterfaceController", context: InterfaceControllerContext.StepperInfinite.rawValue)
//        case .StepperPaged:
//            self.pushControllerWithName("StepperTensInterfaceController", context: InterfaceControllerContext.StepperPagedTens.rawValue)
        }
    }
}
