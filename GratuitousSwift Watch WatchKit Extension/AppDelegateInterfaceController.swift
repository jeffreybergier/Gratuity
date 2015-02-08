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
        
        let corectInterface = self.dataSource.correctInterface
        switch self.dataSource.correctInterface {
        case .CrownScroll:
            self.pushControllerWithName("CrownScrollInterfaceController", context: nil)
        default:
            self.pushControllerWithName("CrownScrollInterfaceController", context: nil)
            //self.pushControllerWithName("BillAmountInterfaceController", context: nil)
        }
    }
}
